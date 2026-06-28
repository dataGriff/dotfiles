# Tracked macOS system settings — single source of truth.
# Sourced by macos/apply.sh (writes them) and bin/dotfiles-doctor.sh (verifies them).
# Edit settings HERE only. Format per entry: domain|key|type|value
# Intent documented in docs/setup.md Part 5.

MACOS_SETTINGS=(
  "NSGlobalDomain|com.apple.swipescrolldirection|bool|false"
  "NSGlobalDomain|com.apple.mouse.tapBehavior|int|1"
  "com.apple.AppleMultitouchTrackpad|Clicking|bool|true"
  "com.apple.AppleMultitouchTrackpad|TrackpadThreeFingerDrag|bool|true"
  "NSGlobalDomain|com.apple.trackpad.scaling|float|3.0"
  "NSGlobalDomain|KeyRepeat|int|2"
  "NSGlobalDomain|InitialKeyRepeat|int|15"
  "com.apple.dock|autohide|bool|true"
  "com.apple.dock|show-recents|bool|false"
  "com.apple.dock|launchanim|bool|false"
  "com.apple.menuextra.clock|IsAnalog|bool|true"
)

MACOS_RESTART=(Dock ControlCenter SystemUIServer)
