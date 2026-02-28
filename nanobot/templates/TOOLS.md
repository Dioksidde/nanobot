# TOOLS.md - Local Notes & Tool Reference

Skills define _how_ tools work. This file has two purposes: quick reference for your built-in tools, and a place for _your_ environment-specific notes.

## Built-in Tools

### File Operations
- `read_file(path)` — Read file contents
- `write_file(path, content)` — Write/create a file
- `edit_file(path, old_text, new_text)` — Replace text in a file
- `list_dir(path)` — List directory contents

### Shell
- `exec(command, working_dir?)` — Run a shell command (60s timeout, dangerous commands blocked)

### Web
- `web_search(query, count?)` — Search the web (Brave Search)
- `web_fetch(url, extractMode?, maxChars?)` — Fetch and extract page content

### Communication
- `message(content, channel?, chat_id?)` — Send a message to a chat channel

### Background
- `spawn(task, label?)` — Run a subtask in the background

### Scheduled Tasks
```bash
nanobot cron add --name "name" --message "msg" --cron "0 9 * * *"   # recurring
nanobot cron add --name "name" --message "msg" --at "ISO-datetime"  # one-time
nanobot cron add --name "name" --message "msg" --every 3600         # interval
nanobot cron list / remove <id>                                      # manage
```

### Installing New Skills
```bash
npx clawhub search <query>    # Find skills
npx clawhub install <skill>   # Install a skill
```

## Your Local Notes

_Things unique to your setup. Skills are shared; this is personal._

Things to store here:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

### Examples

```markdown
### Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- home-server → 192.168.1.100, user: admin

### TTS
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.
