# Cyberpunk Splash

A cyberpunk-style KDE Plasma 6 splash screen for Arch-based systems. It is
driven by Plasma's startup `stage` (0 to 6): a boot log fills in, a segmented
progress bar advances, and the title glitches. Optional CRT effects sit on top.

System details (OS, kernel, hostname, Plasma and Qt versions) and all settings are
written into the theme by a small stamp script, so the splash itself never
reads files at runtime.

## Live preview

**[Try it in your browser](https://causticcatastrophe.github.io/cyberpunk-splash/)**
(animated, with every color and effect option, and a generator for the config
file). The page is a browser approximation of the QML theme; the source is in
`docs/index.html`.

## Screenshots

Default (`ACCENT=yellow`, `SECONDARY=cyan`):

![Yellow accent](docs/screenshots/cyberpunk-yellow.png)

`ACCENT=blue`, `SECONDARY=magenta`:

![Blue accent](docs/screenshots/cyberpunk-blue.png)

Stills captured at stage 5 with sample system values (not a real machine). The glitch, tear and
roll effects are animated and only show while it runs.

## Install

Requires Plasma 6 (`plasma-workspace`) and the `base-devel` and `git`
packages to build.

```
cd "$(mktemp -d)"
git clone https://github.com/CausticCatastrophe/cyberpunk-splash
cd cyberpunk-splash
makepkg -si
```

This builds in a temporary directory, so nothing is left in your home folder.
`makepkg` clones the repo again as its build source, builds the package, and
`-si` installs it with pacman (it asks for your sudo password). The install
hook stamps the theme with your system details.

When it finishes, remove the clone (or just let a reboot clear `/tmp`):

```
cd .. && rm -rf cyberpunk-splash
```

To update later, repeat the same steps with a fresh clone.

After installing, open System Settings, Colors & Themes, Splash Screen, and
choose **Cyberpunk Splash**.

Fonts are bundled under the SIL Open Font License, so no font packages are
needed: Rajdhani and Share Tech Mono for the interface, plus Oxanium, Chakra Petch
and Tektur as title and tagline alternates (see `theme/contents/splash/fonts/NOTICE.txt`).

## Configure

Edit the installed config, then re-stamp:

```
sudoedit /etc/cyberpunk-splash.conf
sudo cyberpunk-splash-stamp
```

| Setting | Values | Effect |
|---|---|---|
| `TITLE` | text | Big title on the splash |
| `TAGLINE` | text | Line under the title |
| `TITLE_FONT` | font family name, or empty | Font for the title: a bundled one (`Oxanium`, `Chakra Petch`, `Tektur`) or any installed font. Empty uses Rajdhani. See "Using your own title font" |
| `TAGLINE_FONT` | font family name, or empty | Font for the line under the title, chosen independently. Same choices |
| `TITLE_FONT_SCALE` | 50 to 150 | Title size for that font, in percent |
| `USER_NAME` | text, or empty | Shows "WELCOME BACK, NAME" on the last stage. Empty hides it |
| `ACCENT` | name or `#rrggbb` | Main color: HUD, bars, brackets, log markers |
| `SECONDARY` | name or `#rrggbb` | Glitch flashes and some log markers |
| `GLITCH_TITLE` | yes / no | Colored slices flashing across the title |
| `CRT_TEAR` | yes / no | A strip of the screen jumps sideways, frame jitters |
| `CRT_ROLL` | yes / no | Faint light band scrolling down the screen |
| `CRT_FLICKER` | yes / no | Brief brightness dips |
| `SCANLINES` | yes / no | Scanlines over the whole splash |
| `KERNEL_PKGBASE` | e.g. `linux-cachyos`, or empty | Which installed kernel to show. Empty shows the newest |

Color names: yellow, cyan, blue, red, magenta, pink, green, teal, lime,
orange, amber, violet, ice, white.
Invalid colors fall back to the defaults. Values are reduced to a safe
character set before they are written into QML.

The copy of `cyberpunk-splash.conf` in this repo is only the package default.
Editing it changes the next build, not an installed system.
`/etc/cyberpunk-splash.conf` is a pacman backup file, so upgrades keep your
edits and write new defaults to `cyberpunk-splash.conf.pacnew`.

## What the labels show

| Where | Text | Source |
|---|---|---|
| Top left | OS name // hostname | Stamped from `/etc/os-release` and the hostname |
| Top right | Kernel version | Stamped from the installed kernel modules |
| Bottom left | Plasma version | Stamped from the `plasma-workspace` package |
| Bottom right | Qt version // session | Qt version stamped from `qt6-base`; session (Wayland or X11) read live |
| Center | Title and tagline | `TITLE` and `TAGLINE` in the config |
| Progress bar | Startup step and `STAGE n/6` | Plasma's startup stage, read live |
| Progress label, last stage | "WELCOME BACK, NAME" | `USER_NAME` in the config |

A label is hidden when its value is empty, so an unstamped theme never shows
placeholder text.

## Title and tagline fonts

Three alternates ship with the theme, all under the SIL Open Font License:
**Oxanium** (clipped, angular corners), **Chakra Petch** (chamfered, military-tech)
and **Tektur** (notched cut-out shapes). Set `TITLE_FONT` and `TAGLINE_FONT` to a
name, or pick them from the font dropdowns on the wallpaper settings page, where
the bundled fonts are listed first. The title and tagline have separate fonts. A
wide title font shrinks automatically to fit the middle 60% of the screen, so it
never runs into the side columns, and the tagline follows it up.

## Using your own title font

The title can use any font installed on your machine. Fonts you download from
other sites often come with licenses that forbid redistribution, so this project
only bundles fonts under the SIL Open Font License and does not ship others. Get
the font yourself and check its license, then install it and set `TITLE_FONT`.

Find the exact family name Qt will see:

```
fc-list | grep -i <part of the name>
```

- **Splash, desktop and lock screen** run as your user, so a font in your home
  folder is enough: copy the file to `~/.local/share/fonts/` and run `fc-cache`.
- **Login screen still** is drawn by the stamp script as root, which cannot see
  your home folder. Install the font system-wide too, for example in
  `/usr/local/share/fonts/`, and run `sudo fc-cache`.

Then set `TITLE_FONT` (use the family name exactly as `fc-list` shows it) and,
since display fonts often run wide or narrow, adjust `TITLE_FONT_SCALE`. Run
`sudo cyberpunk-splash-stamp` to apply. If the font is missing or the name is
wrong, the title falls back to Rajdhani. Letters the font lacks are drawn from a
fallback font, so check that it covers your title.

## Login screen wallpaper

Every time the stamp runs it also renders a matching wallpaper for the Plasma
Login Manager from your `TITLE`, `TAGLINE`, `ACCENT` and `SECONDARY`, and
writes it to `/var/lib/plasmalogin/wallpapers/cyberpunk-splash.png`. Set
`LOGIN_WALLPAPER=no` to skip it. Rendering is offscreen and needs no display;
if it fails, the stamp still succeeds.

One-time setup: point the login screen at that file. In System Settings open
Login Screen and choose the wallpaper image, or set it in
`/etc/plasmalogin.conf`:

```
[Greeter][Wallpaper][org.kde.image][General]
Image=file:///var/lib/plasmalogin/wallpapers/cyberpunk-splash.png
```

The login manager draws its own clock, user picker and password box over the
wallpaper, and their layout is fixed. Two settings keep the wallpaper out of
their way:

| Setting | Values | Effect |
|---|---|---|
| `LOGIN_TITLE` | yes / no | Show or hide the title and tagline |
| `LOGIN_TITLE_Y` | 0 to 80 (default 40) | Title position, as a percent of the screen height from the top. The default sits below the login and lock clock; lower it to move the title up |

To hide the login clock itself, untick "Show clock" on the Login Screen page
in System Settings. It is stored as `ShowClock` in `/etc/plasmalogin.conf`.

After that, any config change plus `sudo cyberpunk-splash-stamp` updates the
login screen on its next appearance. To render a wallpaper by hand without
installing, run `wallpaper/render OUT.png [ACCENT] [SECONDARY]` from the repo.

## Lock screen wallpaper

The same image is also installed as a regular Plasma wallpaper named
**Cyberpunk Splash** in `/usr/share/wallpapers/CyberpunkSplash/`, and the stamp
refreshes it together with the login wallpaper. The login copy lives in a
folder only the login manager can read, so use this one for your own session.

To use it on the lock screen: System Settings, Colors & Themes, Screen
Locking, Appearance, Configure, then choose **Cyberpunk Splash**. Or from a
terminal:

```
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper \
    --group org.kde.image --group General --key Image \
    file:///usr/share/wallpapers/CyberpunkSplash
```

It also shows up in the desktop wallpaper picker. The lock screen draws its own
clock over the image, like the login screen, so `LOGIN_TITLE_Y` and
`LOGIN_TITLE` apply to both.

## Animated wallpaper and per-screen designs

The package also installs a Plasma wallpaper plugin, **Cyberpunk Splash
(Animated)**. Pick it as the Wallpaper type for any screen, or for the lock
screen, and choose a **Style** in its settings. Each monitor and the lock
screen keep their own choice, so each can use a different design.

| Style | What it is | GPU cost |
|---|---|---|
| Data terminal | Host and OS block, a log of real readings, hex columns | about 0.4 points of GPU |
| Hex columns | Hex data down both sides | near zero |
| Terminal | Log in the corner, status block | near zero |
| Classic | Drifting grid, glitch, CRT tear, roll and flicker | high |

Every style shows a clock you can hide or switch to 24-hour time in the same
settings page. It redraws once a minute.

**Per-screen settings.** The same settings page has, for each screen and for the
lock screen separately: the title font (a list of every installed font), title
size, position and text, tagline text, accent and secondary colors, which log
lines to show, how often to read, and the sparkline step and length. Anything
left at **Default** uses the value from `/etc/cyberpunk-splash.conf`, so the config
file sets the baseline and a screen can override just the parts it wants. The log
list on that page uses a fixed order; the config file can use any order. Classic
reads only the config file.

**Bottom margin.** If a panel runs along the bottom of a screen, set **Bottom
margin** on that screen (about 4 to 5 percent clears a typical taskbar). The log,
the bottom corner brackets and the hex columns lift by that much so the panel does
not cover them. It is per screen, so a screen without a panel and the lock screen
stay at None. With a margin, the log reaches higher, so you may also want to move
the title up with **Title position** on that screen (about 30 to 33 percent).

**Why the cost differs.** Measured with `tools/gpu-sample`, GPU load follows
frames per second, not scene complexity: about 0.07 points of whole-GPU load per
frame per second. Classic redraws at your refresh rate (120 fps cost about 8
points). The other styles move a few times a second and cost almost nothing.

**Real readings in the log.** The Data terminal log shows what your machine is
doing, read from KDE's own system monitor service (the same source the System
Monitor widgets use). Each reading has its own line with a sparkline of its
recent history. The log is two columns, which keeps it short: `cpu`, `cputemp` and
`mem` in the accent color on the left, and `gpu`, `gputemp` and `vram` in the
secondary color on the right. Uptime and the static facts join the left column. Uptime and static facts such as OS,
kernel, Plasma and Qt versions can be added as plain lines. Choose and order the
lines with `LOG_ITEMS` (`cpu`, `cputemp`, `mem`, `gpu`, `gputemp`, `vram`,
`uptime`, `os`, `kernel`, `plasma`, `qt`, `host`). Each line is drawn entirely in
its group color, accent for CPU and secondary for GPU.

Polling and graph granularity are tunable. `LOG_REFRESH` is how often readings
are polled, in seconds. `SPARK_STEP` is the seconds between sparkline points and
`SPARK_POINTS` how many points each graph keeps, so a graph covers
`SPARK_STEP` x `SPARK_POINTS` seconds (the defaults show the last 80 seconds).
Slower polling is cheaper. Only plain numbers are read:
nothing identifying such as user names, addresses, processes or files is shown.
A login or lock still cannot update, so it shows only the static facts. If the
monitor service is unavailable, the live lines are simply left out.

Colors, title and tagline come from `/etc/cyberpunk-splash.conf`, like the
splash. The login screen takes a still image, because an image cannot tick.
`LOGIN_STYLE` picks which design that still uses (`DataTerminal`, `HexColumns`,
`Terminal`, or `Still` for the original), and the clock is left out of it. To use the plugin itself for the login screen, set
`WallpaperPluginId=org.cyberpunk.wallpaper` under `[Greeter]` in
`/etc/plasmalogin.conf`. Try the lock screen first, and keep the still as a
fallback.

## Preview

```
ksplashqml --test --window /usr/share/plasma/look-and-feel/org.cyberpunk.splash
```

A test window stays at stage 0 because Plasma is not advancing the stage.

## When the stamp runs

`cyberpunk-splash-stamp` runs automatically (pacman hook, after the
transaction) when a package matching `linux*`, `plasma-workspace`,
`qt6-base`, `filesystem` or `cyberpunk-splash` is installed, upgraded or
removed.
`linux*` also matches `linux-firmware`, which re-stamps harmlessly.

It does not run on its own for a hostname change or a config edit. After
either, run `sudo cyberpunk-splash-stamp`.

The stamp script reads only `/etc/os-release`, the config file, directory
names under `/usr/lib/modules`, the hostname and the versions of the
`plasma-workspace` and `qt6-base` packages. It writes one file:
`/usr/share/plasma/look-and-feel/org.cyberpunk.splash/contents/splash/SystemInfo.qml`.

## Layout

```
PKGBUILD                  package definition
cyberpunk-splash-stamp    writes SystemInfo.qml and the login wallpaper
cyberpunk-splash.hook     pacman hook that triggers the stamp
cyberpunk-splash.conf     default config (installed to /etc)
wallpaper/                login and lock still: original design, render script, package files
wallpaper-plugin/         animated wallpaper plugin and its designs
tools/                    gpu-sample, a GPU and CPU cost sampler
theme/                    the Plasma look-and-feel package
  metadata.json
  contents/splash/
    Splash.qml            the splash
    SystemInfo.qml        defaults, overwritten by the stamp
    fonts/                bundled fonts and their licenses
  contents/previews/      images shown in System Settings
```
