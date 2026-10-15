# AI Subscription Usage feed

An optional add-on for the Cyberpunk Wallpaper, which can draw your AI
subscription's usage limits as segmented bars in its right gutter (see the wallpaper
settings, "AI subscription usage"). This folder holds the part that supplies the numbers.
The main package never builds or installs it, and nothing here is enabled by default.

The wallpaper makes no network calls and reads no credentials for this. It only reads
small JSON files that providers write to `~/.local/state/ai-usage/`, one file per
provider, one line each:

```
{"provider":"Claude","updated":1792019246,"windows":[
 {"label":"Session","used":23.5,"resets_at":1792027046},
 {"label":"Weekly","used":91.2,"resets_at":1792279246}]}
```

`updated` and `resets_at` are Unix seconds, `used` is 0 to 100. Any script can write a file
like this, which is how another provider can be added.

## What the wallpaper shows

A block two grid squares tall above the CPU readings: the provider, then for up to two
windows the label, time until reset and percent, and 20 segments worth 5% each. The bars
use the normal, warning and critical colors (defaults: secondary color, accent color and
red `#ff003c`) from the 70% and 90% thresholds; both thresholds and all three colors are
settings. A window whose reset time has passed shows as reset (0%), and a reading older
than 30 minutes is dimmed and labeled with its time, so it never looks fresher than it is.
Only the first provider is shown. The login screen cannot show it, because the login
manager cannot read your home folder.

## Claude Code

Claude Code's documented status line receives `rate_limits` (session and weekly
percentages and reset times) on stdin for Pro and Max plans. The included
`ai-usage-claude-statusline` command saves them. Set it in `~/.claude/settings.json`:

```
"statusLine": { "type": "command", "command": "ai-usage-claude-statusline" }
```

To keep a status line you already have, pass its command after ours; it receives the same
input and its output is shown:

```
"command": "ai-usage-claude-statusline my-status-command"
```

Limits of this route: the numbers update only while Claude Code runs and has made a
request, so usage from other apps is not seen until then; and per-model weekly limits are
not provided to the status line.

## Install

```
sudo pacman -S --needed git base-devel
cd ~
rm -rf cyberpunk-wallpaper
git clone https://github.com/CausticCatastrophe/cyberpunk-wallpaper
cd cyberpunk-wallpaper/usage
makepkg -si
cd ~
rm -rf cyberpunk-wallpaper
```

It asks for your password (typing shows nothing; press Enter when done) and, if asked to proceed,
press Enter. The last two lines delete the downloaded files.

Remove it with `sudo pacman -Rns ai-subscription-usage`. The files it wrote stay in
`~/.local/state/ai-usage`; delete that folder if you no longer want them, and take the
`statusLine` entry out of `~/.claude/settings.json`.
