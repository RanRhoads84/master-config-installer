# 📝 ModularNotes Quick Reference

ModularNotes keeps your notes, todos, and project files in markdown so you can capture ideas from any shell and sync them across devices.

## Basic commands

- `modularnotes "Quick idea"` – append a plain text note to your inbox.
- `modularnotes todo "Fix setup menu"` – queue a todo with Markdown-style checkboxes.
- `modularnotes list` – review recent notes.
- `modularnotes list --todos` – show open todos only.
- `modularnotes project` – open the fuzzy project manager (requires `fzf`).
- `modularnotes clip` – capture the clipboard (`xclip` or `wl-clipboard` required).

## Project workflow

1. `modularnotes project new my-project` to create a project portal.
2. `modularnotes project my-project "Initial notes"` to append context.
3. Use `modularnotes list --projects` (if available) to preview entries with `fzf`.

## Aliases

Installers add helpers such as:

- `mn` → `modularnotes`
- `mnt` → `modularnotes todo`
- `mnl` → `modularnotes list`
- `mnp` → `modularnotes project`
- `mnc` → `modularnotes clip`

Source ~/.config/modularnotes/aliases.bash from your shell rc to make them available.

## Clipboard capture

Enable clipboard capture in KDE/Wayland/X11 by installing `xclip` or `wl-clipboard`. Then run:

```
modularnotes clip
```

It will prompt for confirmation before saving the clipboard to a timestamped note.

## Troubleshooting

- **Aliases missing**: rerun the installer with `./install.sh` or manually source ~/.config/modularnotes/aliases.bash.
- **Project manager errors**: install `fzf` if `modularnotes project` reports it missing.
- **Notes directory not found**: ensure ~/Documents/ModularNotes exists or update ~/.config/modularnotes/modularnotes.conf and restart your shell.