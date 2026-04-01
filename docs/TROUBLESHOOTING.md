# Troubleshooting

## First steps

- Re-run with `--dry-run` and review the log:

```bash
./install.sh --dry-run --log /tmp/csi.log
less /tmp/csi.log
```

- If the installer appears to “skip” packages, check whether they are already installed (CSI intentionally skips installed packages).

## Package not found / missing in repos

CSI checks repository availability per package and will skip packages it can’t find.

What to do:

- Confirm you’re on the expected distro / repos are enabled.
- Search your distro’s package name and update `packages/pkg-list.txt` accordingly.
- If the name differs by distro, consider adding a mapping rule in `install.sh`.

## Package DB checks are slow or failing

Disable package database checks:

```bash
IGNORE_PKG_DB=1 ./install.sh --dry-run --yes
```

(Useful in CI, containers, or minimal environments.)

## Flatpak setup issues

- CSI follows the official Flatpak setup approach and adds Flathub to the **user** scope.
- If Flatpak isn’t available via your package manager, use the distro-specific steps:
  - https://flatpak.org/setup/

## VS Code setup

- Repo setup is currently wired for `apt`, `dnf`, and `zypper`.
- If `code` is already installed, CSI skips repository configuration.

## Vim-config step fails

The optional Vim step runs:

- `vim-config/depends.sh`
- `vim-config/install.sh`

If it fails:

- review the installer log to see which dependency or command failed
- try running those scripts directly to isolate the error

## Getting more detail

Use the trace harness:

```bash
tests/scripts/trace_dry_all_pm.sh
```

Or run with shell tracing manually:

```bash
bash -x ./install.sh --dry-run --yes --log /tmp/csi-trace.log
```
