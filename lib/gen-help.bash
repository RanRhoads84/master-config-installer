# Generic help message for config scripts
usage() {
  cat <<EOF
Usage: $0 [--dry-run] [--yes] [--log <file>] [--groups <list>]

Options:
  --dry-run        Print commands that would be run (no changes)
  --yes, -y        Assume yes to prompts
  --pm <name>      Override detected package manager (apt|dnf|pacman|zypper)
  --log <file>     Path to log file (default: ./modularconfig-install.log)
  --groups <list>  Comma-separated group names to select non-interactively
  -h, --help       Show this help
EOF
}