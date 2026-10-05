# Standing rules

These apply to every task, in every directory. A project's own AGENTS.md can add stricter rules but never relaxes these.

## Ask before changing anything

Ask the user and wait for approval before any action that is not read-only. This includes, but is not limited to: creating, editing or deleting files; staging or committing in git; rebuilding the NixOS config; starting model training or evaluation.

Say exactly what you intend to do when you ask. An approval covers only what you described. Reading files and running read-only commands need no approval.

Approved in advance:

- creating the tmux session, the tmux window and the scratch directory described below;
- writing a scratch script and running it, provided everything the script does is read-only. If you are not certain of that, ask first;
- deleting scratch files you created;
- closing the tmux window you created.

## Run commands through tmux

Run every shell command inside the tmux session `agents`, never directly. Drive it non-interactively; do not attach to it.

1. Work in one named window. If the user has not given you a window name, ask for one before running anything.
2. Create the window:
   - if `tmux has-session -t agents` fails: `tmux new-session -d -s agents -n NAME`
   - otherwise: `tmux new-window -d -t agents: -n NAME`
3. Send a command: `tmux send-keys -t agents:NAME 'COMMAND' Enter`
4. Read the output: `tmux capture-pane -p -t agents:NAME -S -200`

Reuse that window for the rest of the task.

For a long-running command, repeat step 4 at intervals. If it is still running after a few minutes, stop polling, ask the user to check the window and to tell you when it has finished, then continue from there.

## Scratch files

Put any scratch script you need in `~/agents-scratch` and nowhere else; create the directory if it is missing.

## Clean up

Once the task is definitely finished and successful:

- delete the scratch files you created, and only those;
- close your tmux window with `tmux kill-window -t agents:NAME`. Never close a window you did not create, or one where something is still running.
