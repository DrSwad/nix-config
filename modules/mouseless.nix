{ config, lib, pkgs, ... }:

let
  cfg = config.swad.mouseless;

  devicesYaml = lib.optionalString (cfg.devices != [ ])
    ("devices:\n" + lib.concatMapStrings (d: "  - ${d}\n") cfg.devices + "\n");
in
{
  options.swad.mouseless.devices = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [ "/dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-kbd" ];
    description = ''
      Input devices mouseless grabs, as paths under /dev/input. Prefer stable
      /dev/input/by-id/ symlinks; /dev/input/eventN numbering can shift across
      reboots. Empty means auto-detect every keyboard, which is the safe
      default for a host whose hardware we don't know.

      Worth pinning when a device other than your keyboard also registers a
      kbd handler — Logitech receivers, laptop hotkey blocks, power buttons —
      since grabbing those can swallow their input.
    '';
  };

  config = {
    # mouseless: keyboard-driven pointer control, evdev-level so it works under Wayland
    environment.systemPackages = [ pkgs.mouseless ];

    # Loads the uinput kernel module, creates the uinput group, and adds the
    # udev rule that makes /dev/uinput writable by that group.
    hardware.uinput.enable = true;

    # NIXPKGS-PIN: nixpkgs ships mouseless 0.2.0. mod-layer, devicesExclude, and selecting
    # devices by name all need 0.3.0, so they're avoided below.
    environment.etc."mouseless/config.yaml".text = ''
      ${devicesYaml}baseMouseSpeed: 750.0
      baseScrollSpeed: 20.0

      layers:
        - name: initial
          bindings:
            # tap capslock -> esc, hold capslock -> mouse layer
            capslock: tap-hold esc ; toggle-layer mouse ; 200

        - name: mouse
          # unmapped keys keep their normal meaning
          passThrough: true
          bindings:
            h: move -1  0
            j: move  0  1
            k: move  0 -1
            l: move  1  0

            u: scroll up
            n: scroll down

            f: button left
            d: button right
            s: button middle

            leftshift: speed 2.5
            space: speed 0.25
    '';

    systemd.services.mouseless = {
      description = "mouseless keyboard-driven pointer control";
      wantedBy = [ "multi-user.target" ];
      # environment.etc isn't a unit dependency, so without this a config
      # edit rebuilds successfully while the old config keeps running.
      restartTriggers = [ config.environment.etc."mouseless/config.yaml".source ];
      serviceConfig = {
        ExecStart = "${pkgs.mouseless}/bin/mouseless --config /etc/mouseless/config.yaml";
        # 0.2.0 exits if no matching device exists yet, so cover the boot race
        # and receiver unplugs.
        Restart = "always";
        RestartSec = 2;
      };
    };
  };
}
