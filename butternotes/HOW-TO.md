# 🧈 ButterNotes - Complete HOW TO Guide

## Table of Contents
- [Getting Started](#getting-started)
- [Basic Usage](#basic-usage)
- [Notes Management](#notes-management)
- [Todo Management](#todo-management)
- [Project Management](#project-management)
- [Interactive Mode](#interactive-mode)
- [Aliases and Shortcuts](#aliases-and-shortcuts)
- [Configuration](#configuration)
- [Mobile Sync Setup](#mobile-sync-setup)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

---

## Getting Started

### First Run

After installation, start with the interactive mode:

```bash
butter
```

This launches the main interface where you can explore all features.

### Quick Start Commands

```bash
butter "My first note"           # Add a quick note
butter todo "Buy groceries"      # Add a todo
butter project myproject "Initial thoughts"  # Add to project
butter                          # Interactive mode
```

---

## Basic Usage

### Command Structure

ButterNotes follows a simple pattern:
```bash
butter [COMMAND] [ARGUMENTS...]
```

### Core Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `butter "text"` | Add note | `butter "Meeting notes from today"` |
| `butter add "text"` | Add note (explicit) | `butter add "Idea for project"` |
| `butter clip` | Save clipboard | `butter clip` |
| `butter todo "task"` | Add todo | `butter todo "Call dentist"` |
| `butter project name "text"` | Add to project | `butter project work "Review code"` |
| `butter` | Interactive mode | `butter` |

---

## Notes Management

### Adding Notes

```bash
# Quick note
butter "This is a quick note"

# Explicit add
butter add "This is another note"

# From clipboard
butter clip
```

### Viewing Notes

```bash
# List all notes
butter list

# In interactive mode
butter
> l
```

### Managing Notes

```bash
# Edit notes file directly
butter edit

# In interactive mode - go to notes section
butter
> n
```

#### Notes Sub-Commands (Interactive Mode)

When in notes mode (`butter` then `n`):

| Command | Action |
|---------|--------|
| `a` or `add` | Add new note |
| `l` or `list` | List all notes |
| `e` or `edit` | Edit notes file |
| `c` or `clip` | Save clipboard |
| `rm <numbers>` | Remove specific notes |
| `clear` | Delete all notes |
| `s` or `/` | Search notes |
| `..` | Back to main menu |

#### Removing Notes

```bash
# In notes interactive mode
> rm 3           # Remove note #3
> rm 1-5         # Remove notes 1 through 5
> rm 1 3 5       # Remove specific notes
> clear          # Delete all notes (with confirmation)
```

### Clipboard Integration

ButterNotes safely handles clipboard content:

```bash
butter clip
```

**Safety Features:**
- Detects binary data (images, files) and refuses to save
- 100KB size limit to prevent accidents
- Multi-line content properly formatted
- Cross-platform support (X11, Wayland, macOS)

---

## Todo Management

### Adding Todos

```bash
# Add a todo
butter todo "Complete the report"

# Alternative syntax
butter todo add "Call the client"
```

### Viewing Todos

```bash
# List all todos
butter todos
```

### Managing Todos

#### Mark Complete/Incomplete

```bash
# In interactive mode
butter
> t                # Enter todo mode
> d 1              # Mark todo #1 as done
> d 1              # Toggle back to incomplete
```

#### Remove Todos

```bash
# In todo interactive mode
> rm 2             # Remove todo #2 completely
> clear            # Remove all completed todos
```

#### Todo Sub-Commands (Interactive Mode)

When in todo mode (`butter` then `t`):

| Command | Action |
|---------|--------|
| `a` or `add` | Add new todo |
| `l` or `list` | List all todos |
| `d <number>` | Toggle todo done/undone |
| `rm <number>` | Remove todo completely |
| `clear` | Remove completed todos |
| `..` | Back to main menu |

### Todo Status Display

- ☐ Active todos (numbered)
- ☑ ~~Completed todos~~ (struck-through, with completion date)
- Summary: "5 active, 3 completed"

---

## Project Management

Projects provide organized spaces for structured documentation.

### Creating Projects

```bash
# Add note to project (creates if doesn't exist)
butter project myproject "Initial planning notes"

# Or use shortcut
butter p webdev "Setup webpack config"
```

### Project Manager (requires fzf)

```bash
# Launch interactive project manager
butter project
# or
butter p
```

**Project Manager Features:**
- 📝 Create new projects with template selection
- 🗑️ Delete existing projects
- Browse and edit projects with preview
- Keyboard shortcuts:
  - `Enter` - Edit selected project
  - `Ctrl-N` - New project
  - `Ctrl-D` - Delete project
  - `Tab` - Toggle preview
  - `Esc` - Exit

#### Project Templates

When creating a new project, you'll be prompted to choose a template:

**1. Blank (default)**
```markdown
# Project Name
```
Simple title with free-form content space. Perfect for stream-of-consciousness notes.

**2. Daily Log**
```markdown
# Project Name

## 2024-09-28

**Morning**
-

**Afternoon**
-

**Evening**
-

**Tomorrow**
-
```
Time-based structure for ongoing project tracking. Date is automatically filled.

**3. Simple List**
```markdown
# Project Name

-
-
-
-
-
```
Bullet point format ideal for brainstorming and quick capture lists.

### Project Commands

```bash
# View project contents
butter project myproject

# Edit project file
butter project myproject edit

# Delete project
butter project myproject rm

# List all projects
butter projects
```

### Project Sub-Commands (Interactive Mode)

When in projects mode (`butter` then `p`):

| Command | Action |
|---------|--------|
| `<project>` | View project notes |
| `<project> e` | Edit project file |
| `<project> rm` | Delete project |
| `l` | Launch project manager |
| `.` | Project manager (same as `l`) |
| `..` | Back to main menu |

---

## Interactive Mode

### Main Menu

```bash
butter
```

**Available commands:**
- `n` - Enter notes mode
- `t` - Enter todos mode
- `p` - Enter projects mode
- `l` - Quick list notes
- `lt` - Quick list todos
- `c` - Clear screen
- `q` - Quit

### Navigation

- Type `..` or `back` to go up one level
- Type `exit` or `quit` to leave any sub-mode
- Use `help` or `?` for command help

### Sub-Prompts

Each mode (notes, todos, projects) has its own prompt:

```bash
🧈 butter ❯                    # Main prompt
🧈 butter/notes ❯              # Notes mode
🧈 butter/todos ❯              # Todos mode
🧈 butter/projects ❯           # Projects mode
```

---

## Aliases and Shortcuts

### Default Aliases

If you installed aliases, these shortcuts are available:

| Alias | Command | Purpose |
|-------|---------|---------|
| `b` | `butter` | Main interactive mode |
| `bc` | `butter clip` | Save clipboard |
| `bt` | `butter todo` | Add todo |
| `bp` | `butter project` | Project manager |
| `bn` | `butter` | ButterNotes shorthand |
| `butternotes` | `butter` | Full name |
| `n` | `butter add` | Quick note |
| `nl` | `butter list` | List notes |
| `t` | `butter todo` | Quick todo |
| `tl` | `butter todos` | List todos |
| `p` | `butter project` | Quick project |
| `pl` | `butter projects` | List projects |

### Usage Examples

```bash
b                              # Interactive mode
n "Quick thought"              # Add note
nl                            # List notes
t "Remember to call mom"       # Add todo
tl                            # List todos
p work "Review pull requests"  # Add to work project
pl                            # List projects
bc                            # Save clipboard
```

---

## Configuration

### Config File Location

`~/.config/butternotes/butter.conf`

### Default Configuration

```bash
#!/bin/bash
# ButterNotes Configuration

# Notes directory - change this to sync with mobile apps
BUTTER_NOTES_DIR="/home/user/Documents/ButterNotes"

# File names with .md extension for mobile compatibility
NOTES_FILE="$BUTTER_NOTES_DIR/notes.md"
TODOS_FILE="$BUTTER_NOTES_DIR/todos.md"

# Legacy paths (for migration)
LEGACY_NOTES_FILE="$HOME/.notes"
LEGACY_TODOS_FILE="$HOME/.tasks"

# Editor preference
BUTTER_EDITOR="${BUTTER_EDITOR:-${EDITOR:-nano}}"

# Create notes directory if it doesn't exist
mkdir -p "$BUTTER_NOTES_DIR"
```

### Customizing Storage Location

Edit the config file to change where notes are stored:

```bash
# For Nextcloud sync
BUTTER_NOTES_DIR="$HOME/Nextcloud/Notes"

# For Dropbox sync
BUTTER_NOTES_DIR="$HOME/Dropbox/Notes"

# For custom location
BUTTER_NOTES_DIR="/path/to/your/notes"
```

### Editor Configuration

Set your preferred editor:

```bash
# In your shell config or butter.conf
export BUTTER_EDITOR="code"     # VS Code
export BUTTER_EDITOR="nvim"     # Neovim
export BUTTER_EDITOR="micro"    # Micro editor
```

---

## Mobile Sync Setup

ButterNotes uses standard markdown files for mobile compatibility.

### File Structure

```
~/Documents/ButterNotes/
├── notes.md              # Main notes file
├── todos.md              # Todos file
└── projects/             # Project files
    ├── work.md
    ├── personal.md
    └── ideas.md
```

### Mobile App Recommendations

**Android:**
- **Markor** - Excellent markdown support, sync-friendly
- **Obsidian** - Powerful for project management
- **Nextcloud Notes** - If using Nextcloud sync

**iOS:**
- **1Blocker** - Good markdown editor
- **Obsidian** - Cross-platform consistency
- **Working Copy** - If using Git sync

### Sync Methods

#### Method 1: Cloud Storage
```bash
# Point to cloud directory
BUTTER_NOTES_DIR="$HOME/Dropbox/Notes"
BUTTER_NOTES_DIR="$HOME/Nextcloud/Notes"
BUTTER_NOTES_DIR="$HOME/OneDrive/Notes"
```

#### Method 2: Git Sync
```bash
# Initialize git in notes directory
cd ~/Documents/ButterNotes
git init
git remote add origin https://github.com/yourusername/notes.git

# Create sync script
cat > sync.sh << 'EOF'
#!/bin/bash
cd ~/Documents/ButterNotes
git add .
git commit -m "Update notes $(date)"
git pull --rebase
git push
EOF
```

#### Method 3: Symlinks
```bash
# Link to existing cloud directory
ln -s ~/Dropbox/Notes ~/Documents/ButterNotes
```

---

## Desktop Integration

### Keyboard Shortcuts for Instant Capture

Bind ButterNotes commands to keyboard shortcuts for lightning-fast note capture:

```bash
# GNOME/KDE: System Settings > Keyboard > Custom Shortcuts
# Command: butter clip && notify-send "📋 Clipboard saved to notes"
# Suggested key: Super+Shift+V

# Alternative commands for different shortcuts:
butter clip && notify-send "Note saved" "Clipboard content added"
butter && notify-send "ButterNotes" "Interactive mode launched"

# For quick todo capture:
# Command: zenity --entry --text="Add todo:" | xargs -I {} butter todo "{}"
# Suggested key: Super+Shift+T
```

### Window Manager Integration

```bash
# sxhkd config (~/.config/sxhkd/sxhkdrc):
super + shift + v
    butter clip && notify-send "Note saved"

super + shift + n
    butter && notify-send "ButterNotes launched"

super + shift + t
    rofi -dmenu -p "Todo:" | xargs -I {} butter todo "{}"

# i3wm/sway config example:
bindsym $mod+Shift+n exec butter clip && notify-send "Note saved"
bindsym $mod+Shift+t exec "zenity --entry --text='Todo:' | xargs -I {} butter todo '{}'"

# For rofi users:
echo "butter" | rofi -dmenu -p "Note:" | xargs butter
```

---

## Advanced Usage

### Search and Filtering

```bash
# Search notes (interactive mode)
butter
> n
> s searchterm

# Basic search functionality
# (Note: advanced search features not yet implemented)
```

### Batch Operations

```bash
# Remove multiple notes
butter
> n
> rm 1-5        # Remove notes 1 through 5
> rm 1 3 5      # Remove specific notes
```

### Project Organization

```bash
# Organize by topics
butter project work "Meeting notes"
butter project personal "Birthday ideas"
butter project ideas "App concept"

# Use consistent naming
butter project 2024-project "Status update"
butter project client-acme "Requirements discussion"
```

### Integration with Other Tools

```bash
# Pipe output to other commands
butter list | grep "important"

# Use in scripts
echo "Daily standup notes" | butter add

# Combine with system tools
butter project logs "$(date): System backup completed"
```

### Custom Workflows

#### Daily Notes
```bash
# Create daily note function
daily() {
    butter project daily "$(date '+%Y-%m-%d'): $*"
}

daily "Started new feature development"
```

#### Meeting Notes
```bash
# Meeting note template
meeting() {
    local title="$1"
    shift
    butter project meetings "$title - $(date '+%Y-%m-%d %H:%M'): $*"
}

meeting "Team Standup" "Discussed sprint goals"
```

---

## Troubleshooting

### Common Issues

#### Command not found: butter
```bash
# Check if ~/.local/bin is in PATH
echo $PATH | grep ~/.local/bin

# If not, add to your shell config
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Notes not saving
```bash
# Check permissions
ls -la ~/.config/butternotes/
ls -la ~/Documents/ButterNotes/

# Check config
cat ~/.config/butternotes/butter.conf
```

#### fzf not working
```bash
# Install fzf for project management
# Ubuntu/Debian
sudo apt install fzf

# Or from source
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

#### Clipboard integration not working
```bash
# Install clipboard tools
# X11 systems
sudo apt install xclip

# Wayland systems
sudo apt install wl-clipboard

# Verify clipboard access
echo "test" | xclip -selection clipboard
xclip -selection clipboard -o
```

### Migration Issues

#### From old ~/.notes format
```bash
# ButterNotes automatically migrates on first run
# But you can check manually
cat ~/.notes            # Old format
cat ~/Documents/ButterNotes/notes.md  # New format
```

#### Changing storage location
```bash
# Edit config file
nano ~/.config/butternotes/butter.conf

# Move existing files
mv ~/Documents/ButterNotes/* ~/new/location/
```

### Performance

#### Large notes files
If notes files become very large (>1000 entries):

```bash
# Archive old notes
cd ~/Documents/ButterNotes
cp notes.md "notes-archive-$(date +%Y-%m).md"
echo "# Notes" > notes.md

# Same for todos
cp todos.md "todos-archive-$(date +%Y-%m).md"
echo "# Todos" > todos.md
```

### Getting Help

```bash
# Built-in help
butter help

# Interactive help
butter
> help

# Sub-command help
butter
> n
> help
```

### Reporting Issues

If you encounter bugs or have feature requests:

1. Check existing issues: https://codeberg.org/justaguylinux/butternotes/issues
2. Include your system info:
   ```bash
   echo "OS: $(uname -a)"
   echo "Shell: $SHELL"
   echo "ButterNotes version: $(head -5 ~/.local/bin/butter)"
   ```

---

## Tips and Best Practices

### Organization
- Use consistent project naming conventions
- Keep inbox (main notes) for quick capture only
- Move important notes to dedicated projects
- Regular cleanup of completed todos

### Workflow
- Start your day by reviewing todos: `butter todos`
- Quick capture thoughts: `n "idea here"`
- End sessions by organizing: move notes to projects
- Use clipboard feature for copy-paste from web/documents

### Sync Strategy
- Choose one sync method and stick to it
- Test mobile access before relying on it
- Keep backups of important project files
- Use descriptive project names for mobile browsing

---

*Last updated: 2025-09-28*
*ButterNotes version: Latest*