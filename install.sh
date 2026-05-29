#!/usr/bin/env bash
# =============================================================================
# install.sh — saneaspect-inspired Hyprland Rice
# Clean install for Arch Linux ARM (aarch64) in VMware Fusion
#
# Themes:  tokyonight | catppuccin | gruvbox | nord | rosepine
# Bar:     saneaspect | saneaspect-v1 | saneaspect-centered | minimal | floating
# Menus:   rofi-git (Wayland native)
# Term:    foot
# Notifs:  mako
# WP:      awww (ARM fork of swww)
# =============================================================================

set -uo pipefail

# =============================================================================
# HELPERS
# =============================================================================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log()  { echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} ${BOLD}${1}${NC}"; }
ok()   { echo -e "${GREEN}[✓]${NC} ${1}"; }
warn() { echo -e "${YELLOW}[!]${NC} ${1}"; }

echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║   saneaspect-inspired Hyprland Rice — ARM v1     ║${NC}"
echo -e "${CYAN}${BOLD}║   Arch Linux aarch64 · VMware Fusion              ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# =============================================================================
# STEP 1 — PACMAN KEYRING + SYSTEM UPDATE
# =============================================================================
log "Initialising pacman keyring..."
sudo pacman-key --init 2>/dev/null || true
sudo pacman-key --populate archlinuxarm 2>/dev/null || true

log "Updating system..."
sudo pacman -Syu --noconfirm

# =============================================================================
# STEP 2 — PACKAGES (in small batches to avoid hanging)
# =============================================================================
log "Installing Hyprland + Wayland stack..."
sudo pacman -S --needed --noconfirm \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    xdg-utils \
    qt5-wayland \
    qt6-wayland \
    wayland \
    wayland-protocols
log "Installing Firefox"
sudo pacman -S --needed --noconfirm firefox
log "Installing display manager..."
sudo pacman -S --needed --noconfirm sddm

log "Installing terminal + shell..."
sudo pacman -S --needed --noconfirm \
    foot \
    zsh \
    starship \
    fastfetch \
    btop

log "Installing notifications + bar..."
sudo pacman -S --needed --noconfirm \
    waybar \
    mako \
    libnotify

log "Installing rofi-git (Wayland-native)..."
# Try rofi-git from AUR first, fall back to rofi-wayland
if command -v yay &>/dev/null; then
    yay -S --needed --noconfirm rofi-git 2>/dev/null || \
    sudo pacman -S --needed --noconfirm rofi-wayland 2>/dev/null || \
    warn "rofi not installed — install manually"
else
    sudo pacman -S --needed --noconfirm rofi-wayland 2>/dev/null || \
    warn "rofi not installed — install yay then: yay -S rofi-git"
fi

log "Installing wallpaper tools..."
sudo pacman -S --needed --noconfirm swaybg
# awww (ARM fork of swww) from AUR
if command -v yay &>/dev/null; then
    yay -S --needed --noconfirm awww 2>/dev/null || warn "awww not found, using swaybg fallback"
else
    warn "awww not installed (needs yay) — using swaybg for wallpapers"
fi

log "Installing audio..."
sudo pacman -S --needed --noconfirm \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber \
    pavucontrol

log "Installing tools..."
sudo pacman -S --needed --noconfirm \
    grim \
    slurp \
    wl-clipboard \
    cliphist \
    playerctl \
    network-manager-applet \
    brightnessctl \
    thunar \
    gvfs \
    polkit-kde-agent \
    yad \
    curl \
    wget \
    git \
    unzip \
    python3 \
    imagemagick

log "Installing fonts..."
sudo pacman -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji \
    ttf-nerd-fonts-symbols

log "Installing icon themes..."
sudo pacman -S --needed --noconfirm \
    papirus-icon-theme \
    adwaita-icon-theme

log "Installing yay (AUR helper) if not present..."
if ! command -v yay &>/dev/null; then
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay-build
    cd /tmp/yay-build && makepkg -si --noconfirm && cd ~
    rm -rf /tmp/yay-build
    ok "yay installed"
fi
# =============================================================================
# STEP 3 — DIRECTORIES
# =============================================================================
log "Creating config directories..."
mkdir -p ~/.config/hypr/{scripts,themes,wallpapers/{tokyonight,catppuccin,gruvbox,nord,rosepine}}
mkdir -p ~/.config/waybar/layouts
mkdir -p ~/.config/rofi
mkdir -p ~/.config/foot
mkdir -p ~/.config/mako
mkdir -p ~/Pictures/Screenshots

# =============================================================================
# STEP 4 — WALLPAPERS
# =============================================================================
log "Downloading wallpapers..."

dl() {
    local url="$1" dest="$2"
    [ -f "$dest" ] && return
    echo "  → $(basename $dest)"
    curl -fsSL --max-time 30 -o "$dest" "$url" 2>/dev/null || \
        warn "Failed: $(basename $dest)"
    sleep 0.3
}

# Tokyo Night
dl "https://raw.githubusercontent.com/dharmx/walls/main/dark/dark_city.png" \
   ~/.config/hypr/wallpapers/tokyonight/wall-1.png
dl "https://raw.githubusercontent.com/dharmx/walls/main/dark/a_samurai_in_a_rain.png" \
   ~/.config/hypr/wallpapers/tokyonight/wall-2.png
dl "https://raw.githubusercontent.com/dharmx/walls/main/dark/neon_city.png" \
   ~/.config/hypr/wallpapers/tokyonight/wall-3.png

# Catppuccin
dl "https://raw.githubusercontent.com/catppuccin/wallpapers/main/landscapes/evening-sky.png" \
   ~/.config/hypr/wallpapers/catppuccin/wall-1.png
dl "https://raw.githubusercontent.com/catppuccin/wallpapers/main/minimalistic/cat-sound.png" \
   ~/.config/hypr/wallpapers/catppuccin/wall-2.png

# Gruvbox
dl "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/main/wallpapers/minimalist/road.png" \
   ~/.config/hypr/wallpapers/gruvbox/wall-1.png
dl "https://raw.githubusercontent.com/AngelJumbo/gruvbox-wallpapers/main/wallpapers/art/firewatch.png" \
   ~/.config/hypr/wallpapers/gruvbox/wall-2.png

# Nord
dl "https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers/ign_astronaut.png" \
   ~/.config/hypr/wallpapers/nord/wall-1.png
dl "https://raw.githubusercontent.com/linuxdotexe/nordic-wallpapers/master/wallpapers/MeshGradient-1.png" \
   ~/.config/hypr/wallpapers/nord/wall-2.png

# Rose Pine
dl "https://raw.githubusercontent.com/rose-pine/wallpapers/main/landscapes/dawn-light.png" \
   ~/.config/hypr/wallpapers/rosepine/wall-1.png
dl "https://raw.githubusercontent.com/rose-pine/wallpapers/main/landscapes/moon-light.png" \
   ~/.config/hypr/wallpapers/rosepine/wall-2.png

ok "Wallpapers downloaded"

# =============================================================================
# STEP 5 — HYPRLAND CONFIG
# =============================================================================
log "Writing hyprland.conf..."
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# =============================================================================
# hyprland.conf — saneaspect-inspired rice
# VMware ARM aarch64
# =============================================================================

monitor=,preferred,auto,1

# VMware ARM software rendering — REQUIRED
env = WLR_RENDERER,pixman
env = WLR_RENDERER_ALLOW_SOFTWARE,1
env = WLR_DRM_NO_ATOMIC,1
env = LIBGL_ALWAYS_SOFTWARE,1
env = WLR_NO_HARDWARE_CURSORS,1

# Wayland
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = QT_QPA_PLATFORM,wayland;xcb
env = GDK_BACKEND,wayland,x11,*
env = MOZ_ENABLE_WAYLAND,1
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,Adwaita

# Autostart
exec-once = bash ~/.config/hypr/scripts/startup.sh
exec-once = mako
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = wl-paste --watch cliphist store
exec-once = nm-applet --indicator

$mainMod  = ALT
$terminal = foot
$launcher = rofi -show drun -theme ~/.config/rofi/launcher.rasi -show-icons -icon-theme Papirus-Dark

general {
    gaps_in  = 4
    gaps_out = 8
    border_size = 2
    col.active_border   = rgba(7aa2f7ff) rgba(bb9af7ff) 45deg
    col.inactive_border = rgba(292e42aa)
    layout = dwindle
    resize_on_border = true
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size    = 5
        passes  = 2
        new_optimizations = true
    }
    shadow {
        enabled      = true
        range        = 12
        render_power = 3
        color        = rgba(1a1b26cc)
    }
    active_opacity   = 1.0
    inactive_opacity = 0.92
}

animations {
    enabled = true
    bezier = sane,   0.16, 1,   0.3,  1
    bezier = linear, 0.0,  0.0, 1.0,  1.0

    animation = windows,     1, 4, sane, popin 80%
    animation = windowsOut,  1, 3, sane, popin 80%
    animation = windowsMove, 1, 3, sane
    animation = border,      1, 6, linear
    animation = fade,        1, 3, sane
    animation = workspaces,  1, 4, sane, slide
}

input {
    kb_layout    = us
    follow_mouse = 1
    sensitivity  = 0
    accel_profile = flat
    touchpad { natural_scroll = true; tap-to-click = true }
}

dwindle { pseudotile = true; preserve_split = true }

misc {
    force_default_wallpaper  = 0
    disable_hyprland_logo    = true
    disable_splash_rendering = true
    mouse_move_enables_dpms  = true
    enable_swallow           = true
    swallow_regex            = ^(foot)$
}

windowrule = float, rofi
windowrule = float, pavucontrol
windowrule = float, nm-connection-editor
windowrule = float, thunar
windowrule = opacity 0.92 0.85, foot

layerrule = blur, waybar
layerrule = ignorezero, waybar
layerrule = blur, rofi
layerrule = ignorezero, rofi
layerrule = blur, mako
layerrule = ignorezero, mako

# Apps
bind = $mainMod,       Return, exec, $terminal
bind = $mainMod,       D,      exec, $launcher
bind = $mainMod,       B,      exec, firefox
bind = $mainMod,       E,      exec, thunar
bind = $mainMod,       C,      killactive
bind = $mainMod SHIFT, E,      exit
bind = $mainMod,       F,      fullscreen, 0
bind = $mainMod SHIFT, F,      fullscreen, 1
bind = $mainMod,       V,      togglefloating
bind = $mainMod,       Tab,    cyclenext
bind = $mainMod,       S,      togglespecialworkspace, magic
bind = $mainMod SHIFT, S,      movetoworkspace, special:magic

# Rice controls
bind = $mainMod,       T,            exec, bash ~/.config/hypr/scripts/theme-switcher.sh
bind = $mainMod,       W,            exec, bash ~/.config/hypr/scripts/wallpaper-switcher.sh
bind = $mainMod SHIFT, W,            exec, bash ~/.config/hypr/scripts/random-wallpaper.sh
bind = $mainMod,       L,            exec, bash ~/.config/hypr/scripts/layout-switcher.sh
bind = $mainMod,       bracketleft,  exec, bash ~/.config/hypr/scripts/sidebar-left.sh
bind = $mainMod,       bracketright, exec, bash ~/.config/hypr/scripts/sidebar-right.sh

# Focus
bind = $mainMod, left,  movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up,    movefocus, u
bind = $mainMod, down,  movefocus, d
bind = $mainMod, H,     movefocus, l
bind = $mainMod, J,     movefocus, d
bind = $mainMod, K,     movefocus, u

# Move
bind = $mainMod SHIFT, left,  movewindow, l
bind = $mainMod SHIFT, right, movewindow, r
bind = $mainMod SHIFT, up,    movewindow, u
bind = $mainMod SHIFT, down,  movewindow, d

# Resize
binde = $mainMod CTRL, right, resizeactive,  40 0
binde = $mainMod CTRL, left,  resizeactive, -40 0
binde = $mainMod CTRL, up,    resizeactive,  0 -40
binde = $mainMod CTRL, down,  resizeactive,  0  40

# Workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up,   workspace, e-1

# Screenshots
bind = ,      Print, exec, grim ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot saved"
bind = SHIFT, Print, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png
bind = CTRL,  Print, exec, grim -g "$(slurp)" - | wl-copy

# Volume
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute,        exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind = , XF86AudioPlay,        exec, playerctl play-pause
bind = , XF86AudioNext,        exec, playerctl next
bind = , XF86AudioPrev,        exec, playerctl previous

bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF
ok "hyprland.conf written"

# =============================================================================
# STEP 6 — THEMES FILE
# =============================================================================
log "Writing theme definitions..."
cat > ~/.config/hypr/themes/themes.sh << 'EOF'
#!/usr/bin/env bash
case "${1:-$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo tokyonight)}" in
    tokyonight)
        BG="#1a1b26"; BG2="#16161e"; SURFACE="#292e42"; SURFACE2="#414868"
        TEXT="#c0caf5"; SUB="#565f89"; ACCENT="#7aa2f7"; ACCENT2="#bb9af7"
        GREEN="#9ece6a"; RED="#f7768e"; YELLOW="#e0af68"; TEAL="#7dcfff"
        WALL_DIR="tokyonight" ;;
    catppuccin)
        BG="#1e1e2e"; BG2="#181825"; SURFACE="#313244"; SURFACE2="#45475a"
        TEXT="#cdd6f4"; SUB="#6c7086"; ACCENT="#cba6f7"; ACCENT2="#89b4fa"
        GREEN="#a6e3a1"; RED="#f38ba8"; YELLOW="#f9e2af"; TEAL="#94e2d5"
        WALL_DIR="catppuccin" ;;
    gruvbox)
        BG="#1d2021"; BG2="#282828"; SURFACE="#3c3836"; SURFACE2="#504945"
        TEXT="#ebdbb2"; SUB="#928374"; ACCENT="#d79921"; ACCENT2="#b57614"
        GREEN="#98971a"; RED="#cc241d"; YELLOW="#fabd2f"; TEAL="#689d6a"
        WALL_DIR="gruvbox" ;;
    nord)
        BG="#2e3440"; BG2="#242933"; SURFACE="#3b4252"; SURFACE2="#434c5e"
        TEXT="#eceff4"; SUB="#4c566a"; ACCENT="#88c0d0"; ACCENT2="#81a1c1"
        GREEN="#a3be8c"; RED="#bf616a"; YELLOW="#ebcb8b"; TEAL="#8fbcbb"
        WALL_DIR="nord" ;;
    rosepine)
        BG="#191724"; BG2="#1f1d2e"; SURFACE="#26233a"; SURFACE2="#403d52"
        TEXT="#e0def4"; SUB="#6e6a86"; ACCENT="#c4a7e7"; ACCENT2="#9ccfd8"
        GREEN="#31748f"; RED="#eb6f92"; YELLOW="#f6c177"; TEAL="#9ccfd8"
        WALL_DIR="rosepine" ;;
esac
export BG BG2 SURFACE SURFACE2 TEXT SUB ACCENT ACCENT2 GREEN RED YELLOW TEAL WALL_DIR
EOF
echo "tokyonight" > ~/.config/hypr/themes/current-name
ok "Themes written"

# =============================================================================
# STEP 7 — SCRIPTS
# =============================================================================
log "Writing scripts..."

# startup.sh
cat > ~/.config/hypr/scripts/startup.sh << 'EOF'
#!/usr/bin/env bash
mkdir -p ~/.cache/awww
awww-daemon 2>/dev/null &
sleep 1
bash ~/.config/hypr/scripts/layout-switcher.sh saneaspect
THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo "tokyonight")
WALL=$(find ~/.config/hypr/wallpapers/$THEME -type f \( -iname "*.png" -o -iname "*.jpg" \) 2>/dev/null | shuf -n 1)
[ -n "$WALL" ] && bash ~/.config/hypr/scripts/set-wallpaper.sh "$WALL"
EOF

# set-wallpaper.sh
cat > ~/.config/hypr/scripts/set-wallpaper.sh << 'EOF'
#!/usr/bin/env bash
WALL="$1"
[ -z "$WALL" ] || [ ! -f "$WALL" ] && exit 1
if pgrep awww-daemon > /dev/null 2>&1; then
    awww img "$WALL" --transition-type grow --transition-duration 1.2 \
        --transition-fps 60 --transition-pos 0.5,0.5 2>/dev/null
else
    mkdir -p ~/.cache/awww && awww-daemon &
    sleep 0.5
    awww img "$WALL" --transition-type grow --transition-duration 1.2 2>/dev/null || \
    (pkill swaybg 2>/dev/null; swaybg -i "$WALL" -m fill &)
fi
EOF

# random-wallpaper.sh
cat > ~/.config/hypr/scripts/random-wallpaper.sh << 'EOF'
#!/usr/bin/env bash
THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo "tokyonight")
WALL=$(find ~/.config/hypr/wallpapers/$THEME \
    -type f \( -iname "*.png" -o -iname "*.jpg" \) 2>/dev/null | shuf -n 1)
[ -n "$WALL" ] && bash ~/.config/hypr/scripts/set-wallpaper.sh "$WALL"
EOF

# wallpaper-switcher.sh
cat > ~/.config/hypr/scripts/wallpaper-switcher.sh << 'EOF'
#!/usr/bin/env bash
THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo "tokyonight")
WALL_DIR="$HOME/.config/hypr/wallpapers/$THEME"
WALLS=$(find "$WALL_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" \) 2>/dev/null | sort)
[ -z "$WALLS" ] && notify-send "Wallpaper" "No wallpapers found" && exit 1
SELECTED=$(echo "$WALLS" | while read -r f; do basename "$f"; done | \
    rofi -dmenu -p "Wallpaper" -theme ~/.config/rofi/theme-switcher.rasi -no-custom)
[ -z "$SELECTED" ] && exit 0
FULL="$WALL_DIR/$SELECTED"
[ -f "$FULL" ] && bash ~/.config/hypr/scripts/set-wallpaper.sh "$FULL"
EOF

# powermenu.sh
cat > ~/.config/hypr/scripts/powermenu.sh << 'EOF'
#!/usr/bin/env bash
CHOICE=$(printf "󰌾  Lock\n󰿅  Logout\n  Suspend\n󰑐  Reboot\n󰐥  Shutdown" | \
    rofi -dmenu -p "" -theme ~/.config/rofi/powermenu.rasi -no-custom)
case "$CHOICE" in
    *Lock*)     swaylock 2>/dev/null || loginctl lock-session ;;
    *Logout*)   hyprctl dispatch exit ;;
    *Suspend*)  systemctl suspend ;;
    *Reboot*)   systemctl reboot ;;
    *Shutdown*) systemctl poweroff ;;
esac
EOF

# layout-switcher.sh
cat > ~/.config/hypr/scripts/layout-switcher.sh << 'EOF'
#!/usr/bin/env bash
if [ -n "$1" ]; then
    LAYOUT="$1"
else
    LAYOUT=$(printf "saneaspect\nsaneaspect-v1\nsaneaspect-centered\nminimal\nproductive\nfloating" | \
        rofi -dmenu -p "Layout" -theme ~/.config/rofi/theme-switcher.rasi -no-custom)
fi
[ -z "$LAYOUT" ] && exit 0
echo "$LAYOUT" > ~/.config/waybar/current-layout
pkill waybar 2>/dev/null || true
sleep 0.3
L="$HOME/.config/waybar/layouts"
case "$LAYOUT" in
    saneaspect)          waybar -c $L/saneaspect.jsonc          -s $L/saneaspect.css & ;;
    saneaspect-v1)       waybar -c $L/saneaspect-v1.jsonc       -s $L/saneaspect-v1.css & ;;
    saneaspect-centered) waybar -c $L/saneaspect-centered.jsonc -s $L/saneaspect-centered.css & ;;
    minimal)             waybar -c $L/minimal.jsonc             -s $L/shared.css & ;;
    productive)          waybar -c $L/productive.jsonc          -s $L/shared.css & ;;
    floating)
        waybar -c $L/floating-left.jsonc   -s $L/shared.css &
        waybar -c $L/floating-center.jsonc -s $L/shared.css &
        waybar -c $L/floating-right.jsonc  -s $L/shared.css & ;;
    *) waybar -c $L/saneaspect.jsonc -s $L/saneaspect.css & ;;
esac
[ -z "$1" ] && notify-send "Layout" "→ $LAYOUT" 2>/dev/null || true
EOF

# theme-switcher.sh
cat > ~/.config/hypr/scripts/theme-switcher.sh << 'EOF'
#!/usr/bin/env bash
THEME=$(printf "tokyonight\ncatppuccin\ngruvbox\nnord\nrosepine" | \
    rofi -dmenu -p "Select Theme" -theme ~/.config/rofi/theme-switcher.rasi -no-custom)
[ -z "$THEME" ] && exit 0

echo "$THEME" > ~/.config/hypr/themes/current-name
source ~/.config/hypr/themes/themes.sh "$THEME"

cat > ~/.config/waybar/colors.css << COLORS
@define-color bg       ${BG};
@define-color bg2      ${BG2};
@define-color surface  ${SURFACE};
@define-color surface2 ${SURFACE2};
@define-color text     ${TEXT};
@define-color sub      ${SUB};
@define-color accent   ${ACCENT};
@define-color accent2  ${ACCENT2};
@define-color green    ${GREEN};
@define-color red      ${RED};
@define-color yellow   ${YELLOW};
@define-color teal     ${TEAL};
COLORS

for f in ~/.config/rofi/*.rasi; do
    [ -f "$f" ] || continue
    sed -i "s/bg:      #[0-9a-fA-F]*/bg:      ${BG}/" "$f"
    sed -i "s/bg2:     #[0-9a-fA-F]*/bg2:     ${SURFACE}/" "$f"
    sed -i "s/accent:  #[0-9a-fA-F]*/accent:  ${ACCENT}/" "$f"
    sed -i "s/fg:      #[0-9a-fA-F]*/fg:      ${TEXT}/" "$f"
    sed -i "s/fg2:     #[0-9a-fA-F]*/fg2:     ${SUB}/" "$f"
done

cat > ~/.config/foot/theme.ini << FOOT
[colors-dark]
background=${BG#\#}
foreground=${TEXT#\#}
regular0=${BG2#\#}
regular1=${RED#\#}
regular2=${GREEN#\#}
regular3=${YELLOW#\#}
regular4=${ACCENT2#\#}
regular5=${ACCENT#\#}
regular6=${TEAL#\#}
regular7=${SUB#\#}
bright0=${SURFACE#\#}
bright1=${RED#\#}
bright2=${GREEN#\#}
bright3=${YELLOW#\#}
bright4=${ACCENT2#\#}
bright5=${ACCENT#\#}
bright6=${TEAL#\#}
bright7=${TEXT#\#}
selection-foreground=${BG#\#}
selection-background=${ACCENT#\#}
FOOT

cat > ~/.config/mako/config << MAKO
background-color=${BG}ee
text-color=${TEXT}
border-color=${ACCENT}
border-radius=10
border-size=1
font=JetBrainsMono Nerd Font 11
padding=12,16
margin=8
width=320
height=100
layer=overlay
anchor=top-right
default-timeout=4000
max-visible=3

[urgency=high]
border-color=${RED}
MAKO

WALL=$(find ~/.config/hypr/wallpapers/$WALL_DIR \
    -type f \( -iname "*.png" -o -iname "*.jpg" \) 2>/dev/null | shuf -n 1)
[ -n "$WALL" ] && bash ~/.config/hypr/scripts/set-wallpaper.sh "$WALL"

hyprctl keyword general:col.active_border \
    "rgba(${ACCENT#\#}ff) rgba(${ACCENT2#\#}ff) 45deg" 2>/dev/null || true

LAYOUT=$(cat ~/.config/waybar/current-layout 2>/dev/null || echo "saneaspect")
pkill waybar 2>/dev/null || true
sleep 0.3
bash ~/.config/hypr/scripts/layout-switcher.sh "$LAYOUT"

notify-send "Theme" "→ $THEME" 2>/dev/null || true
EOF

# sidebar-left.sh
cat > ~/.config/hypr/scripts/sidebar-left.sh << 'EOF'
#!/usr/bin/env bash
pkill -f "yad --title=sidebar-left" 2>/dev/null && exit 0
THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo "tokyonight")
source ~/.config/hypr/themes/themes.sh "$THEME"
SCREEN_H=$(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; print(json.load(sys.stdin)[0]['height'])" 2>/dev/null || echo "1080")
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}' 2>/dev/null || echo "?")
RAM=$(free | awk '/Mem/{printf "%.0f", $3/$2*100}' 2>/dev/null || echo "?")
DISK=$(df -h / | awk 'NR==2{print $5}' 2>/dev/null || echo "?")
export GTK_THEME=Adwaita:dark
yad --title="sidebar-left" \
    --no-buttons --undecorated --skip-taskbar --no-focus \
    --geometry=270x${SCREEN_H}+0+0 \
    --text-align=left \
    --text="<span font='JetBrainsMono Nerd Font Bold 28' foreground='${ACCENT}'>$(date '+%H:%M')</span>
<span font='JetBrainsMono Nerd Font 12' foreground='${TEXT}'>$(date '+%A, %B %d')</span>

<span font='JetBrainsMono Nerd Font Bold 12' foreground='${ACCENT}'>  Calendar</span>
<span font='JetBrainsMono Nerd Font 10' foreground='${TEXT}'><tt>$(cal)</tt></span>

<span font='JetBrainsMono Nerd Font Bold 12' foreground='${ACCENT}'>  System</span>
<span font='JetBrainsMono Nerd Font 11' foreground='${TEXT}'> CPU    ${CPU}%
 RAM    ${RAM}%
 Disk   ${DISK}
 $(uptime -p | sed 's/up //')</span>" \
    --borders=20 --fixed 2>/dev/null &
EOF

# sidebar-right.sh
cat > ~/.config/hypr/scripts/sidebar-right.sh << 'EOF'
#!/usr/bin/env bash
pkill -f "yad --title=sidebar-right" 2>/dev/null && exit 0
THEME=$(cat ~/.config/hypr/themes/current-name 2>/dev/null || echo "tokyonight")
source ~/.config/hypr/themes/themes.sh "$THEME"
SCREEN_W=$(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; print(json.load(sys.stdin)[0]['width'])" 2>/dev/null || echo "1920")
SCREEN_H=$(hyprctl monitors -j 2>/dev/null | \
    python3 -c "import sys,json; print(json.load(sys.stdin)[0]['height'])" 2>/dev/null || echo "1080")
X=$((SCREEN_W - 278))
VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%.0f", $2*100}' || echo "?")
TITLE=$(playerctl metadata title 2>/dev/null || echo "Nothing playing")
ARTIST=$(playerctl metadata artist 2>/dev/null || echo "")
NET=$(iwgetid -r 2>/dev/null || echo "Wired")
LAYOUT=$(cat ~/.config/waybar/current-layout 2>/dev/null || echo "saneaspect")
export GTK_THEME=Adwaita:dark
yad --title="sidebar-right" \
    --no-buttons --undecorated --skip-taskbar --no-focus \
    --geometry=270x${SCREEN_H}+${X}+0 \
    --text-align=left \
    --text="<span font='JetBrainsMono Nerd Font Bold 12' foreground='${ACCENT}'>󰒓  Quick Settings</span>

<span font='JetBrainsMono Nerd Font 11' foreground='${TEXT}'>󰋋  Volume   ${VOL}%
󰖩  Network  ${NET}
 Theme    ${THEME}
 Layout   ${LAYOUT}</span>

<span font='JetBrainsMono Nerd Font Bold 12' foreground='${ACCENT}'>♪  Now Playing</span>
<span font='JetBrainsMono Nerd Font 11' foreground='${TEXT}'>${TITLE}
${ARTIST}</span>

<span font='JetBrainsMono Nerd Font Bold 12' foreground='${ACCENT}'>  Keybinds</span>
<span font='JetBrainsMono Nerd Font 10' foreground='${SUB}'>ALT+Return  Terminal
ALT+D       Launcher
ALT+T       Theme Switcher
ALT+W       Wallpaper
ALT+L       Layout Switcher
ALT+[       Left Panel
ALT+]       Right Panel
Print       Screenshot</span>" \
    --borders=20 --fixed 2>/dev/null &
EOF

chmod +x ~/.config/hypr/scripts/*.sh
ok "Scripts written"

# =============================================================================
# STEP 8 — WAYBAR COLORS (default tokyonight)
# =============================================================================
log "Writing waybar colors..."
cat > ~/.config/waybar/colors.css << 'EOF'
@define-color bg       #1a1b26;
@define-color bg2      #16161e;
@define-color surface  #292e42;
@define-color surface2 #414868;
@define-color text     #c0caf5;
@define-color sub      #565f89;
@define-color accent   #7aa2f7;
@define-color accent2  #bb9af7;
@define-color green    #9ece6a;
@define-color red      #f7768e;
@define-color yellow   #e0af68;
@define-color teal     #7dcfff;
EOF
echo "saneaspect" > ~/.config/waybar/current-layout

# =============================================================================
# STEP 9 — WAYBAR LAYOUTS
# =============================================================================
log "Writing waybar layouts..."

# ── Shared CSS (used by minimal/productive/floating) ──────────────────────────
cat > ~/.config/waybar/layouts/shared.css << 'EOF'
@import "../colors.css";
* { font-family: "JetBrainsMono Nerd Font",monospace; font-size:12px; border:none; border-radius:0; min-height:0; transition:all 0.15s ease; }
window#waybar { background:alpha(@surface,0.85); border:1px solid alpha(@surface2,0.5); border-radius:14px; color:@text; }
#workspaces { background:alpha(@surface,0.6); border-radius:10px; margin:4px; padding:0 4px; }
#workspaces button { color:@sub; border-radius:8px; padding:0 10px; margin:3px 1px; background:transparent; font-weight:600; }
#workspaces button.active { background:@accent; color:@bg; border-radius:8px; font-weight:bold; }
#workspaces button.urgent { background:@red; color:@bg; }
#clock { color:@accent; font-weight:600; padding:0 16px; margin:4px 0; background:alpha(@surface,0.6); border-radius:10px; }
#mpris { color:@green; padding:0 10px; margin:4px 2px; background:alpha(@surface,0.6); border-radius:8px; font-style:italic; }
#cpu,#memory,#network,#pulseaudio,#tray,#custom-power,#battery { padding:0 10px; margin:4px 2px; background:alpha(@surface,0.6); border-radius:8px; }
#cpu { color:@teal; } #memory { color:@accent; } #network { color:@green; } #pulseaudio { color:@accent2; }
#battery { color:@yellow; } #battery.charging { color:@green; } #battery.critical { color:@red; }
#custom-power { color:@red; font-size:14px; padding:0 12px; }
tooltip { background:alpha(@bg,0.97); border:1px solid alpha(@surface,0.8); border-radius:10px; color:@text; }
EOF

# ── saneaspect (image 1/3 style: full bar, small pills) ───────────────────────
cat > ~/.config/waybar/layouts/saneaspect.jsonc << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 28,
    "margin-top": 6,
    "margin-left": 0,
    "margin-right": 0,
    "spacing": 0,
    "exclusive": true,

    "modules-left": ["custom/arch", "clock", "mpris"],
    "modules-center": ["hyprland/workspaces"],
    "modules-right": ["cpu", "pulseaudio", "network", "battery", "custom/notification", "custom/power"],

    "custom/arch": {
        "format": "  ",
        "tooltip": false,
        "on-click": "rofi -show drun -theme ~/.config/rofi/launcher.rasi -show-icons -icon-theme Papirus-Dark"
    },
    "clock": {
        "format": "{:%I:%M %p}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>"
    },
    "mpris": {
        "format": "▶ {title}",
        "format-paused": "⏸ {title}",
        "format-stopped": "",
        "max-length": 22,
        "interval": 1,
        "tooltip": false
    },
    "hyprland/workspaces": {
        "format": "{id}",
        "on-click": "activate",
        "sort-by-number": true,
        "persistent-workspaces": { "*": [1,2,3,4,5] },
        "tooltip": false
    },
    "cpu": {
        "format": "󰻠 {usage}%",
        "interval": 2,
        "tooltip": false,
        "on-click": "foot -e btop"
    },
    "pulseaudio": {
        "format": "󰋋 {volume}%",
        "format-muted": "󰝟",
        "tooltip": false,
        "on-click": "pavucontrol",
        "on-scroll-up": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+",
        "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    },
    "network": {
        "format-wifi": "󰖩 {essid}",
        "format-ethernet": "󰈀 Wired",
        "format-disconnected": "󰤭",
        "max-length": 14,
        "tooltip": false,
        "on-click": "nm-connection-editor"
    },
    "battery": {
        "format": "󰁹 {capacity}%",
        "format-charging": "󰂄 {capacity}%",
        "tooltip": false
    },
    "custom/notification": {
        "format": "󰂚",
        "tooltip": false
    },
    "custom/power": {
        "format": "⏻",
        "tooltip": false,
        "on-click": "bash ~/.config/hypr/scripts/powermenu.sh"
    }
}
EOF

cat > ~/.config/waybar/layouts/saneaspect.css << 'EOF'
@import "../colors.css";
* { font-family:"JetBrainsMono Nerd Font",monospace; font-size:12px; border:none; border-radius:0; min-height:0; transition:all 0.15s ease; }

window#waybar {
    background: alpha(@bg, 0.85);
    border-bottom: 1px solid alpha(@surface, 0.5);
    color: @text;
}

#custom-arch {
    background: alpha(@surface,0.8);
    border-radius: 0 0 10px 0;
    color: @accent;
    font-size: 14px;
    padding: 0 12px;
    margin: 0;
}

#clock {
    color: @text;
    font-weight: 500;
    padding: 0 12px;
    margin: 0 2px;
    background: alpha(@surface,0.5);
    border-radius: 0 0 10px 10px;
}

#mpris {
    color: @green;
    padding: 0 10px;
    margin: 0 2px;
    background: alpha(@surface,0.5);
    border-radius: 0 0 10px 10px;
    font-style: italic;
}

#workspaces {
    background: alpha(@surface,0.7);
    border-radius: 0 0 12px 12px;
    padding: 0 6px;
    margin: 0;
}

#workspaces button {
    color: @sub;
    border-radius: 0 0 8px 8px;
    padding: 0 10px;
    margin: 0 1px;
    background: transparent;
    font-weight: 600;
    min-width: 28px;
}

#workspaces button.active {
    background: @accent;
    color: @bg;
    border-radius: 0 0 10px 10px;
    font-weight: bold;
    padding: 0 14px;
}

#workspaces button.urgent { background: @red; color: @bg; }

#cpu,#pulseaudio,#network,#battery,#custom-notification,#custom-power {
    background: alpha(@surface,0.5);
    border-radius: 0 0 10px 10px;
    padding: 0 10px;
    margin: 0 2px;
    color: @text;
}

#cpu              { color: @teal; }
#pulseaudio       { color: @accent2; }
#network          { color: @green; }
#battery          { color: @yellow; }
#battery.charging { color: @green; }
#battery.critical { color: @red; }
#custom-notification { color: @sub; }
#custom-power     { color: @red; margin-right: 0; border-radius: 0 0 0 10px; }

tooltip { background:alpha(@bg,0.97); border:1px solid alpha(@surface,0.8); border-radius:10px; color:@text; }
EOF

# ── saneaspect-v1 (image 2 style: centered pill) ─────────────────────────────
cat > ~/.config/waybar/layouts/saneaspect-v1.jsonc << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "margin-top": 8,
    "margin-left": 0,
    "margin-right": 0,
    "spacing": 0,
    "exclusive": true,

    "modules-left": [],
    "modules-center": ["clock", "hyprland/workspaces", "pulseaudio", "network", "battery", "custom/notification"],
    "modules-right": [],

    "clock": {
        "format": "{:%H:%M}",
        "tooltip": false
    },
    "hyprland/workspaces": {
        "format": "{id}",
        "on-click": "activate",
        "sort-by-number": true,
        "persistent-workspaces": { "*": [1,2,3,4,5] },
        "tooltip": false
    },
    "pulseaudio": {
        "format": "󰋋",
        "format-muted": "󰝟",
        "tooltip": false,
        "on-click": "pavucontrol",
        "on-scroll-up": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+",
        "on-scroll-down": "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    },
    "network": {
        "format-wifi": "󰖩",
        "format-ethernet": "󰈀",
        "format-disconnected": "󰤭",
        "tooltip": false
    },
    "battery": {
        "format": "󰁹",
        "format-charging": "󰂄",
        "tooltip": false
    },
    "custom/notification": {
        "format": "󰂚",
        "tooltip": false,
        "on-click": "bash ~/.config/hypr/scripts/powermenu.sh"
    }
}
EOF

cat > ~/.config/waybar/layouts/saneaspect-v1.css << 'EOF'
@import "../colors.css";
* { font-family:"JetBrainsMono Nerd Font",monospace; font-size:12px; border:none; border-radius:0; min-height:0; transition:all 0.15s ease; }

window#waybar {
    background: alpha(@surface,0.80);
    border: 1px solid alpha(@surface2,0.5);
    border-radius: 0 0 16px 16px;
    color: @text;
}

#clock {
    color: @text;
    font-weight: 600;
    padding: 0 14px;
    background: transparent;
}

#workspaces {
    background: transparent;
    padding: 0 4px;
}

#workspaces button {
    color: @sub;
    border-radius: 20px;
    padding: 2px 10px;
    margin: 3px 2px;
    background: alpha(@surface2,0.5);
    font-weight: 600;
    min-width: 24px;
}

#workspaces button.active {
    background: @accent;
    color: @bg;
    border-radius: 20px;
    font-weight: bold;
    padding: 2px 14px;
}

#workspaces button.urgent { background: @red; color: @bg; }

#pulseaudio,#network,#battery,#custom-notification {
    background: transparent;
    padding: 0 8px;
    color: @text;
}

#pulseaudio { color: @accent2; }
#network { color: @green; }
#battery { color: @yellow; }
#battery.charging { color: @green; }
#custom-notification { color: @sub; padding-right: 14px; }

tooltip { background:alpha(@bg,0.97); border:1px solid alpha(@surface,0.8); border-radius:10px; color:@text; }
EOF

# ── saneaspect-centered (full centered compact pill) ─────────────────────────
cat > ~/.config/waybar/layouts/saneaspect-centered.jsonc << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "margin-top": 8,
    "margin-left": 180,
    "margin-right": 180,
    "spacing": 0,
    "exclusive": true,

    "modules-left": [],
    "modules-center": ["custom/arch", "hyprland/workspaces", "clock", "cpu", "pulseaudio", "network", "custom/power"],
    "modules-right": [],

    "custom/arch": {
        "format": "  ",
        "tooltip": false,
        "on-click": "rofi -show drun -theme ~/.config/rofi/launcher.rasi -show-icons -icon-theme Papirus-Dark"
    },
    "hyprland/workspaces": {
        "format": "{id}",
        "on-click": "activate",
        "sort-by-number": true,
        "persistent-workspaces": { "*": [1,2,3,4,5] },
        "tooltip": false
    },
    "clock": { "format": "{:%H:%M}", "tooltip": false },
    "cpu": { "format": "󰻠 {usage}%", "interval": 2, "tooltip": false, "on-click": "foot -e btop" },
    "pulseaudio": {
        "format": "󰋋 {volume}%",
        "format-muted": "󰝟",
        "on-click": "pavucontrol",
        "tooltip": false
    },
    "network": {
        "format-wifi": "󰖩 {essid}",
        "format-ethernet": "󰈀",
        "format-disconnected": "󰤭",
        "max-length": 12,
        "tooltip": false
    },
    "custom/power": {
        "format": "⏻",
        "tooltip": false,
        "on-click": "bash ~/.config/hypr/scripts/powermenu.sh"
    }
}
EOF

cat > ~/.config/waybar/layouts/saneaspect-centered.css << 'EOF'
@import "../colors.css";
* { font-family:"JetBrainsMono Nerd Font",monospace; font-size:12px; border:none; border-radius:0; min-height:0; transition:all 0.15s ease; }

window#waybar {
    background: alpha(@bg,0.88);
    border: 1px solid alpha(@surface,0.6);
    border-radius: 0 0 20px 20px;
    color: @text;
}

#custom-arch { color:@accent; font-size:14px; padding:0 10px 0 14px; background:transparent; }
#workspaces { background:transparent; padding:0 4px; }
#workspaces button { color:@sub; border-radius:8px; padding:0 8px; margin:3px 1px; background:transparent; font-weight:600; }
#workspaces button.active { background:@accent; color:@bg; border-radius:8px; }
#workspaces button.urgent { background:@red; color:@bg; }
#clock { color:@accent; font-weight:600; padding:0 10px; background:alpha(@surface,0.5); border-radius:10px; margin:4px 2px; }
#cpu,#pulseaudio,#network,#custom-power { padding:0 8px; margin:4px 2px; background:transparent; }
#cpu { color:@teal; } #pulseaudio { color:@accent2; } #network { color:@green; }
#custom-power { color:@red; padding-right:14px; }
tooltip { background:alpha(@bg,0.97); border:1px solid alpha(@surface,0.8); border-radius:10px; color:@text; }
EOF

# ── Minimal ────────────────────────────────────────────────────────────────────
cat > ~/.config/waybar/layouts/minimal.jsonc << 'EOF'
{
    "layer":"top","position":"top","height":32,
    "margin-top":8,"margin-left":100,"margin-right":100,
    "spacing":4,"exclusive":true,
    "modules-left":["hyprland/workspaces"],
    "modules-center":["clock"],
    "modules-right":["pulseaudio","custom/power"],
    "hyprland/workspaces":{"format":"{id}","on-click":"activate","sort-by-number":true,"persistent-workspaces":{"*":[1,2,3,4,5]}},
    "clock":{"format":"{:%H:%M}","tooltip-format":"<tt>{calendar}</tt>"},
    "pulseaudio":{"format":"{icon} {volume}%","format-muted":"󰝟","format-icons":{"default":["󰕿","󰖀","󰕾"]},"on-click":"pavucontrol"},
    "custom/power":{"format":"⏻","tooltip":false,"on-click":"bash ~/.config/hypr/scripts/powermenu.sh"}
}
EOF

# ── Productive ─────────────────────────────────────────────────────────────────
cat > ~/.config/waybar/layouts/productive.jsonc << 'EOF'
{
    "layer":"top","position":"top","height":36,
    "margin-top":6,"margin-left":6,"margin-right":6,
    "spacing":4,"exclusive":true,
    "modules-left":["hyprland/workspaces","hyprland/window"],
    "modules-center":["clock"],
    "modules-right":["mpris","network","cpu","memory","pulseaudio","tray","custom/power"],
    "hyprland/workspaces":{"format":"{id}","on-click":"activate","sort-by-number":true,"persistent-workspaces":{"*":[1,2,3,4,5]}},
    "hyprland/window":{"format":"  {}","max-length":40,"separate-outputs":true},
    "clock":{"format":"󰥔 {:%H:%M}    󰃮 {:%a %d %b}","tooltip-format":"<tt>{calendar}</tt>"},
    "mpris":{"format":"♪ {title}","format-paused":"⏸ {title}","format-stopped":"","max-length":25,"interval":1},
    "cpu":{"format":"󰻠 {usage}%","interval":2,"on-click":"foot -e btop"},
    "memory":{"format":"󰍛 {percentage}%","interval":5},
    "network":{"format-wifi":"󰤨 {essid}","format-ethernet":"󰈀 Wired","format-disconnected":"󰤭","max-length":14,"on-click":"nm-connection-editor"},
    "pulseaudio":{"format":"{icon} {volume}%","format-muted":"󰝟","format-icons":{"default":["󰕿","󰖀","󰕾"]},"on-click":"pavucontrol","on-scroll-up":"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+","on-scroll-down":"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"},
    "tray":{"spacing":6,"icon-size":15},
    "custom/power":{"format":"⏻","tooltip":false,"on-click":"bash ~/.config/hypr/scripts/powermenu.sh"}
}
EOF

# ── Floating islands ────────────────────────────────────────────────────────────
cat > ~/.config/waybar/layouts/floating-left.jsonc << 'EOF'
{"layer":"top","position":"top","height":34,"margin-top":8,"margin-left":8,"margin-right":0,"spacing":4,"exclusive":false,"modules-left":["hyprland/workspaces"],"modules-center":[],"modules-right":[],"hyprland/workspaces":{"format":"{id}","on-click":"activate","sort-by-number":true,"persistent-workspaces":{"*":[1,2,3,4,5]}}}
EOF

cat > ~/.config/waybar/layouts/floating-center.jsonc << 'EOF'
{"layer":"top","position":"top","height":34,"margin-top":8,"margin-left":350,"margin-right":350,"spacing":4,"exclusive":false,"modules-left":[],"modules-center":["clock","mpris"],"modules-right":[],"clock":{"format":"{:%a %b %d  %H:%M}","tooltip-format":"<tt>{calendar}</tt>"},"mpris":{"format":"  ♪ {title}","format-paused":"  ⏸ {title}","format-stopped":"","max-length":24,"interval":1}}
EOF

cat > ~/.config/waybar/layouts/floating-right.jsonc << 'EOF'
{"layer":"top","position":"top","height":34,"margin-top":8,"margin-left":0,"margin-right":8,"spacing":4,"exclusive":false,"modules-left":[],"modules-center":[],"modules-right":["cpu","pulseaudio","network","tray","custom/power"],"cpu":{"format":"󰻠 {usage}%","interval":2,"on-click":"foot -e btop"},"network":{"format-wifi":"󰤨 {essid}","format-ethernet":"󰈀 Wired","format-disconnected":"󰤭","max-length":14},"pulseaudio":{"format":"{icon} {volume}%","format-muted":"󰝟","format-icons":{"default":["󰕿","󰖀","󰕾"]},"on-click":"pavucontrol"},"tray":{"spacing":6,"icon-size":15},"custom/power":{"format":"⏻","tooltip":false,"on-click":"bash ~/.config/hypr/scripts/powermenu.sh"}}
EOF

ok "Waybar layouts written"

# =============================================================================
# STEP 10 — ROFI THEMES
# =============================================================================
log "Writing rofi themes..."

# launcher.rasi — image 8 style (2 col, large icons, dark)
cat > ~/.config/rofi/launcher.rasi << 'EOF'
* {
    bg:      #1a1b26;
    bg2:     #16161e;
    bg3:     #292e42;
    fg:      #c0caf5;
    fg2:     #565f89;
    accent:  #7aa2f7;
    background-color: transparent;
    text-color: @fg;
}
window {
    background-color: @bg;
    border:           0px;
    border-radius:    14px;
    width:            700px;
    height:           520px;
}
mainbox {
    background-color: transparent;
    children: [inputbar, listview];
    spacing: 8px;
    padding: 14px;
}
inputbar {
    background-color: @bg3;
    border-radius: 10px;
    padding: 12px 16px;
    children: [prompt, entry];
    spacing: 8px;
    margin: 0 0 4px 0;
}
prompt { background-color:transparent; text-color:@fg2; }
entry {
    background-color: transparent;
    text-color: @fg;
    placeholder: "Search...";
    placeholder-color: @fg2;
}
listview {
    background-color: transparent;
    columns: 2;
    lines: 7;
    spacing: 4px;
    scrollbar: false;
    fixed-height: false;
}
element {
    background-color: transparent;
    border-radius: 8px;
    padding: 10px 12px;
    spacing: 10px;
    children: [element-icon, element-text];
}
element normal normal { background-color:transparent; text-color:@fg; }
element selected normal { background-color:@accent; text-color:@bg; border-radius:8px; }
element-icon { size:28px; background-color:transparent; }
element-text { background-color:transparent; text-color:inherit; vertical-align:0.5; }
EOF

# theme-switcher.rasi — image 1 style (minimal dark dropdown)
cat > ~/.config/rofi/theme-switcher.rasi << 'EOF'
* {
    bg:      #1a1b26;
    bg2:     #292e42;
    fg:      #c0caf5;
    fg2:     #565f89;
    accent:  #7aa2f7;
    background-color: transparent;
    text-color: @fg;
}
window {
    background-color: @bg;
    border: 1px;
    border-color: @fg2;
    border-radius: 12px;
    width: 380px;
    height: 300px;
}
mainbox {
    background-color: transparent;
    children: [inputbar, listview];
    spacing: 0px;
    padding: 0px;
}
inputbar {
    background-color: @bg;
    border-radius: 12px 12px 0 0;
    padding: 12px 16px;
    children: [prompt, entry];
    spacing: 8px;
    border: 0 0 1px 0;
    border-color: @fg2;
}
prompt { background-color:transparent; text-color:@fg2; }
entry {
    background-color: transparent;
    text-color: @fg;
    placeholder: "Search themes...";
    placeholder-color: @fg2;
}
listview {
    background-color: transparent;
    columns: 1;
    lines: 5;
    spacing: 0px;
    scrollbar: false;
    padding: 4px 0;
}
element {
    background-color: transparent;
    padding: 10px 18px;
    children: [element-text];
}
element normal normal { background-color:transparent; text-color:@fg; }
element selected normal { background-color:@bg2; text-color:@accent; }
element-text { background-color:transparent; text-color:inherit; vertical-align:0.5; }
EOF

# powermenu.rasi
cat > ~/.config/rofi/powermenu.rasi << 'EOF'
* {
    bg:      #1a1b26;
    bg2:     #292e42;
    fg:      #c0caf5;
    fg2:     #565f89;
    accent:  #f7768e;
    background-color: transparent;
    text-color: @fg;
}
window { background-color:@bg; border:1px; border-color:@fg2; border-radius:14px; width:220px; height:290px; }
mainbox { background-color:transparent; children:[listview]; padding:10px; }
listview { background-color:transparent; columns:1; lines:5; spacing:4px; scrollbar:false; }
element { background-color:transparent; border-radius:8px; padding:10px 14px; children:[element-text]; }
element normal normal { background-color:transparent; text-color:@fg; }
element selected normal { background-color:@bg2; text-color:@accent; }
element-text { background-color:transparent; text-color:inherit; vertical-align:0.5; }
EOF

ok "Rofi themes written"

# =============================================================================
# STEP 11 — FOOT TERMINAL
# =============================================================================
log "Writing foot config..."
cat > ~/.config/foot/foot.ini << 'EOF'
[main]
font=JetBrainsMono Nerd Font:size=12
dpi-aware=yes
pad=14x10

[scrollback]
lines=10000

[cursor]
style=block
blink=yes
blink-rate=600

[colors-dark]
background=1a1b26
foreground=c0caf5
regular0=16161e
regular1=f7768e
regular2=9ece6a
regular3=e0af68
regular4=7aa2f7
regular5=bb9af7
regular6=7dcfff
regular7=565f89
bright0=292e42
bright1=f7768e
bright2=9ece6a
bright3=e0af68
bright4=7aa2f7
bright5=bb9af7
bright6=7dcfff
bright7=c0caf5
selection-foreground=1a1b26
selection-background=7aa2f7

[key-bindings]
clipboard-copy=Control+Shift+c
clipboard-paste=Control+Shift+v
search-start=Control+Shift+f
font-increase=Control+equal
font-decrease=Control+minus
EOF

ok "Foot config written"

# =============================================================================
# STEP 12 — MAKO
# =============================================================================
log "Writing mako config..."
cat > ~/.config/mako/config << 'EOF'
background-color=#1a1b26ee
text-color=#c0caf5
border-color=#7aa2f7
border-radius=10
border-size=1
font=JetBrainsMono Nerd Font 11
padding=12,16
margin=8
width=320
height=100
layer=overlay
anchor=top-right
default-timeout=4000
max-visible=3

[urgency=high]
border-color=#f7768e
EOF
ok "Mako config written"

# =============================================================================
# STEP 13 — ZSH + STARSHIP
# =============================================================================
log "Writing shell config..."
cat > ~/.config/starship.toml << 'EOF'
format = "$directory$git_branch$git_status$character"
add_newline = false

[character]
success_symbol = "[→](bold #7aa2f7)"
error_symbol   = "[→](bold #f7768e)"

[directory]
style = "bold #bb9af7"
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = " "
style  = "bold #9ece6a"

[git_status]
style = "bold #e0af68"
EOF

if [ ! -f ~/.zshrc ] || ! grep -q "starship" ~/.zshrc; then
cat >> ~/.zshrc << 'ZSHEOF'

# Starship prompt
eval "$(starship init zsh)"

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la --color=auto'
alias grep='grep --color=auto'
ZSHEOF
fi
ok "Shell config written"

# =============================================================================
# STEP 14 — SDDM
# =============================================================================
log "Enabling SDDM..."
sudo systemctl enable sddm 2>/dev/null || warn "SDDM enable failed"

# Add Hyprland session if missing
if [ ! -f /usr/share/wayland-sessions/hyprland.desktop ]; then
    sudo mkdir -p /usr/share/wayland-sessions
    sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << 'SESS'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
SESS
fi
ok "SDDM enabled"

# =============================================================================
# STEP 15 — SCREENSHOTS DIR
# =============================================================================
mkdir -p ~/Pictures/Screenshots

# =============================================================================
# DONE
# =============================================================================
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║   saneaspect Rice Installed Successfully! 🎉     ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo "  Keybinds:"
echo "  ALT + Return     → Terminal (foot)"
echo "  ALT + D          → App Launcher (2-col with icons)"
echo "  ALT + T          → Theme Switcher (tokyonight/catppuccin/gruvbox/nord/rosepine)"
echo "  ALT + W          → Wallpaper Switcher"
echo "  ALT + SHIFT+W    → Random Wallpaper"
echo "  ALT + L          → Layout Switcher"
echo "  ALT + [          → Left Sidebar"
echo "  ALT + ]          → Right Sidebar"
echo "  Print            → Screenshot"
echo "  SHIFT+Print      → Area Screenshot"
echo ""
echo "  Layouts: saneaspect | saneaspect-v1 | saneaspect-centered"
echo "           minimal | productive | floating"
echo ""
echo "  Reboot and select Hyprland from SDDM!"
echo ""
echo -e "${YELLOW}  Reboot now? (y/N)${NC}"
read -r REBOOT
[[ "$REBOOT" =~ ^[Yy]$ ]] && sudo reboot
