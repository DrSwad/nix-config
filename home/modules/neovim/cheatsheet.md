# Neovim cheatsheet

`Space` is the leader key. "Terminal mode" means the cursor is inside the terminal panel.

## Editor tabs

| Action | Key |
|---|---|
| New tab (empty buffer) | `Space t n` |
| Close tab | `Space t c` |
| Next / previous tab | `gt` / `gT` |
| Go to tab n | `{n}gt` (e.g. `3gt`) |

## File search

| Action | Key |
|---|---|
| Find file in project | `Ctrl+P` |
| Open in current window / new tab / vertical split | `Enter` / `Ctrl+T` / `Ctrl+V` |
| Close picker | `Ctrl+C` |

## Surround and jump

| Action | Key |
|---|---|
| Add surround | `ys{motion}{char}` (e.g. `ysiw"`) |
| Delete / change surround | `ds{char}` / `cs{old}{new}` |
| Surround selection | Visual mode, then `S{char}` |
| Jump (easymotion) | `s`, type a few chars, press the label |

## File tree

| Action | Key |
|---|---|
| Focus tree ↔ editor | `Space e` |
| Show / hide tree | `Space E` |
| Filter / clear filter | `f` / `F` |
| Toggle hovered directory | `Enter` or `o` |
| Collapse parent (from a file) | `Backspace` |
| Expand all / collapse all | `E` / `W` |
| New file or dir (end with `/` for a dir) | `a` |
| Rename | `r` |
| Move | `x` then `p`, or `u` to edit the full path |
| Copy | `c` then `p` |
| Delete | `d` |
| Help | `g?` |

## Terminal

| Action | Key |
|---|---|
| Show / hide panel | `Alt+t` |
| New terminal tab | `Alt+c` |
| Close terminal tab | `Alt+x` (terminal mode) |
| Next / previous terminal tab | `Alt+n` / `Alt+p` (terminal mode) |
| Focus terminal ↔ editor | `Alt+h/j/k/l` |
| Exit terminal mode (to scroll or copy) | `Ctrl+\ Ctrl+N` |

## Panes

| Action | Key |
|---|---|
| Vertical / horizontal split | `Space v` / `Space s` |
| Close pane | `Space x` |
| Focus | `Alt+h/j/k/l` |
| Narrower / wider | `Ctrl+Left` / `Ctrl+Right` |
| Shorter / taller | `Ctrl+Down` / `Ctrl+Up` |
| Equalize sizes | `Ctrl+W =` |
| Move pane to far left / bottom / top / right | `Alt+Shift+h/j/k/l` |
| Swap with next pane | `Ctrl+W x` |

## Python (LSP)

Start `nvim` from inside the FHS env, with the venv activated if you use one, so the LSP sees the project's packages.

| Action | Key |
|---|---|
| Hover docs | `K` |
| Go to definition / type definition | `gd` / `grt` |
| References | `grr` |
| Rename symbol | `grn` |
| Code actions | `gra` |
| Next / previous diagnostic | `]d` / `[d` |
| Show diagnostic | `Ctrl+W d` |
| Completion: select / accept | `Ctrl+N`, `Ctrl+P` / `Ctrl+Y` |
| Signature help (insert mode) | `Ctrl+S` |
