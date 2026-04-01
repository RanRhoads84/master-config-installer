# Packages

CSI reads package groups from `packages/pkg-list.txt`.

## File format (`packages/pkg-list.txt`)

- Group headers are comment lines starting with `#`.
- Each non-empty, non-header line is a package name.

Example:

```text
# Shell Tools
bash
fzf
ripgrep

# Development Tools
git
make
```

The header text is the **group name** you select in the menu and must match `--groups` values.

## Package managers

The installer supports:

- `apt`
- `dnf`
- `pacman`
- `zypper`

You can override detection:

```bash
./install.sh --pm dnf
```

## Package name mapping

Some package names differ between distros. CSI includes lightweight mapping (currently for a few common tools), for example:

- On `apt`: `fd` → `fd-find`, `bat` → `batcat`
- On `dnf/pacman/zypper`: `fd-find` → `fd`

If you add packages that have different names across distros, you’ll typically need to extend the mapping logic in `install.sh`.

## Installed package detection

CSI tries to avoid reinstalling packages by checking the package DB:

- `apt`: `dpkg -s`
- `pacman`: `pacman -Qi`
- `dnf/zypper`: `rpm -q`

It also treats an existing command in `$PATH` as “installed” as a fallback.

To skip all package DB checks:

```bash
IGNORE_PKG_DB=1 ./install.sh --dry-run --yes
```

## Optional npm/cargo lists

If these files exist, CSI prompts to install them:

- `packages/npm.txt` — each line is passed to `npm install -g <pkg>`
- `packages/cargo.txt` — each line is passed to `cargo install <pkg>`

Both files ignore blank lines and `#` comments.
