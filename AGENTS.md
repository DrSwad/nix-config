# AGENTS.md

Rules for AI agents working in this repository.

## No automatic rebuilds

Never run a NixOS rebuild or deploy yourself. Never run any of these:

- `nixos-rebuild` (build / switch / test / dry-activate)
- `flakes.nix update` or any other deploy pipeline

Correct procedure:

1. Make the config edit.
2. Tell the user to run `git add -A` and `nixos-rebuild switch --flake
   .#swad-lab-pc --sudo` to commit and apply, then stop and wait for review.

Non-system-impacting commands like `nix eval` / `nix flake check` are fine
when needed for the task.
