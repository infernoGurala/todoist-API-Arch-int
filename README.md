# Todoist Desktop Notifications for Linux

A bash script that brings Todoist task notifications directly to your Linux desktop with synchronized alerts across devices. Get real-time notifications for today's and upcoming tasks with quick-action buttons.

## Features

- 📱 **Desktop Notifications** - Native Linux desktop alerts for all tasks
- ✅ **One-Click Task Completion** - Mark tasks done directly from the notification
- ⏰ **Smart Time Display** - Converts task times to readable 12-hour format
- 🔔 **Scheduled Alerts** - Additional reminder at task due time
- 🔄 **Background Processing** - Multiple notifications run independently
- 📊 **Task Filtering** - Shows only today's and upcoming tasks
- 🎯 **Hyprland Integration** - Auto-run at login with Hyprland window manager

## Prerequisites

Before setting up this script, ensure you have the following installed:

### Required Tools

- **bash** - Shell interpreter (usually pre-installed)
- **todoist-cli** - Official Todoist command-line tool
- **notify-send** - Desktop notification daemon (part of `libnotify`)
- **at** - Task scheduling daemon

### Installation

#### On Arch Linux / Manjaro

```bash
sudo pacman -S libnotify at todoist-cli
sudo systemctl enable atd
sudo systemctl start atd
```

#### On Ubuntu / Debian

```bash
sudo apt install libnotify-bin at todoist-cli
sudo systemctl enable atd
sudo systemctl start atd
```

#### On Fedora / RHEL

```bash
sudo dnf install libnotify at todoist-cli
sudo systemctl enable atd
sudo systemctl start atd
```

## Setup Instructions

### Step 1: Get Your Todoist API Token

1. Visit [Todoist App](https://app.todoist.com/app/settings/integrations)
2. Go to **Settings** → **Integrations** → **Developer**
3. Copy your **API Token**
4. Save it safely - you'll need it next

### Step 2: Configure Todoist CLI

Set up the Todoist CLI with your API token:

```bash
todoist login
# Paste your API token when prompted
```

Test the connection:

```bash
todoist list
```

If you see your tasks, you're all set!

### Step 3: Place the Script

Create a dedicated directory for the script (optional but recommended):

```bash
mkdir -p ~/.local/bin
```

Copy the script to your preferred location:

```bash
cp notify_tasks.sh ~/.local/bin/notify_tasks.sh
chmod +x ~/.local/bin/notify_tasks.sh
```

Or place it directly in your home folder:

```bash
cp notify_tasks.sh ~/notify_tasks.sh
chmod +x ~/notify_tasks.sh
```

### Step 4: Configure Auto-Start (Hyprland)

If you're using **Hyprland** as your window manager, add this line to your Hyprland config:

```bash
# ~/.config/hyprland/hyprland.conf
exec-once = ~/.local/bin/notify_tasks.sh
```

Or if you placed it in your home folder:

```bash
exec-once = ~/notify_tasks.sh
```

**For other window managers:**

**GNOME / GNOME Shell:**
Add to your startup applications or place the script in `~/.config/autostart/`

**KDE Plasma:**
Go to **System Settings** → **Autostart** and add the script

**i3wm / Openbox:**
Add to your `.i3/config` or `.config/openbox/autostart`

```bash
exec ~/notify_tasks.sh
```

**Systemd User Service** (Universal approach):

Create `~/.config/systemd/user/todoist-notify.service`:

```ini
[Unit]
Description=Todoist Desktop Notifications
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=%h/.local/bin/notify_tasks.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

Then enable it:

```bash
systemctl --user enable todoist-notify.service
systemctl --user start todoist-notify.service
```

## How It Works

```
Script Execution Flow
│
├─ Fetch today's and upcoming tasks from Todoist API
│
├─ For each task (runs in parallel):
│  ├─ Extract: Task ID, Time, Name
│  ├─ Convert time to user-friendly format (12-hour)
│  ├─ Show notification with ✅ DONE button
│  └─ If DONE clicked → Mark task complete in Todoist
│
└─ Schedule additional reminder at task due time
```

### Example Task Flow

1. **Script runs** → Queries Todoist for `today | upcoming` tasks
2. **Notification appears** → Shows "⏰ 2:30 PM - Buy groceries"
3. **User clicks DONE** → Task marked complete in Todoist
4. **Confirmation** → ✅ feedback shown

## Configuration & Customization

### Modify Task Filters

Edit the `RAW_DATA` line to change which tasks appear:

```bash
# Current: today and upcoming
RAW_DATA=$(todoist list -f "today | upcoming")

# Alternative filters:
RAW_DATA=$(todoist list -f "today")           # Only today's tasks
RAW_DATA=$(todoist list -f "upcoming")        # Only upcoming tasks
RAW_DATA=$(todoist list -f "@high")           # Only high priority
RAW_DATA=$(todoist list -f "p1")              # Only priority 1
```

### Change Notification Title

Modify the notification title or emoji:

```bash
# Default
notify-send -a "Todoist" "⏰ $FRIENDLY_TIME" "$TASK_NAME"

# Custom (e.g., for dark mode preference)
notify-send -a "My Tasks" "📋 $FRIENDLY_TIME" "$TASK_NAME"
```

### Adjust Urgency Level

Change the `--hint` parameter for more prominent alerts:

```bash
# For critical tasks
notify-send -u critical "⏰ $FRIENDLY_TIME" "$TASK_NAME"

# For normal tasks (default)
notify-send -u normal "⏰ $FRIENDLY_TIME" "$TASK_NAME"
```

## Troubleshooting

### Issue: "todoist: command not found"

**Solution:** Install todoist-cli:
```bash
# Arch
sudo pacman -S todoist-cli

# Ubuntu/Debian
sudo apt install todoist-cli

# Fedora
sudo dnf install todoist-cli
```

Then configure: `todoist login`

### Issue: Notifications don't appear

**Possible causes and fixes:**

1. **notify-send not installed:**
   ```bash
   sudo pacman -S libnotify  # Arch
   sudo apt install libnotify-bin  # Ubuntu
   ```

2. **Notification daemon not running:**
   ```bash
   # Check if daemon is active
   systemctl --user status notify-daemon
   
   # Start if not running
   systemctl --user start notify-daemon
   ```

3. **Hyprland config not reloaded:**
   - Press `Super+Shift+R` to reload Hyprland config
   - Or restart Hyprland session

### Issue: "at: command not found"

**Solution:** Install and start the `at` daemon:

```bash
# Install
sudo pacman -S at  # Arch
sudo apt install at  # Ubuntu

# Enable and start
sudo systemctl enable atd
sudo systemctl start atd
```

### Issue: Tasks not fetching / API errors

**Debugging steps:**

```bash
# Test your API token
todoist list

# If error, re-login
todoist login

# Check if script has execute permissions
ls -l notify_tasks.sh
chmod +x notify_tasks.sh
```

### Issue: Scheduled alerts (at) not working

**Check if atd is running:**

```bash
sudo systemctl status atd

# If not active, start it
sudo systemctl start atd
sudo systemctl enable atd
```

**View scheduled jobs:**
```bash
atq
```

**Remove a scheduled job:**
```bash
atrm <job_number>
```

### Issue: Tasks show but can't click DONE button

**Verify todoist-done wrapper exists:**

```bash
# Create a wrapper if missing
mkdir -p ~/.local/bin
cat > ~/.local/bin/todoist-done << 'EOF'
#!/bin/bash
todoist close "$1"
notify-send -a "Todoist" "✅ Task Complete" "$2 marked as done!"
EOF

chmod +x ~/.local/bin/todoist-done
```

Ensure this is in your `$PATH`:
```bash
echo $PATH | grep .local/bin
```

If not, add to `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Advanced Usage

### Run on Demand

Execute the script manually anytime:

```bash
~/.local/bin/notify_tasks.sh
```

### Run Every 5 Minutes (with Cron)

Edit your crontab:

```bash
crontab -e
```

Add this line:

```cron
*/5 * * * * ~/.local/bin/notify_tasks.sh
```

This checks for new tasks every 5 minutes.

### Integrate with Other Tools

**With i3blocks (status bar):**

```bash
# ~/.config/i3blocks/config
[todoist]
command=todoist list -f "today" | wc -l
interval=300
```

**With Polybar:**

```ini
[module/todoist]
type = custom/script
exec = todoist list -f "today" | wc -l
interval = 300
label = "📋 %output% tasks"
```

## Mobile Sync

Todoist automatically syncs across devices:

1. **Install Todoist on mobile** - Get the official app from Play Store / App Store
2. **Log in with same account** - Use your Todoist credentials
3. **Notifications auto-sync** - Changes on desktop reflect immediately on mobile and vice versa

**Note:** Mobile notifications are handled by the official Todoist app. This script provides additional Linux desktop notifications.

## Performance Tips

- **Large task list?** Filter by priority: `-f "p1 | p2"`
- **Reduce CPU usage:** Increase cron interval to `*/10 * * * *` (every 10 mins)
- **Disable scheduled alerts:** Comment out the `at` command if you only want initial notification
- **Clean up old jobs:** Run `atq` and `atrm` periodically

## Security Notes

- **API Token:** Keep your Todoist API token private. Never share scripts with tokens hardcoded.
- **Permissions:** The script only reads and marks tasks complete - it cannot delete tasks.
- **Local storage:** API token is stored locally by todoist-cli in `~/.config/todoist/token`

## Contributing

Found a bug or have an improvement? Feel free to submit issues or pull requests!

## License

This project is open source and available under the MIT License.

## Support

For issues with:

- **Todoist CLI** → [Todoist GitHub](https://github.com/todoist/todoist-cli)
- **Hyprland** → [Hyprland Documentation](https://wiki.hyprland.org)
- **This script** → Check troubleshooting section above

---

**Happy tasking! 🚀**
