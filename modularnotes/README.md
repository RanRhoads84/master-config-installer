![Made for Debian](https://img.shields.io/badge/Made%20for-Debian-A81D33?style=for-the-badge)

# 📝 ModularNotes

ModularNotes is the ModularConfig Suite's terminal-first note-taking and todo manager. It captures inbox-style notes, todos, and project files in markdown so you can sync with mobile apps or collaborate using plain text workflows. The helper ships with lightweight integrations for `fzf`, clipboard utilities, and your shell of choice.

## Philosophy

- **Capture first, organize later** — jot ideas without deciding their final location.
- **Plain-text friendly** — every file stays markdown so other devices and apps can read it.
- **Shell native** — interactive prompts, aliases, and clipboard helpers suit any shell session.
- **Modular pairing** — works alongside ModularShell and other ModularConfig Suite pieces without duplicating effort.

## Installation

```bash
cd modularnotes
./install.sh
```

The installer writes configuration to `~/.config/modularnotes/modularnotes.conf` (legacy key names remain for compatibility) and deploys the `modularnotes` command into `~/.local/bin`. It also creates `~/.config/modularnotes/aliases.bash` so you can source it from your shell rc file.

## Quick Start

- `modularnotes "Idea for ModularConfig"` — append a note.
- `modularnotes todo "Review optional tools"` — queue a todo item.
- `modularnotes list` — skim recent captures.
- `modularnotes project` — open the `fzf`-powered project manager (requires `fzf`).
- `modularnotes clip` — capture clipboard content (requires `xclip` or `wl-clipboard`).

## Configuration

The installer emits this baseline config, which you can tweak and reload:

```bash
MODULARNOTES_DIR="$HOME/Documents/ModularNotes"
NOTES_FILE="$MODULARNOTES_DIR/notes.md"
TODOS_FILE="$MODULARNOTES_DIR/todos.md"
MODULARNOTES_EDITOR="${EDITOR:-nano}"
```

Adjust the paths or editor and restart your shell so alias sourcing takes effect.

## Aliases

Installation can drop shell helpers such as:

```bash
alias mn="modularnotes"
alias mnt="modularnotes todo"
alias mnl="modularnotes list"
alias mnp="modularnotes project"
```

Source `~/.config/modularnotes/aliases.bash` if your rc file does not already load it.

## Integrations

- **ModularShell** — keeps your shell experience aligned with ModularNotes workflows.
- **Optional tools menu** — ModularConfig's installer can add browsers, theming helpers, and fastfetch without conflicts.
- **Clipboard utilities** — `modularnotes clip` works with `xclip`, `wl-clipboard`, or similar tools.

## Troubleshooting

- **Clipboard capture fails**: install `xclip` or `wl-clipboard` so `modularnotes clip` can read the clipboard.
- **Project manager missing**: `modularnotes project` depends on `fzf`; install it through your package manager or the optional tools installer.
- **Permission errors**: ensure `~/Documents/ModularNotes` is writable by your user.

## Support

Enjoy ModularNotes? Support the ModularConfig Suite by buying a coffee at [https://www.buymeacoffee.com/justaguylinux](https://www.buymeacoffee.com/justaguylinux).
