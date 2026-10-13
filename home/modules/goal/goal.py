#!@python@
import json
import re
import secrets
import subprocess
import sys
import time
import urllib.request
from datetime import date, datetime, time as dtime
from pathlib import Path


# NIXPKGS-PIN: written against TimeTagger 26.1.3. Per-tag targets live in
# "taginfo #tag" settings as targets.day (hours), and t1 == t2 marks a running
# record. Recheck both after nixpkgs bumps python3Packages.timetagger.
API = "http://127.0.0.1:@port@/timetagger/api/v2/"
TOKEN = Path.home() / ".config/timetagger/api-token"
TAG = re.compile(r"#[\w/-]+")
PAUSE = "⏸ pause"
PLAN = "✎ plan today"


def call(method, path, body=None):
    req = urllib.request.Request(
        API + path,
        method=method,
        data=None if body is None else json.dumps(body).encode(),
        headers={"authtoken": TOKEN.read_text().strip(), "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=5) as r:
        return json.load(r)


def tags(record):
    return list(dict.fromkeys(t.lower() for t in TAG.findall(record.get("ds") or "")))


def taginfo():
    return {
        s["key"].removeprefix("taginfo "): s["value"]
        for s in call("GET", "settings")["settings"]
        if s["key"].startswith("taginfo ")
    }


def snapshot():
    now = time.time()
    midnight = datetime.combine(date.today(), dtime.min).timestamp()
    plan = {
        tag: v["targets"]["day"] * 3600
        for tag, v in taginfo().items()
        if v.get("targets", {}).get("day")
    }
    spent, running = {}, []
    for r in call("GET", f"records?timerange={int(midnight)}-{int(now)}")["records"]:
        if (r.get("ds") or "").startswith("HIDDEN"):
            continue
        if r["t1"] == r["t2"]:
            running.append(r)
        end = now if r["t1"] == r["t2"] else r["t2"]
        for tag in tags(r):
            spent[tag] = spent.get(tag, 0) + max(0, end - max(r["t1"], midnight))
    return now, plan, spent, running


def hms(s):
    s = int(abs(s))
    return f"{s // 3600}:{s // 60 % 60:02}:{s % 60:02}"


def label(plan, spent, running):
    current = [t for r in running for t in tags(r)]
    if current:
        tag = next((t for t in current if t in plan), current[0])
        if tag not in plan:
            return f"{tag[1:]} {hms(spent.get(tag, 0))}", "running"
        left = plan[tag] - spent.get(tag, 0)
        return (f"{tag[1:]} {hms(left)}", "running") if left >= 0 else (f"{tag[1:]} +{hms(left)}", "over")
    if not plan:
        return "no plan", "idle"
    left = sum(max(0, s - spent.get(t, 0)) for t, s in plan.items())
    return f"paused · {hms(left)} left", "idle"


def watch():
    snap, fetched = None, 0.0
    while True:
        now = time.time()
        if now - fetched >= 2:
            fetched = now
            try:
                snap = snapshot()
            except (OSError, ValueError, KeyError):
                snap = None
        if snap is None:
            text, state = "timetagger unreachable", "error"
        else:
            t0, plan, spent, running = snap
            spent = dict(spent)
            for tag in {t for r in running for t in tags(r)}:
                spent[tag] = spent.get(tag, 0) + now - t0
            text, state = label(plan, spent, running)
        print(json.dumps({"text": text, "state": state}), flush=True)
        time.sleep(1 - time.time() % 1)


def rofi(lines, *args):
    r = subprocess.run(["rofi", "-dmenu", "-i", *args], input="\n".join(lines), capture_output=True, text=True)
    return r.stdout.rstrip("\n") if r.returncode == 0 else None


def switch():
    _, plan, spent, running = snapshot()
    current = {t for r in running for t in tags(r)}
    rows = {}
    for tag in sorted(plan):
        left = plan[tag] - spent.get(tag, 0)
        status = f"{hms(left)} left" if left >= 0 else f"{hms(left)} over"
        rows[f"{'▶' if tag in current else ' '} {tag[1:]:<20} {status}"] = tag
    active = [str(i) for i, tag in enumerate(rows.values()) if tag in current]
    choice = rofi(
        [*rows, *([PAUSE] if running else []), PLAN],
        "-p", "goal", *(["-a", ",".join(active)] if active else []),
    )
    if not choice:
        return
    if choice == PLAN:
        return plan_today()
    now = time.time()
    stop = [dict(r, t2=max(int(now), r["t1"] + 1), mt=now) for r in running]
    if choice == PAUSE:
        if stop:
            call("PUT", "records", stop)
        return
    tag = rows.get(choice) or "#" + choice.strip().lstrip("#").lower()
    if not TAG.fullmatch(tag) or current == {tag}:
        return
    start = {"key": secrets.token_hex(4), "t1": int(now), "t2": int(now), "ds": tag, "mt": now, "st": 0.0}
    call("PUT", "records", [*stop, start])


def plan_today():
    info = taginfo()
    current = ", ".join(
        f"{tag[1:]} {v['targets']['day']:g}"
        for tag, v in sorted(info.items())
        if v.get("targets", {}).get("day")
    )
    text = rofi([], "-p", "plan", "-filter", current, "-theme-str", "listview { enabled: false; }")
    if text is None:
        return
    new = {}
    try:
        for item in filter(None, (i.strip() for i in text.split(","))):
            name, _, amount = item.rpartition(" ")
            tag = "#" + name.strip().lstrip("#").lower()
            h, _, m = amount.partition(":")
            hours = round(float(h) + float(m or 0) / 60, 2)
            if not TAG.fullmatch(tag):
                raise ValueError(tag)
            new[tag] = int(hours) if hours.is_integer() else hours
    except ValueError:
        subprocess.run(["rofi", "-e", f"Not a plan: {text}\nExpected: research 5, meeting 1:30"])
        return
    # Only the day target is rewritten; week/month targets set in the web UI survive.
    now = time.time()
    updates = []
    for tag in info.keys() | new.keys():
        value = info.get(tag, {"targets": {}, "priority": 0, "color": ""})
        targets = {k: v for k, v in value.get("targets", {}).items() if k != "day"}
        if new.get(tag, 0) > 0:
            targets["day"] = new[tag]
        if targets != value.get("targets", {}):
            updates.append({"key": f"taginfo {tag}", "value": {**value, "targets": targets}, "mt": now, "st": 0.0})
    if updates:
        call("PUT", "settings", updates)


if __name__ == "__main__":
    commands = {"watch": watch, "switch": switch, "plan": plan_today}
    if len(sys.argv) != 2 or sys.argv[1] not in commands:
        sys.exit("usage: goal watch|switch|plan")
    try:
        commands[sys.argv[1]]()
    except (OSError, ValueError) as err:
        subprocess.run(["rofi", "-e", f"goal: {err}"])
    except KeyboardInterrupt:
        pass
