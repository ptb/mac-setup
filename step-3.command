#!/bin/sh
if [ -z "$1" ]; then
  osascript > /dev/null <<-END
    tell app "Terminal" to do script "source ${0} 0"
END
  clear

else

function config_file_map () {
  if [ -x "/usr/local/bin/duti" ]; then
    printf "%s\t%s\t%s\n" \
      "org.videolan.vlc" "public.avi" "all" \
      "com.VortexApps.NZBVortex3" "dyn.ah62d4rv4ge8068xc" "all" \
      "com.apple.DiskImageMounter" "com.apple.disk-image" "all" \
      "com.apple.DiskImageMounter" "public.disk-image" "all" \
      "com.apple.DiskImageMounter" "public.iso-image" "all" \
      "com.apple.QuickTimePlayerX" "com.apple.coreaudio-format" "all" \
      "com.apple.QuickTimePlayerX" "com.apple.quicktime-movie" "all" \
      "com.apple.QuickTimePlayerX" "com.microsoft.waveform-audio" "all" \
      "com.apple.QuickTimePlayerX" "public.aifc-audio" "all" \
      "com.apple.QuickTimePlayerX" "public.aiff-audio" "all" \
      "com.apple.QuickTimePlayerX" "public.audio" "all" \
      "com.apple.QuickTimePlayerX" "public.mp3" "all" \
      "com.apple.Safari" "com.compuserve.gif" "all" \
      "com.apple.Terminal" "com.apple.terminal.shell-script" "all" \
      "com.apple.iTunes" "com.apple.iTunes.audible" "all" \
      "com.apple.iTunes" "com.apple.iTunes.ipg" "all" \
      "com.apple.iTunes" "com.apple.iTunes.ipsw" "all" \
      "com.apple.iTunes" "com.apple.iTunes.ite" "all" \
      "com.apple.iTunes" "com.apple.iTunes.itlp" "all" \
      "com.apple.iTunes" "com.apple.iTunes.itms" "all" \
      "com.apple.iTunes" "com.apple.iTunes.podcast" "all" \
      "com.apple.iTunes" "com.apple.m4a-audio" "all" \
      "com.apple.iTunes" "com.apple.mpeg-4-ringtone" "all" \
      "com.apple.iTunes" "com.apple.protected-mpeg-4-audio" "all" \
      "com.apple.iTunes" "com.apple.protected-mpeg-4-video" "all" \
      "com.apple.iTunes" "com.audible.aa-audio" "all" \
      "com.apple.iTunes" "public.mpeg-4-audio" "all" \
      "com.apple.installer" "com.apple.installer-package-archive" "all" \
      "com.github.atom" "com.apple.binary-property-list" "editor" \
      "com.github.atom" "com.apple.crashreport" "editor" \
      "com.github.atom" "com.apple.dt.document.ascii-property-list" "editor" \
      "com.github.atom" "com.apple.dt.document.script-suite-property-list" "editor" \
      "com.github.atom" "com.apple.dt.document.script-terminology-property-list" "editor" \
      "com.github.atom" "com.apple.log" "editor" \
      "com.github.atom" "com.apple.property-list" "editor" \
      "com.github.atom" "com.apple.rez-source" "editor" \
      "com.github.atom" "com.apple.symbol-export" "editor" \
      "com.github.atom" "com.apple.xcode.ada-source" "editor" \
      "com.github.atom" "com.apple.xcode.bash-script" "editor" \
      "com.github.atom" "com.apple.xcode.configsettings" "editor" \
      "com.github.atom" "com.apple.xcode.csh-script" "editor" \
      "com.github.atom" "com.apple.xcode.fortran-source" "editor" \
      "com.github.atom" "com.apple.xcode.ksh-script" "editor" \
      "com.github.atom" "com.apple.xcode.lex-source" "editor" \
      "com.github.atom" "com.apple.xcode.make-script" "editor" \
      "com.github.atom" "com.apple.xcode.mig-source" "editor" \
      "com.github.atom" "com.apple.xcode.pascal-source" "editor" \
      "com.github.atom" "com.apple.xcode.strings-text" "editor" \
      "com.github.atom" "com.apple.xcode.tcsh-script" "editor" \
      "com.github.atom" "com.apple.xcode.yacc-source" "editor" \
      "com.github.atom" "com.apple.xcode.zsh-script" "editor" \
      "com.github.atom" "com.apple.xml-property-list" "editor" \
      "com.github.atom" "com.barebones.bbedit.actionscript-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.erb-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.ini-configuration" "editor" \
      "com.github.atom" "com.barebones.bbedit.javascript-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.json-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.jsp-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.lasso-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.lua-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.setext-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.sql-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.tcl-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.tex-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.textile-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.vbscript-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.vectorscript-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.verilog-hdl-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.vhdl-source" "editor" \
      "com.github.atom" "com.barebones.bbedit.yaml-source" "editor" \
      "com.github.atom" "com.netscape.javascript-source" "editor" \
      "com.github.atom" "com.sun.java-source" "editor" \
      "com.github.atom" "dyn.ah62d4rv4ge80255drq" "all" \
      "com.github.atom" "dyn.ah62d4rv4ge80g55gq3w0n" "all" \
      "com.github.atom" "dyn.ah62d4rv4ge80g55sq2" "all" \
      "com.github.atom" "dyn.ah62d4rv4ge80y2xzrf0gk3pw" "all" \
      "com.github.atom" "dyn.ah62d4rv4ge81e3dtqq" "all" \
      "com.github.atom" "dyn.ah62d4rv4ge81e7k" "all" \
      "com.github.atom" "dyn.ah62d4rv4ge81g25xsq" "all" \
      "com.github.atom" "dyn.ah62d4rv4ge81g2pxsq" "all" \
      "com.github.atom" "net.daringfireball.markdown" "editor" \
      "com.github.atom" "public.assembly-source" "editor" \
      "com.github.atom" "public.c-header" "editor" \
      "com.github.atom" "public.c-plus-plus-source" "editor" \
      "com.github.atom" "public.c-source" "editor" \
      "com.github.atom" "public.csh-script" "editor" \
      "com.github.atom" "public.json" "editor" \
      "com.github.atom" "public.lex-source" "editor" \
      "com.github.atom" "public.log" "editor" \
      "com.github.atom" "public.mig-source" "editor" \
      "com.github.atom" "public.nasm-assembly-source" "editor" \
      "com.github.atom" "public.objective-c-plus-plus-source" "editor" \
      "com.github.atom" "public.objective-c-source" "editor" \
      "com.github.atom" "public.patch-file" "editor" \
      "com.github.atom" "public.perl-script" "editor" \
      "com.github.atom" "public.php-script" "editor" \
      "com.github.atom" "public.plain-text" "editor" \
      "com.github.atom" "public.precompiled-c-header" "editor" \
      "com.github.atom" "public.precompiled-c-plus-plus-header" "editor" \
      "com.github.atom" "public.python-script" "editor" \
      "com.github.atom" "public.ruby-script" "editor" \
      "com.github.atom" "public.script" "editor" \
      "com.github.atom" "public.shell-script" "editor" \
      "com.github.atom" "public.source-code" "editor" \
      "com.github.atom" "public.text" "editor" \
      "com.github.atom" "public.utf16-external-plain-text" "editor" \
      "com.github.atom" "public.utf16-plain-text" "editor" \
      "com.github.atom" "public.utf8-plain-text" "editor" \
      "com.github.atom" "public.xml" "editor" \
      "com.kodlian.Icon-Slate" "com.apple.icns" "all" \
      "com.kodlian.Icon-Slate" "com.microsoft.ico" "all" \
      "com.microsoft.Word" "public.rtf" "all" \
      "com.panayotis.jubler" "dyn.ah62d4rv4ge81g6xy" "all" \
      "com.sketchup.SketchUp.2016" "com.sketchup.skp" "all" \
      "com.vmware.fusion" "com.microsoft.windows-executable" "all" \
      "cx.c3.theunarchiver" "com.alcohol-soft.mdf-image" "all" \
      "cx.c3.theunarchiver" "com.allume.stuffit-archive" "all" \
      "cx.c3.theunarchiver" "com.altools.alz-archive" "all" \
      "cx.c3.theunarchiver" "com.amiga.adf-archive" "all" \
      "cx.c3.theunarchiver" "com.amiga.adz-archive" "all" \
      "cx.c3.theunarchiver" "com.apple.applesingle-archive" "all" \
      "cx.c3.theunarchiver" "com.apple.binhex-archive" "all" \
      "cx.c3.theunarchiver" "com.apple.bom-compressed-cpio" "all" \
      "cx.c3.theunarchiver" "com.apple.itunes.ipa" "all" \
      "cx.c3.theunarchiver" "com.apple.macbinary-archive" "all" \
      "cx.c3.theunarchiver" "com.apple.self-extracting-archive" "all" \
      "cx.c3.theunarchiver" "com.apple.xar-archive" "all" \
      "cx.c3.theunarchiver" "com.apple.xip-archive" "all" \
      "cx.c3.theunarchiver" "com.cyclos.cpt-archive" "all" \
      "cx.c3.theunarchiver" "com.microsoft.cab-archive" "all" \
      "cx.c3.theunarchiver" "com.microsoft.msi-installer" "all" \
      "cx.c3.theunarchiver" "com.nero.nrg-image" "all" \
      "cx.c3.theunarchiver" "com.network172.pit-archive" "all" \
      "cx.c3.theunarchiver" "com.nowsoftware.now-archive" "all" \
      "cx.c3.theunarchiver" "com.nscripter.nsa-archive" "all" \
      "cx.c3.theunarchiver" "com.padus.cdi-image" "all" \
      "cx.c3.theunarchiver" "com.pkware.zip-archive" "all" \
      "cx.c3.theunarchiver" "com.rarlab.rar-archive" "all" \
      "cx.c3.theunarchiver" "com.redhat.rpm-archive" "all" \
      "cx.c3.theunarchiver" "com.stuffit.archive.sit" "all" \
      "cx.c3.theunarchiver" "com.stuffit.archive.sitx" "all" \
      "cx.c3.theunarchiver" "com.sun.java-archive" "all" \
      "cx.c3.theunarchiver" "com.symantec.dd-archive" "all" \
      "cx.c3.theunarchiver" "com.winace.ace-archive" "all" \
      "cx.c3.theunarchiver" "com.winzip.zipx-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.arc-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.arj-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.dcs-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.dms-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.ha-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.lbr-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.lha-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.lhf-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.lzx-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.packdev-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.pax-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.pma-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.pp-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.xmash-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.zoo-archive" "all" \
      "cx.c3.theunarchiver" "cx.c3.zoom-archive" "all" \
      "cx.c3.theunarchiver" "org.7-zip.7-zip-archive" "all" \
      "cx.c3.theunarchiver" "org.archive.warc-archive" "all" \
      "cx.c3.theunarchiver" "org.debian.deb-archive" "all" \
      "cx.c3.theunarchiver" "org.gnu.gnu-tar-archive" "all" \
      "cx.c3.theunarchiver" "org.gnu.gnu-zip-archive" "all" \
      "cx.c3.theunarchiver" "org.gnu.gnu-zip-tar-archive" "all" \
      "cx.c3.theunarchiver" "org.tukaani.lzma-archive" "all" \
      "cx.c3.theunarchiver" "org.tukaani.xz-archive" "all" \
      "cx.c3.theunarchiver" "public.bzip2-archive" "all" \
      "cx.c3.theunarchiver" "public.cpio-archive" "all" \
      "cx.c3.theunarchiver" "public.tar-archive" "all" \
      "cx.c3.theunarchiver" "public.tar-bzip2-archive" "all" \
      "cx.c3.theunarchiver" "public.z-archive" "all" \
      "cx.c3.theunarchiver" "public.zip-archive" "all" \
      "cx.c3.theunarchiver" "public.zip-archive.first-part" "all" \
      "org.gnu.Emacs" "dyn.ah62d4rv4ge8086xh" "all" \
      "org.inkscape.Inkscape" "public.svg-image" "editor" \
      "org.videolan.vlc" "com.apple.m4v-video" "all" \
      "org.videolan.vlc" "com.microsoft.windows-media-wmv" "all" \
      "org.videolan.vlc" "org.perian.matroska" "all" \
      "org.videolan.vlc" "org.videolan.ac3" "all" \
      "org.videolan.vlc" "org.videolan.ogg-audio" "all" \
      "org.videolan.vlc" "public.ac3-audio" "all" \
      "org.videolan.vlc" "public.audiovisual-content" "all" \
      "org.videolan.vlc" "public.avi" "all" \
      "org.videolan.vlc" "public.movie" "all" \
      "org.videolan.vlc" "public.mpeg" "all" \
      "org.videolan.vlc" "public.mpeg-2-video" "all" \
      "org.videolan.vlc" "public.mpeg-4" "all" \
      > "${HOME}/.duti"

      /usr/local/bin/duti "${HOME}/.duti"
    fi

    sudo mkdir -p /var/db/lsd
    sudo chown root:admin /var/db/lsd
    sudo chmod 775 /var/db/lsd

    /System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister -kill -r -domain local -domain system -domain user
  fi
}

function config_finder () {
### Finder > Preferences… > General

  # Show these items on the desktop: Hard disks: on
  defaults write 'com.apple.finder' 'ShowHardDrivesOnDesktop' -bool false

  # Show these items on the desktop: External disks: on
  defaults write 'com.apple.finder' 'ShowExternalHardDrivesOnDesktop' -bool false

  # Show these items on the desktop: CDs, DVDs, and iPods: on
  defaults write 'com.apple.finder' 'ShowRemovableMediaOnDesktop' -bool false

  # Show these items on the desktop: Connected servers: on
  defaults write 'com.apple.finder' 'ShowMountedServersOnDesktop' -bool true

  # New Finder windows show: ${HOME}
  defaults write 'com.apple.finder' 'NewWindowTarget' -string 'PfHm'
  defaults write 'com.apple.finder' 'NewWindowTargetPath' -string "file://${HOME}/"

### Finder > Preferences… > Advanced

  # Show all filename extensions: on
  defaults write -g 'AppleShowAllExtensions' -bool true

  # Show warning before emptying the Trash: on
  defaults write 'com.apple.finder' 'WarnOnEmptyTrash' -bool false

### View

  # Show Path Bar
  defaults write 'com.apple.finder' 'ShowPathbar' -bool true

  # Show Status Bar
  defaults write 'com.apple.finder' 'ShowStatusBar' -bool true

  # Customize Toolbar…
  defaults write 'com.apple.finder' 'NSToolbar Configuration Browser' '{ "TB Item Identifiers" = ( "com.apple.finder.BACK", "com.apple.finder.PATH", "com.apple.finder.SWCH", "com.apple.finder.ARNG", "NSToolbarFlexibleSpaceItem", "com.apple.finder.SRCH", "com.apple.finder.ACTN" ); "TB Display Mode" = 2; }'

### View > Show View Options: [${HOME}]

  # Show Library Folder: on
  chflags nohidden "${HOME}/Library"

### Window

  # Copy
  defaults write 'com.apple.finder' 'CopyProgressWindowLocation' -string '{2160, 23}'
}

function config_safari () {
### Safari > Preferences… > General

  # New windows open with: Empty Page
  defaults write 'com.apple.Safari' 'NewWindowBehavior' -int 1

  # New tabs open with: Empty Page
  defaults write 'com.apple.Safari' 'NewTabBehavior' -int 1

  # Homepage: about:blank
  defaults write 'com.apple.Safari' 'HomePage' -string 'about:blank'

### Safari > Preferences… > Tabs

  # Open pages in tabs instead of windows: Always
  defaults write 'com.apple.Safari' 'TabCreationPolicy' -int 2

### Safari > Preferences… > AutoFill

  # Using info from my Contacts card: off
  defaults write 'com.apple.Safari' 'AutoFillFromAddressBook' -bool false

  # Credit cards: off
  defaults write 'com.apple.Safari' 'AutoFillCreditCardData' -bool false

  # Other forms: off
  defaults write 'com.apple.Safari' 'AutoFillMiscellaneousForms' -bool false

### Safari > Preferences… > Search

  # Include Spotlight Suggestions: off
  defaults write 'com.apple.Safari' 'UniversalSearchEnabled' -bool false

  # Show Favorites: off
  defaults write 'com.apple.Safari' 'ShowFavoritesUnderSmartSearchField' -bool false

### Safari > Preferences… > Privacy

  # Website use of location services: Deny without prompting
  defaults write 'com.apple.Safari' 'SafariGeolocationPermissionPolicy' -int 0

  # Ask websites not to track me: on
  defaults write 'com.apple.Safari' 'SendDoNotTrackHTTPHeader' -bool true

### Safari > Preferences… > Notifications

  # Allow websites to ask for permission to send push notifications: off
  defaults write 'com.apple.Safari' 'CanPromptForPushNotifications' -bool false

### Safari > Preferences… > Advanced

  # Smart Search Field: Show full website address: on
  defaults write 'com.apple.Safari' 'ShowFullURLInSmartSearchField' -bool true

  # Default encoding: Unicode (UTF-8)
  defaults write 'com.apple.Safari' 'WebKitDefaultTextEncodingName' -string 'utf-8'
  defaults write 'com.apple.Safari' 'com.apple.Safari.ContentPageGroupIdentifier.WebKit2DefaultTextEncodingName' -string 'utf-8'

  # Show Develop menu in menu bar: on
  defaults write 'com.apple.Safari' 'IncludeDevelopMenu' -bool true
  defaults write 'com.apple.Safari' 'WebKitDeveloperExtrasEnabledPreferenceKey' -bool true
  defaults write 'com.apple.Safari' 'com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled' -bool true

### View

  # Show Favorites Bar
  defaults write 'com.apple.Safari' 'ShowFavoritesBar-v2' -bool true

  # Show Status Bar
  defaults write 'com.apple.Safari' 'ShowStatusBar' -bool true
  defaults write 'com.apple.Safari' 'ShowStatusBarInFullScreen' -bool true
}

function config_system_prefs () {
### General

  # Appearance: Graphite
  defaults write -g 'AppleAquaColorVariant' -int 6

  # Use dark menu bar and Dock: on
  defaults write -g 'AppleInterfaceStyle' -string 'Dark'

  # Highlight color: Other… #CC99CC
  defaults write -g 'AppleHighlightColor' -string '0.600000 0.800000 0.600000'

  # Sidebar icon size: Small
  defaults write -g 'NSTableViewDefaultSizeMode' -int 1

  # Show scroll bars: Always
  defaults write -g 'AppleShowScrollBars' -string 'Always'

  # Click in the scroll bar to: Jump to the next page
  defaults write -g 'AppleScrollerPagingBehavior' -bool false

  # Ask to keep changes when closing documents: on
  defaults write -g 'NSCloseAlwaysConfirmsChanges' -bool true

  # Close windows when quitting an app: on
  defaults write -g 'NSQuitAlwaysKeepsWindows' -bool false

  # Recent items: None
  osascript <<-EOF
    tell application "System Events"
      tell appearance preferences
        set recent documents limit to 0
        set recent applications limit to 0
        set recent servers limit to 0
      end tell
    end tell
EOF

  # Use LCD font smoothing when available: on
  defaults -currentHost delete -g 'AppleFontSmoothing' 2> /dev/null

### Desktop & Screen Saver

  # Desktop: Solid Colors: Custom Color… Solid Black
  mkdir -m go= -p "${HOME}/Library/Desktop Pictures/Solid Colors/"
  base64 -D > "${HOME}/Library/Desktop Pictures/Solid Colors/Solid Black.png" <<-EOF
iVBORw0KGgoAAAANSUhEUgAAAIAAAACAAQAAAADrRVxmAAAAGElEQVR4AWOgMxgFo2AUjIJRMApG
wSgAAAiAAAH3bJXBAAAAAElFTkSuQmCC
EOF
  osascript <<-EOF
    tell application "System Events"
      set a to POSIX file "${HOME}/Library/Desktop Pictures/Solid Colors/Solid Black.png"
      set b to a reference to every desktop
      repeat with c in b
        set picture of c to a
      end repeat
    end tell
EOF

  # Screen Saver: BlankScreen
  if [ -e "/Library/Screen Savers/BlankScreen.saver" ]; then
    defaults -currentHost write 'com.apple.screensaver' 'moduleDict' '{ moduleName = BlankScreen; path = "/Library/Screen Savers/BlankScreen.saver"; type = 0; }'
  fi

  # Screen Saver: Start after: Never
  defaults -currentHost write 'com.apple.screensaver' 'idleTime' -int 0

  # Screen Saver: Hot Corners… Top Left: ⌘ Mission Control
  defaults write 'com.apple.dock' 'wvous-tl-corner' -int 2
  defaults write 'com.apple.dock' 'wvous-tl-modifier' -int 1048576

  # Screen Saver: Hot Corners… Bottom Left: Put Display to Sleep
  defaults write 'com.apple.dock' 'wvous-bl-corner' -int 10
  defaults write 'com.apple.dock' 'wvous-bl-modifier' -int 0

### Dock

  # Size: 32
  defaults write 'com.apple.dock' 'tilesize' -int 32

  # Magnification: off
  defaults write 'com.apple.dock' 'magnification' -bool false
  defaults write 'com.apple.dock' 'largesize' -int 64

  # Position on screen: Left
  defaults write 'com.apple.dock' 'orientation' -string 'right'

  # Minimize windows using: Scale effect
  defaults write 'com.apple.dock' 'mineffect' -string 'scale'

  # Animate opening applications: off
  defaults write 'com.apple.dock' 'launchanim' -bool false

### Security & Privacy

  # General: Require password: on
  defaults write 'com.apple.screensaver' 'askForPassword' -int 1

  # General: Require password: 5 seconds after sleep or screen saver begins
  defaults write 'com.apple.screensaver' 'askForPasswordDelay' -int 5

### Energy Saver

  # Power > Turn display off after: 20 min
  sudo pmset -c displaysleep 20

  # Power > Prevent computer from sleeping automatically when the display is off: enabled
  sudo pmset -c sleep 0

  # Power > Put hard disks to sleep when possible: 60 min
  sudo pmset -c disksleep 60

  # Power > Wake for Ethernet network access: enabled
  sudo pmset -c womp 1

  # Power > Start up automatically after a power failure: enabled
  sudo pmset -c autorestart 1

  # Power > Enable Power Nap: enabled
  sudo pmset -c powernap 1

### Mouse

  # Scroll direction: natural: off
  defaults write -g 'com.apple.swipescrolldirection' -bool false

### Trackpad

  # Point & Click: Tap to click: on
  defaults -currentHost write -g 'com.apple.mouse.tapBehavior' -int 1

### Sound

  # Sound Effects: Select an alert sound: Sosumi
  defaults write 'com.apple.systemsound' 'com.apple.sound.beep.sound' -string '/System/Library/Sounds/Sosumi.aiff'

  # Sound Effects: Play user interface sound effects: off
  defaults write 'com.apple.systemsound' 'com.apple.sound.uiaudio.enabled' -int 0

  # Sound Effects: Play feedback when volume is changed: off
  defaults write -g 'com.apple.sound.beep.feedback' -int 0

### Sharing

  # Computer Name
  sudo systemsetup -setcomputername $(hostname -s | perl -nE 'say ucfirst' | perl -np -e 'chomp')

  # Local Hostname
  sudo systemsetup -setlocalsubnetname $(hostname -s) &> /dev/null

### Users & Groups

  # Current User > Advanced Options… > Login shell: /usr/local/bin/zsh
  sudo sh -c 'printf "%s\n" "/usr/local/bin/zsh" >> /etc/shells'
  sudo chsh -s /usr/local/bin/zsh
  chsh -s /usr/local/bin/zsh
  sudo mkdir -p /private/var/root/Library/Caches/
  sudo touch "/private/var/root/.zshrc"
  touch "${HOME}/.zshrc"

### Dictation & Speech

  # Dictation: Dictation: On
  defaults write 'com.apple.speech.recognition.AppleSpeechRecognition.prefs' 'DictationIMMasterDictationEnabled' -bool true
  defaults write 'com.apple.speech.recognition.AppleSpeechRecognition.prefs' 'DictationIMIntroMessagePresented' -bool true

  # Dictation: Use Enhanced Dictation: on
  if [ -d '/System/Library/Speech/Recognizers/SpeechRecognitionCoreLanguages/en_US.SpeechRecognition' ]; then
    defaults write 'com.apple.speech.recognition.AppleSpeechRecognition.prefs' 'DictationIMPresentedOfflineUpgradeSuggestion' -bool true
    defaults write 'com.apple.speech.recognition.AppleSpeechRecognition.prefs' 'DictationIMSIFolderWasUpdated' -bool true
    defaults write 'com.apple.speech.recognition.AppleSpeechRecognition.prefs' 'DictationIMUseOnlyOfflineDictation' -bool true
  fi

  # Text to Speech: System Voice: Allison
  if [ -d '/System/Library/Speech/Voices/Allison.SpeechVoice' ]; then
    defaults write 'com.apple.speech.voice.prefs' 'VisibleIdentifiers' '{ "com.apple.speech.synthesis.voice.allison.premium" = 1; }'
    defaults write 'com.apple.speech.voice.prefs' 'SelectedVoiceName' -string 'Allison'
    defaults write 'com.apple.speech.voice.prefs' 'SelectedVoiceCreator' -int 1886745202
    defaults write 'com.apple.speech.voice.prefs' 'SelectedVoiceID' -int 184555197
  fi

### Date & Time

  # Clock: Display the time with seconds: on / Show date: on
  defaults write 'com.apple.menuextra.clock' 'DateFormat' -string 'EEE MMM d  h:mm:ss a'

### Accessibility

  # Display: Reduce transparency: on
  defaults write 'com.apple.universalaccess' 'reduceTransparency' -bool true

### Restart defaults server

  killall -u "$USER" cfprefsd
  osascript -e 'tell app "Finder" to quit'
  osascript -e 'tell app "Dock" to quit'
}

function create_zshrc () {
  sudo tee /etc/zshrc > /dev/null <<-EOF
alias -g ...="../.."
alias -g ....="../../.."
alias -g .....="../../../.."
alias l="/bin/ls -lG"
alias ll="/bin/ls -alG"
alias lr="/bin/ls -alRG"
alias screen="/usr/bin/screen -U"
autoload -U compaudit
compaudit | xargs -L 1 sudo chown -HR root:wheel {} 2> /dev/null
compaudit | xargs -L 1 sudo chmod -HR go-w {} 2> /dev/null
autoload -U compinit
compinit -d "\${HOME}/Library/Caches/zcompdump"
bindkey "\e[3~" delete-char
bindkey "\e[A" up-line-or-search
bindkey "\e[B" down-line-or-search
export HISTFILE="\${HOME}/Library/Caches/zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt APPEND_HISTORY
setopt AUTO_CD
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY
setopt PROMPT_SUBST
setopt SHARE_HISTORY
stty erase \b
# Correctly display UTF-8 with combining characters.
if [ "\$TERM_PROGRAM" = "Apple_Terminal" ]; then
  setopt combiningchars
fi
EOF
}

function config_all () {
  config_file_map
  config_finder
  config_safari
  config_system_prefs
  create_zshrc
}

clear
cat <<-END

Enter any of these commands:
  config_file_map
  config_finder
  config_safari
  config_system_prefs
  create_zshrc

Or:
  config_all

END
fi
