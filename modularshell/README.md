![Made for Debian](https://img.shields.io/badge/Made%20for-Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)

# 🧈 ModularShell

A smooth, modular Bash configuration framework that makes your shell experience butter-smooth. ModularShell now lives inside the ModularConfig Suite (CSI) optional toolset so you can install it alongside the other helper modules without manually cloning another repository.

## ✨ Features

- **Modular Design**: Clean separation of concerns with individual files for aliases, functions, and prompt modules.
- **FZF Integration**: Fuzzy finding for files and processes.
- **Git-Aware Prompt**: Shows the current branch and status in your prompt.
- **Extensive Aliases**: Productivity shortcuts for common tasks.
- **Archive Extraction**: Universal `extract` helper for every archive format.
- **System Functions**: Quick system info, colored man pages, and more.
- **Extension Ready**: Works seamlessly with [ModularNotes](../modularnotes/README.md) for note-taking and todo management.

## 📦 Installation

### Recommended: Install via ModularConfig Suite

The ModularConfig Suite optional tools menu (`setup/optional_tools.sh`) features ModularShell as its prioritized shell configuration helper. Run the installer and pick **ModularShell** from the helper list:

```bash
./setup/optional_tools.sh
# Choose the ModularConfig helper menu and select "ModularShell".
```

This path ensures the installer runs inside the repo and keeps the `modularshell` directory in sync with the suite.

### Direct Install

If you prefer to install from the workspace directly:

```bash
cd modularshell
./install.sh
source ~/.bashrc
```

The installer backs up your existing `~/.bashrc` before replacing it, so you can restore your launcher if needed.

### Manual Page

After installation, you can read the manual page with:

```bash
man modularshell
```

## 🗂️ Structure

```
~/.config/bash/
├── aliases.bash        # Command shortcuts
├── libs/               # Shared color helpers
├── prompt.bash         # Custom prompt with git branch
├── keybinds.bash       # Keyboard shortcuts
├── fzf.bash            # FZF configuration
└── functions/
    ├── system.bash     # System utilities
    └── utils.bash      # General utilities
```

## 🎯 Core Functions

### Utility Functions
```bash
mkcd directory        # Create and enter directory
extract file.tar.gz   # Extract any archive type
backup file.txt       # Create timestamped backup
calc 2+2             # Quick calculations
sysinfo              # Display system information
```

## ⚙️ Configuration

### Customization

Drop custom files into `~/.config/bash/`:

1. Create a module: `~/.config/bash/custom.bash`
2. It is automatically sourced the next time a shell starts.

### Local Overrides

Create `~/.bashrc.local` for machine-specific tweaks:

```bash
# ~/.bashrc.local
export CUSTOM_VAR="value"
alias myalias="command"
```

### Integration with ModularConfig Suite

ModularShell works seamlessly with the modular helpers in this workspace:

- **ModularNotes** – A modular note-taking and todo manager located at [../modularnotes/README.md](../modularnotes/README.md).
- **Other CSI modules** – The optional tools menu can fetch external helper bundles (fastfetch, browsers, editors) and theming assets without duplication.

## 🚀 Key Bindings

- **Ctrl+L**: Clears the terminal.
- **↑ / ↓**: Searches command history.
- **Ctrl+R**: Reverse history search (FZF integration if available).

## 📋 Requirements

- Bash 4.0+
- Optional helpers: `fzf`, `ripgrep`, `eza`/`exa`, `xclip`/`wl-clipboard`

Install optional helpers with the built-in `install_tools` function.

## 🤝 Contributing

Contributions and fixes can be made inside this repository:

1. Fork `master-config-installer`.
2. Create a feature branch.
3. Test with `./modularshell/install.sh`.
4. Submit a pull request describing the change.

## 📝 License

MIT

## 🙏 Acknowledgments

- Inspired by dotfile repositories and modular shell builders.
- Built with love for terminal-first workflows.

## ☕ Support

If ModularShell has been helpful, consider buying me a coffee:

[![Buy me a coffee](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/justaguylinux)

Made with 🧈 by [JustAGuyLinux](https://www.youtube.com/@justaguylinux)
