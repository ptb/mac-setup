#!/bin/sh
if [ -z "$1" ]; then
  if [[ ! $SHELL == *"zsh" ]]; then
    chsh -s /bin/zsh
  fi

  osascript << EOF
tell app "Terminal" to do script "source ${0} 0"
EOF
  clear
else

CACHE="/Volumes/Install"
DOMAIN="ptb2.me"
MAIL="mail.${DOMAIN}"

MAS="$(getconf DARWIN_USER_CACHE_DIR)com.apple.appstore"

function p () {
  printf "\n\033[1m\033[34m%s\033[0m\n\n" "${1}"
}

function init_sudoers () {
  p "Disable repeated requests for password"

  printf "%s\t%s\n" \
    "timeout" "Defaults:%admin timestamp_timeout=-1" \
    "installer" "%admin ALL=(ALL) NOPASSWD:SETENV: /usr/sbin/installer" \
    "tty_tickets" 'Defaults:%admin !tty_tickets' \
  | while IFS=$'\t' read a b; do
    sudo tee "/etc/sudoers.d/${a}" <<< "${b}" > /dev/null
  done
}

function init_no_sleep () {
  p "Disable system and disk sleep"

  sudo pmset -a sleep 0
  sudo pmset -a disksleep 0
}

function init_hostname () {
  p "Set computer name and local hostname"

sudo systemsetup -setcomputername $(ruby -e "print '$(hostname -s)'.capitalize") &> /dev/null

sudo systemsetup -setlocalsubnetname $(hostname -s) &> /dev/null

}

function init_perms () {
  p "Set permissions on install destinations"

  for c in \
    "/Library/ColorPickers" \
    "/Library/Fonts" \
    "/Library/Input Methods" \
    "/Library/PreferencePanes" \
    "/Library/QuickLook" \
    "/Library/Screen Savers" \
    "/usr/local" \
  ; do
    sudo chgrp -R admin "${c}"
    sudo chmod -R g+w "${c}"
  done

  if [ ! -d "/usr/local/bin" ]; then
    mkdir -m o-w -p "/usr/local/bin"
  fi
}

function init_devtools () {
  p "Install developer tools"

  if [ -d "${CACHE}/Updates" ]; then
    sudo chown -R "${USER}" "/Library/Updates"
    rsync -a --delay-updates \
      "${CACHE}/Updates/" "/Library/Updates/"
  fi

  xcode-select --install
}

function init_updater () {
  p "Install macOS updates"

  if [ -d "${CACHE}/Updates" ]; then
    sudo chown -R "${USER}" "/Library/Updates"
    rsync -a --delay-updates \
      "${CACHE}/Updates/" "/Library/Updates/"
  fi

  sudo softwareupdate --install --all
}

function init_account () {
  p "Create primary user account"

  /bin/echo -n "Real name: " && read NAME
  /bin/echo -n "Account name: " && read U
  /bin/echo -n "Email address: " && read EMAIL

  sudo chgrp admin "/Library/User Pictures"
  sudo chmod g+w "/Library/User Pictures"
  curl "https://www.gravatar.com/avatar/$(md5 -qs $EMAIL).jpg?s=512" --silent \
    --compressed --location --output "/Library/User Pictures/${EMAIL}.jpg" \

  sudo defaults write \
    "/System/Library/User Template/Non_localized/Library/Preferences/.GlobalPreferences.plist" \
    "com.apple.swipescrolldirection" -bool false

  sudo sysadminctl -addUser "${U}" -fullName "${NAME}" -password - \
    -shell "/bin/zsh" -admin -picture "/Library/User Pictures/${EMAIL}.jpg"

  p "Press any key to log out."
  /usr/bin/read -n 1 -s

  osascript -e 'tell application "loginwindow" to «event aevtrlgo»'
}

function init () {
  init_sudoers
  init_no_sleep
  init_hostname
  init_perms
  init_devtools
  init_updater
  init_account
}

function install_caches () {
  if [ -d "${CACHE}/Homebrew" ]; then
    p "Restore Homebrew caches from backup"

    rsync -a --delay-updates \
      "${CACHE}/Homebrew/" "${HOME}/Library/Caches/Homebrew/"
  fi

  if [ -d "${CACHE}/Updates" ]; then
    p "Restore App Store caches from backup"

    sudo chown -R "${USER}" "${MAS}"
    rsync -a --delay-updates \
      "${CACHE}/App Store/" "${MAS}/"
  fi
}

function install_paths () {
  if ! grep -Fq "/usr/local/sbin" /etc/paths; then
    p "Add '/usr/local/sbin' to default \$PATH"

    sudo sed -i -e "/\/usr\/sbin/{x;s/$/\/usr\/local\/sbin/;G;}" /etc/paths
  fi
}

function install_brew () {
  p "Install Homebrew"

  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  brew analytics off

  brew update
  brew doctor

  brew tap "homebrew/bundle"

cat > /usr/local/Brewfile << EOF
cask_args colorpickerdir: "/Library/ColorPickers",
  fontdir: "/Library/Fonts",
  input_methoddir: "/Library/Input Methods",
  prefpanedir: "/Library/PreferencePanes",
  qlplugindir: "/Library/QuickLook",
  screen_saverdir: "/Library/Screen Savers"

tap "homebrew/bundle"
tap "caskroom/cask"

brew "mas"
mas "autoping", id: 632347870

cask "docker-toolbox"
cask "java"
cask "vmware-fusion"

cask "xquartz"
cask "inkscape"
cask "wireshark"

brew "aspell",
  args: ["lang=en"]
brew "chromedriver"
brew "coreutils"
tap "homebrew/services"
brew "dovecot",
  args: [
  "with-pam",
  "with-pigeonhole",
  "with-pigeonhole-unfinished-features"]
brew "duti"
brew "fdupes"
brew "gawk"
brew "getmail"
brew "git"
brew "gnu-sed",
  args: ["with-default-names"]
brew "gnupg"
brew "gpac"
brew "hub"
brew "ievms"
brew "imagemagick"
brew "mercurial"
brew "mp4v2"
brew "mtr"
brew "nmap"
brew "node"
brew "openssl"
brew "pinentry-mac"
brew "python"
brew "python3"
brew "rsync"
brew "ruby"
brew "selenium-server-standalone"
brew "sqlite"
brew "stow"
brew "terminal-notifier"
brew "trash"
brew "vim"
brew "wget"
brew "youtube-dl"
brew "zsh"

cask "adium"
cask "airfoil"
cask "alfred"
cask "arduino"
cask "atom"
cask "autodmg"
cask "bbedit"
cask "caffeine"
cask "carbon-copy-cloner"
cask "charles"
cask "dash"
cask "dropbox"
cask "duet"
cask "exifrenamer"
cask "firefox"
cask "flux"
cask "github-desktop"
cask "gitup"
cask "google-chrome"
cask "handbrake"
cask "hermes"
cask "imageoptim"
cask "integrity"
cask "istat-menus"
cask "jubler"
cask "little-snitch"
cask "machg"
cask "makemkv"
cask "menubar-countdown"
cask "meteorologist"
cask "moom"
cask "mp4tools"
cask "munki"
cask "musicbrainz-picard"
cask "namechanger"
cask "nvalt"
cask "nzbget"
cask "nzbvortex"
cask "openemu"
cask "opera"
cask "pacifist"
cask "platypus"
cask "plex-media-server"
cask "quitter"
cask "rescuetime"
cask "scrivener"
cask "sitesucker"
cask "sizeup"
cask "sketch"
cask "sketchup"
cask "skitch"
cask "skype"
cask "slack"
cask "sonarr"
cask "sonarr-menu"
cask "sourcetree"
cask "steermouse"
cask "subler"
cask "sublime-text"
cask "the-unarchiver"
cask "time-sink"
cask "torbrowser"
cask "tower"
cask "transmit"
cask "vimr"
cask "vlc"
cask "xld"

tap "railwaycat/emacsmacport"
cask "railwaycat/emacsmacport/emacs-mac-spacemacs-icon"

tap "caskroom/fonts"
cask "caskroom/fonts/font-inconsolata-lgc"

tap "caskroom/versions"
cask "caskroom/versions/safari-technology-preview"

tap "ptb/custom"
cask "ptb/custom/adobe-creative-cloud-2014"
cask "ptb/custom/blankscreen"
cask "ptb/custom/composer"
cask "ptb/custom/enhanced-dictation"
cask "ptb/custom/ipmenulet"
cask "ptb/custom/pcalc-3"
cask "ptb/custom/sketchup-pro"
cask "ptb/custom/synergy"

mas "1Password", id: 443987910
mas "Coffitivity", id: 659901392
mas "Growl", id: 467939042
mas "HardwareGrowler", id: 475260933
mas "I Love Stars", id: 402642760
mas "Icon Slate", id: 439697913
mas "Justnotes", id: 511230166
mas "Keynote", id: 409183694
mas "Numbers", id: 409203825
mas "Pages", id: 409201541
mas "WiFi Explorer", id: 494803304

tap "homebrew/nginx"
brew "homebrew/nginx/nginx-full",
  args: [
  "with-dav-ext-module",
  "with-fancyindex-module",
  "with-gzip-static",
  "with-http2",
  "with-mp4-h264-module",
  "with-passenger",
  "with-push-stream-module",
  "with-secure-link",
  "with-webdav" ]

brew "ptb/custom/ffmpeg",
  args: [
  "with-chromaprint",
  "with-fdk-aac",
  "with-fontconfig",
  "with-freetype",
  "with-frei0r",
  "with-game-music-emu",
  "with-lame",
  "with-libass",
  "with-libbluray",
  "with-libbs2b",
  "with-libcaca",
  "with-libgsm",
  "with-libmodplug",
  "with-libsoxr",
  "with-libssh",
  "with-libvidstab",
  "with-libvorbis",
  "with-libvpx",
  "with-opencore-amr",
  "with-openh264",
  "with-openjpeg",
  "with-openssl",
  "with-opus",
  "with-pkg-config",
  "with-rtmpdump",
  "with-rubberband",
  "with-schroedinger",
  "with-sdl2",
  "with-snappy",
  "with-speex",
  "with-tesseract",
  "with-texi2html",
  "with-theora",
  "with-tools",
  "with-two-lame",
  "with-wavpack",
  "with-webp",
  "with-x264",
  "with-x265",
  "with-xvid",
  "with-xz",
  "with-yasm",
  "with-zeromq",
  "with-zimg" ]

mas "Xcode", id: 497799835
EOF
}

function install_macos_sw () {
  p "Install macOS software with Homebrew"

  cd /usr/local/ && brew bundle && cd "${HOME}"

  if [ -d "/Applications/Xcode.app" ]; then
    sudo xcodebuild -license accept
  fi

  brew upgrade
}

function install_links () {
  p "Link System and Xcode utilities to Applications"

  brew linkapps 2> /dev/null
  cd /Applications \
    && for a in /System/Library/CoreServices/Applications/*; do
      ln -s "../..$a" . 2> /dev/null
    done && \
  cd "${HOME}"

  if [ -d "/Applications/Xcode.app" ]; then
    cd /Applications \
      && for b in /Applications/Xcode.app/Contents/Applications/*; do
        ln -s "../..$b" . 2> /dev/null
      done \
      && for c in /Applications/Xcode.app/Contents/Developer/Applications/*; do
        ln -s "../..$c" . 2> /dev/null
      done && \
    cd "${HOME}"
  fi
}

function install () {
  install_caches
  install_paths
  install_brew
  install_macos_sw
  install_links
  #install_node_sw
  #install_python_sw
  #install_ruby_sw

  which prefs
}

function prefs_autoping () {
  defaults write -app autoping Hostname -string "google.com"
  defaults write -app autoping LaunchAtLogin -bool true
  defaults write -app autoping ShowNotifications -bool true
  defaults write -app autoping ShowPacketLossText -bool true
}

function prefs_finder () {
  p "Set Finder preferences"

defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false

defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

defaults write -globalDomain AppleShowAllExtensions -bool true

defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool true

defaults write com.apple.finder WarnOnEmptyTrash -bool false

defaults write com.apple.finder ShowPathbar -bool true

defaults write com.apple.finder ShowStatusBar -bool true

defaults write com.apple.finder "NSToolbar Configuration Browser" '{ "TB Item Identifiers" = ( "com.apple.finder.BACK", "com.apple.finder.PATH", "com.apple.finder.SWCH", "com.apple.finder.ARNG", "NSToolbarFlexibleSpaceItem", "com.apple.finder.SRCH", "com.apple.finder.ACTN" ); "TB Display Mode" = 2; }'

chflags nohidden "${HOME}/Library"

defaults write com.apple.finder CopyProgressWindowLocation -string "{2160, 23}"

}

function prefs_moom () {
  p "Set Moom preferences"

defaults write -app Moom "Allow For Drawers" -bool true

defaults write -app Moom "Grid Spacing" -bool true
defaults write -app Moom "Grid Spacing: Gap" -int 2
defaults write -app Moom "Grid Spacing: Apply To Edges" -bool false

defaults write -app Moom "Stealth Mode" -bool true

defaults write -app Moom "Application Mode" -int 2

defaults write -app Moom "Mouse Controls Grid" -bool true
defaults write -app Moom "Mouse Controls Grid: Columns" -int 10
defaults write -app Moom "Mouse Controls Grid: Rows" -int 6

defaults write -app Moom "Mouse Controls Include Custom Controls" -bool true

defaults write -app Moom "Mouse Controls Auto-Activate Window" -bool true

defaults write -app Moom "Snap" -bool false

defaults write -app Moom "Custom Controls" -array-add '{ Action = 19; "Relative Frame" = "{{0, 0.33333}, {0.5, 0.66666}}"; }'
defaults write -app Moom "Custom Controls" -array-add '{ Action = 19; "Relative Frame" = "{{0, 0}, {0.3, 0.33333}}"; }'
defaults write -app Moom "Custom Controls" -array-add '{ Action = 19; "Relative Frame" = "{{0.4, 0.33333}, {0.3, 0.66666}}"; }'
defaults write -app Moom "Custom Controls" -array-add '{ Action = 19; "Relative Frame" = "{{0.3, 0}, {0.4, 0.33333}}"; }'
defaults write -app Moom "Custom Controls" -array-add '{ Action = 19; "Relative Frame" = "{{0.7, 0.66666}, {0.3, 0.33333}}"; }'
defaults write -app Moom "Custom Controls" -array-add '{ Action = 19; "Relative Frame" = "{{0.7, 0.33333}, {0.3, 0.33333}}"; }'
defaults write -app Moom "Custom Controls" -array-add '{ Action = 19; "Relative Frame" = "{{0.7, 0}, {0.3, 0.33333}}"; }'

defaults write -app Moom "Configuration Grid: Columns" -int 10
defaults write -app Moom "Configuration Grid: Rows" -int 6

}

function prefs_nvalt () {
  p "Set nvALT preferences"

defaults write -app nvALT TableFontPointSize -int 11

defaults write -app nvALT AppActivationKeyCode -int -1
defaults write -app nvALT AppActivationModifiers -int -1

defaults write -app nvALT AutoCompleteSearches -bool true

defaults write -app nvALT ConfirmNoteDeletion -bool true

defaults write -app nvALT QuitWhenClosingMainWindow -bool false

defaults write -app nvALT StatusBarItem -bool true

defaults write -app nvALT ShowDockIcon -bool false

defaults write -app nvALT PastePreservesStyle -bool false

defaults write -app nvALT CheckSpellingInNoteBody -bool false

defaults write -app nvALT TabKeyIndents -bool true

defaults write -app nvALT UseSoftTabs -bool true

defaults write -app nvALT MakeURLsClickable -bool true

defaults write -app nvALT AutoSuggestLinks -bool false

defaults write -app nvALT UseMarkdownImport -bool false

defaults write -app nvALT UseReadability -bool false

defaults write -app nvALT rtl -bool false

defaults write -app nvALT UseAutoPairing -bool true

defaults write -app nvALT DefaultEEIdentifier -string "org.gnu.Emacs"
defaults write -app nvALT UserEEIdentifiers -array "com.apple.TextEdit" "org.gnu.Emacs"

defaults write -app nvALT NoteBodyFont -data 040b73747265616d747970656481e803840140848484064e53466f6e741e8484084e534f626a65637400858401692884055b3430635d060000001e000000fffe49006e0063006f006e0073006f006c006100740061004c004700430000008401660d8401630098019800980086

defaults write -app nvALT HighlightSearchTerms -bool true

defaults write -app nvALT SearchTermHighlightColor -data 040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a65637400858401630184046666666683cdcc4c3f0183cdcc4c3f0186

defaults write -app nvALT ForegroundTextColor -data 040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a65637400858401630184046666666683cdcc4c3f83cdcc4c3f83cdcc4c3f0186

defaults write -app nvALT BackgroundTextColor -data 040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a65637400858401630184046666666683d1d0d03d83d1d0d03d83d1d0d03d0186

defaults write -app nvALT ShowGrid -bool true

defaults write -app nvALT AlternatingRows -bool true

defaults write -app nvALT UseETScrollbarsOnLion -bool false

defaults write -app nvALT KeepsMaxTextWidth -bool true

defaults write -app nvALT NoteBodyMaxWidth -int 650

defaults write -app nvALT HorizontalLayout -bool false

defaults write -app nvALT NoteAttributesVisible -array "Title" "Tags"

defaults write -app nvALT TableIsReverseSorted -bool true
defaults write -app nvALT TableSortColumn -string "Date Modified"

defaults write -app nvALT TableColumnsHaveBodyPreview -bool true

}

function prefs_safari () {
  p "Set Safari preferences"

defaults write -app Safari AlwaysRestoreSessionAtLaunch -bool false
defaults write -app Safari OpenPrivateWindowWhenNotRestoringSessionAtLaunch -bool false

defaults write -app Safari NewWindowBehavior -int 1

defaults write -app Safari NewTabBehavior -int 1

defaults write -app Safari AutoOpenSafeDownloads -bool false

defaults write -app Safari TabCreationPolicy -int 2

defaults write -app Safari AutoFillFromAddressBook -bool false

defaults write -app Safari AutoFillPasswords -bool true

defaults write -app Safari AutoFillCreditCardData -bool false

defaults write -app Safari AutoFillMiscellaneousForms -bool false

defaults write -app Safari SuppressSearchSuggestions -bool false

defaults write -app Safari UniversalSearchEnabled -bool false

defaults write -app Safari WebsiteSpecificSearchEnabled -bool true

defaults write -app Safari PreloadTopHit -bool true

defaults write -app Safari ShowFavoritesUnderSmartSearchField -bool false

defaults write -app Safari SafariGeolocationPermissionPolicy -int 0

defaults write -app Safari SendDoNotTrackHTTPHeader -bool true

defaults write -app Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2ApplePayCapabilityDisclosureAllowed" -bool true

defaults write -app Safari CanPromptForPushNotifications -bool false

defaults write -app Safari ShowFullURLInSmartSearchField -bool true

defaults write -app Safari WebKitDefaultTextEncodingName -string "utf-8"
defaults write -app Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DefaultTextEncodingName" -string "utf-8"

defaults write -app Safari IncludeDevelopMenu -bool true
defaults write -app Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write -app Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

defaults write -app Safari "ShowFavoritesBar-v2" -bool true

defaults write -app Safari AlwaysShowTabBar -bool true

defaults write -app Safari ShowStatusBar -bool true
defaults write -app Safari ShowStatusBarInFullScreen -bool true

}

function prefs_general () {
  p "Set System preferences"

defaults write -globalDomain "AppleAquaColorVariant" -int 6

defaults write -globalDomain "AppleInterfaceStyle" -string "Dark"

defaults write -globalDomain "_HIHideMenuBar" -bool false

defaults write -globalDomain "AppleHighlightColor" -string "0.600000 0.800000 0.600000"

defaults write -globalDomain "NSTableViewDefaultSizeMode" -int 1

defaults write -globalDomain "AppleShowScrollBars" -string "Always"

defaults write -globalDomain "AppleScrollerPagingBehavior" -bool false

defaults write -globalDomain "NSCloseAlwaysConfirmsChanges" -bool true

defaults write -globalDomain "NSQuitAlwaysKeepsWindows" -bool false

osascript << EOF
  tell application "System Events"
    tell appearance preferences
      set recent documents limit to 0
      set recent applications limit to 0
      set recent servers limit to 0
    end tell
  end tell
EOF

defaults -currentHost write com.apple.coreservices.useractivityd "ActivityAdvertisingAllowed" -bool true
defaults -currentHost write com.apple.coreservices.useractivityd "ActivityReceivingAllowed" -bool true

defaults -currentHost delete -globalDomain "AppleFontSmoothing" 2> /dev/null

}

function prefs_screensaver () {

defaults -currentHost write com.apple.screensaver "idleTime" -int 0

defaults write com.apple.dock "wvous-tl-corner" -int 2
defaults write com.apple.dock "wvous-tl-modifier" -int 1048576

defaults write com.apple.dock "wvous-bl-corner" -int 10
defaults write com.apple.dock "wvous-bl-modifier" -int 0

}

function prefs_dock () {

defaults write com.apple.dock "tilesize" -int 32

defaults write com.apple.dock "magnification" -bool false
defaults write com.apple.dock "largesize" -int 64

defaults write com.apple.dock "orientation" -string "right"

defaults write com.apple.dock "mineffect" -string "scale"

defaults write -globalDomain "AppleWindowTabbingMode" -string "always"

defaults write -globalDomain "AppleActionOnDoubleClick" -string "None"

defaults write com.apple.dock "minimize-to-application" -bool true

defaults write com.apple.dock "launchanim" -bool false

defaults write com.apple.dock "autohide" -bool true

defaults write com.apple.dock "show-process-indicators" -bool true

}

function prefs_security () {

defaults write com.apple.screensaver "askForPassword" -int 1
defaults write com.apple.screensaver "askForPasswordDelay" -int 5

}

function prefs_power () {

sudo pmset -c displaysleep 20

sudo pmset -c sleep 0

sudo pmset -c disksleep 60

sudo pmset -c womp 1

sudo pmset -c autorestart 1

sudo pmset -c powernap 1

}

function prefs_ups () {

sudo pmset -u displaysleep 2

sudo pmset -u lessbright 1

sudo pmset -u haltafter 5

sudo pmset -u haltremain -1

sudo pmset -u haltlevel -1

}

function prefs_text () {

defaults write -globalDomain NSAutomaticCapitalizationEnabled -bool false

defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

defaults write -globalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

}

function prefs_mouse () {

defaults write -globalDomain com.apple.swipescrolldirection -bool false

}

function prefs_trackpad () {

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -globalDomain com.apple.mouse.tapBehavior -int 1

}

function prefs_sound () {

defaults write -globalDomain "com.apple.sound.beep.sound" -string "/System/Library/Sounds/Sosumi.aiff"

defaults write -globalDomain "com.apple.sound.uiaudio.enabled" -int 0

defaults write -globalDomain "com.apple.sound.beep.feedback" -int 0

}

function prefs_clock () {
  defaults write com.apple.menuextra.clock "DateFormat" -string "EEE MMM d  h:mm:ss a"
}

function prefs_accessibility () {
  defaults write com.apple.universalaccess "reduceTransparency" -bool true
}

function prefs_restart () {
  killall -u "$(whoami)" cfprefsd
  osascript -e 'tell app "Finder" to quit'
  killall Finder
}

function prefs_vlc () {
  p "Set VLC preferences"

  if [ ! -d "${HOME}/Library/Preferences/org.videolan.vlc" ]; then
    mkdir -m o-w -p "${HOME}/Library/Preferences/org.videolan.vlc"
  fi

  cat > "${HOME}/Library/Preferences/org.videolan.vlc/vlcrc" << EOF
avcodec-hw=vda
macosx-appleremote=0
macosx-continue-playback=1
macosx-nativefullscreenmode=1
macosx-pause-minimized=1
macosx-video-autoresize=0
spdif=1
sub-language=English
subsdec-encoding=UTF-8
volume-save=0
EOF
}

function prefs () {
  prefs_autoping
  prefs_finder
  prefs_moom
  prefs_nvalt
  prefs_safari

  prefs_general
  prefs_screensaver
  prefs_dock
  prefs_security
  prefs_power
  prefs_ups
  prefs_text
  prefs_mouse
  prefs_trackpad
  prefs_sound
  prefs_clock
  prefs_accessibility

  prefs_restart

  prefs_vlc

  which config
}

function config_mas () {
  p "Save App Store packages"

  cat > "/usr/local/bin/mas_save.sh" << EOF
#!/bin/sh
DIR="\${HOME}/Downloads/App Store"
MAS="\$(getconf DARWIN_USER_CACHE_DIR)com.apple.appstore"

mkdir -m go= -p "\${DIR}"
for a in \$(find "\${MAS}" -iname "[0-9]*" -type d); do
  b="\${DIR}/\$(basename \$a)"
  mkdir -m go= -p "\${b}"
  end=\$(( \$(date +%s) + 5 ))
  while [ \$(date +%s) -lt \$end ]; do
    for c in \${a}/*; do
      d="\$(basename \$c)"
      if [ ! -e "\${b}/\${d}" ]; then
        ln "\${a}/\${d}" "\${b}/\${d}"
      fi
    done
  done
done
EOF

  chmod a+x "/usr/local/bin/mas_save.sh"
  rehash

mkdir -m go= -p "${HOME}/Library/LaunchAgents"
launchctl unload "${HOME}/Library/LaunchAgents/com.github.ptb.mas_save.plist" 2> /dev/null
printf "%s\n" \
  "add ':KeepAlive' bool false" \
  "add ':Label' string 'com.github.ptb.mas_save'" \
  "add ':Program' string '/usr/local/bin/mas_save.sh'" \
  "add ':RunAtLoad' bool true" \
  "add ':WatchPaths' array" \
  "add ':WatchPaths:0' string '$(getconf DARWIN_USER_CACHE_DIR)com.apple.appstore'" \
| while IFS=$'\t' read a; do
  /usr/libexec/PlistBuddy "${HOME}/Library/LaunchAgents/com.github.ptb.mas_save.plist" -c "${a}" &> /dev/null
done
launchctl load "${HOME}/Library/LaunchAgents/com.github.ptb.mas_save.plist"

}

function config_atom () {
  p "Install Atom packages"

  for a in \
    "MagicPython" \
    "atom-beautify" \
    "atom-css-comb" \
    "atom-jade" \
    "atom-wallaby" \
    "autoclose-html" \
    "autocomplete-python" \
    "busy-signal" \
    "double-tag" \
    "editorconfig" \
    "ex-mode" \
    "file-icons" \
    "git-plus" \
    "git-time-machine" \
    "highlight-selected" \
    "intentions" \
    "language-docker" \
    "language-jade" \
    "language-javascript-jsx" \
    "language-lisp" \
    "language-slim" \
    "linter" \
    "linter-eslint" \
    "linter-rubocop" \
    "linter-ui-default" \
    "python-yapf" \
    "react" \
    "riot" \
    "sort-lines" \
    "term3" \
    "tomorrow-night-eighties-syntax" \
    "tree-view-open-files" \
    "vim-mode" \
    "vim-mode-zz" \
    "vim-surround" \
  ; do
    apm install "${a}"
  done

cat > "${HOME}/.atom/packages/tomorrow-night-eighties-syntax/styles/colors.less" \
  << EOF
@background: #191919;
@current-line: #333333;
@selection: #4c4c4c;
@foreground: #cccccc;
@comment: #999999;
@red: #f27f7f;
@orange: #ff994c;
@yellow: #ffcc66;
@green: #99cc99;
@aqua: #66cccc;
@blue: #6699cc;
@purple: #cc99cc;
EOF
}

function config_bbedit () {
  if [ -d "/Applications/BBEdit.app" ]; then
    p "Install BBEdit tools"

    cd /usr/local/bin && \
    ln ../../../Applications/BBEdit.app/Contents/Helpers/bbdiff bbdiff && \
    ln ../../../Applications/BBEdit.app/Contents/Helpers/bbedit_tool bbedit && \
    ln ../../../Applications/BBEdit.app/Contents/Helpers/bbfind bbfind && \
    ln ../../../Applications/BBEdit.app/Contents/Helpers/bbresults bbresults && \
    cd "${HOME}"
  fi
}

function config_desktop () {
  p "Set Desktop preferences"

sudo rm "/Library/Caches/com.apple.desktop.admin.png"
base64 -D > "/Library/Caches/com.apple.desktop.admin.png" <<< "iVBORw0KGgoAAAANSUhEUgAAAIAAAACAAQAAAADrRVxmAAAAGElEQVR4AWOgMxgFo2AUjIJRMApGwSgAAAiAAAH3bJXBAAAAAElFTkSuQmCC"

osascript << EOF
  tell application "System Events"
    set a to POSIX file "/Library/Caches/com.apple.desktop.admin.png"
    set b to a reference to every desktop
    repeat with c in b
      set picture of c to a
    end repeat
  end tell
EOF

if [ -e "/Library/Screen Savers/BlankScreen.saver" ]; then
  p "Set Screen Saver preferences"

  defaults -currentHost write com.apple.screensaver moduleDict \
    '{ moduleName = "BlankScreen"; path = "/Library/Screen Savers/BlankScreen.saver"; type = 0; }'
fi

}

function config_dock () {
  p "Set Dock preferences"

  defaults write com.apple.dock "autohide-delay" -float 0
  defaults write com.apple.dock "autohide-time-modifier" -float 0.5

  defaults delete com.apple.dock "persistent-apps"

  for app in \
    "nvALT" \
    "Mail" \
    "Safari" \
    "Messages" \
    "Emacs" \
    "Atom" \
    "Utilities/Terminal" \
    "System Preferences" \
    "PCalc" \
    "iTunes" \
    "VLC" \
  ; do
    defaults write com.apple.dock "persistent-apps" -array-add \
      "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/${app}.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
  done

  defaults delete com.apple.dock "persistent-others"

  osascript -e 'tell app "Dock" to quit'
}

function config_emacs () {
  p "Configure Emacs"

  mkdir -m go= -p "${HOME}/.emacs.d" \
    && curl --compressed --location --silent \
      "https://github.com/syl20bnr/spacemacs/archive/master.tar.gz" \
    | tar -C "${HOME}/.emacs.d" --strip-components 1 -xf -
  mkdir -m go= -p "${HOME}/.emacs.d/private/ptb"

cat > "${HOME}/.spacemacs" << EOF
(defun dotspacemacs/layers ()
  (setq-default
    dotspacemacs-configuration-layers '(
      auto-completion
      (colors :variables
        colors-colorize-identifiers 'variables)
      dash
      deft
      docker
      emacs-lisp
      evil-cleverparens
      git
      github
      helm
      html
      ibuffer
      imenu-list
      javascript
      markdown
      nginx
      (org :variables
        org-enable-github-support t)
      (osx :variables
        osx-use-option-as-meta nil)
      ptb
      react
      ruby
      ruby-on-rails
      search-engine
      semantic
      shell-scripts
      (spell-checking :variables
        spell-checking-enable-by-default nil)
      syntax-checking
      (version-control :variables
        version-control-diff-side 'left)
      vim-empty-lines
    )
    dotspacemacs-excluded-packages '(org-bullets)
  )
)

(defun dotspacemacs/init ()
  (setq-default
    dotspacemacs-startup-banner nil
    dotspacemacs-startup-lists nil
    dotspacemacs-scratch-mode 'org-mode
    dotspacemacs-themes '(sanityinc-tomorrow-eighties)
    dotspacemacs-default-font '(
      "Inconsolata LGC"
      :size 13
      :weight normal
      :width normal
      :powerline-scale 1.1)
    dotspacemacs-loading-progress-bar nil
    dotspacemacs-active-transparency 100
    dotspacemacs-inactive-transparency 100
    dotspacemacs-line-numbers t
    dotspacemacs-whitespace-cleanup 'all
  )
)

(defun dotspacemacs/user-init ())
(defun dotspacemacs/user-config ())
EOF

cat > "${HOME}/.emacs.d/private/ptb/config.el" << EOF
(setq
  default-frame-alist '(
    (top . 22)
    (left . 1790)
    (height . 40)
    (width . 91)
    (vertical-scroll-bars . right))
  initial-frame-alist (copy-alist default-frame-alist)

  deft-directory "~/Dropbox/Notes"
  focus-follows-mouse t
  mouse-wheel-follow-mouse t
  mouse-wheel-scroll-amount '(1 ((shift) . 1))
  purpose-display-at-right 20
  recentf-max-saved-items 5
  scroll-step 1
  system-uses-terminfo nil

  ibuffer-formats '(
    (mark modified read-only " "
    (name 18 18 :left :elide)))

  ibuffer-shrink-to-minimum-size t
  ibuffer-always-show-last-buffer nil
  ibuffer-sorting-mode 'recency
  ibuffer-use-header-line nil
  x-select-enable-clipboard nil)

(global-linum-mode t)
(recentf-mode t)
(x-focus-frame nil)
(with-eval-after-load 'org
  (org-babel-do-load-languages
    'org-babel-load-languages '(
      (ruby . t)
      (shell . t)
    )
  )
)
EOF

cat > "${HOME}/.emacs.d/private/ptb/funcs.el" << EOF
(defun is-useless-buffer (buffer)
  (let ((name (buffer-name buffer)))
    (and (= ?* (aref name 0))
        (string-match "^\\**" name))))

(defun kill-useless-buffers ()
  (interactive)
  (loop for buffer being the buffers
        do (and (is-useless-buffer buffer) (kill-buffer buffer))))

(defun org-babel-tangle-hook ()
  (add-hook 'after-save-hook 'org-babel-tangle))

(add-hook 'org-mode-hook #'org-babel-tangle-hook)

(defun ptb/new-untitled-buffer ()
  "Create a new untitled buffer in the current frame."
  (interactive)
  (let
    ((buffer "Untitled-") (count 1))
    (while
      (get-buffer (concat buffer (number-to-string count)))
      (setq count (1+ count)))
    (switch-to-buffer
    (concat buffer (number-to-string count))))
  (org-mode))

(defun ptb/previous-buffer ()
  (interactive)
  (kill-useless-buffers)
  (previous-buffer))

(defun ptb/next-buffer ()
  (interactive)
  (kill-useless-buffers)
  (next-buffer))

(defun ptb/kill-current-buffer ()
  (interactive)
  (kill-buffer (current-buffer))
  (kill-useless-buffers))
EOF

cat > "${HOME}/.emacs.d/private/ptb/keybindings.el" << EOF
(define-key evil-normal-state-map (kbd "s-c") 'clipboard-kill-ring-save)
(define-key evil-insert-state-map (kbd "s-c") 'clipboard-kill-ring-save)
(define-key evil-visual-state-map (kbd "s-c") 'clipboard-kill-ring-save)

(define-key evil-ex-completion-map (kbd "s-v") 'clipboard-yank)
(define-key evil-ex-search-keymap (kbd "s-v") 'clipboard-yank)
(define-key evil-insert-state-map (kbd "s-v") 'clipboard-yank)

(define-key evil-normal-state-map (kbd "s-x") 'clipboard-kill-region)
(define-key evil-insert-state-map (kbd "s-x") 'clipboard-kill-region)
(define-key evil-visual-state-map (kbd "s-x") 'clipboard-kill-region)

(define-key evil-normal-state-map (kbd "<S-up>") 'evil-previous-visual-line)
(define-key evil-insert-state-map (kbd "<S-up>") 'evil-previous-visual-line)
(define-key evil-visual-state-map (kbd "<S-up>") 'evil-previous-visual-line)

(define-key evil-normal-state-map (kbd "<S-down>") 'evil-next-visual-line)
(define-key evil-insert-state-map (kbd "<S-down>") 'evil-next-visual-line)
(define-key evil-visual-state-map (kbd "<S-down>") 'evil-next-visual-line)

(global-set-key (kbd "C-l") 'evil-search-highlight-persist-remove-all)

(global-set-key (kbd "s-t") 'make-frame)
(global-set-key (kbd "s-n") 'ptb/new-untitled-buffer)
(global-set-key (kbd "s-w") 'ptb/kill-this-buffer)
(global-set-key (kbd "s-{") 'ptb/previous-buffer)
(global-set-key (kbd "s-}") 'ptb/next-buffer)
EOF

cat > "${HOME}/.emacs.d/private/ptb/packages.el" << EOF
(setq ptb-packages '(auto-indent-mode inline-crypt))

(defun ptb/init-auto-indent-mode ()
  (use-package auto-indent-mode
    :init
    (setq
      auto-indent-delete-backward-char t
      auto-indent-fix-org-auto-fill t
      auto-indent-fix-org-move-beginning-of-line t
      auto-indent-fix-org-return t
      auto-indent-fix-org-yank t
      auto-indent-start-org-indent t
    )
  )
)

(defun ptb/init-inline-crypt ()
  (use-package inline-crypt :init))
EOF

}

function config_vi_script () {
  p "Create vi script"

  cat > /usr/local/bin/vi <<-EOF
#!/bin/sh

if [ -e "/Applications/Emacs.app" ]; then
  t=()

  if [ \${#@} -ne 0 ]; then
    while IFS= read -r file; do
      [ ! -f "\$file" ] && t+=("\$file") && /usr/bin/touch "\$file"
      file=\$(echo \$(cd \$(dirname "\$file") && pwd -P)/\$(basename "\$file"))
      \$(/usr/bin/osascript <<-END
        if application "Emacs.app" is running then
          tell application id (id of application "Emacs.app") to open POSIX file "\$file"
        else
          tell application ((path to applications folder as text) & "Emacs.app")
            activate
            open POSIX file "\$file"
          end tell
        end if
END
        ) &  # Note: END on the previous line may be indented with tabs but not spaces
      done <<<"\$(printf '%s\n' "\$@")"
    fi

    if [ ! -z "\$t" ]; then
      \$(/bin/sleep 10; for file in "\${t[@]}"; do
        [ ! -s "\$file" ] && /bin/rm "\$file";
      done) &
    fi
  else
    vim -No "\$@"
  fi
EOF

  chmod a+x /usr/local/bin/vi
  rehash
}
function config_terminal () {
  p "Set Terminal preferences"
defaults write -app Terminal "Startup Window Settings" -string "$(whoami)"
defaults write -app Terminal "Default Window Settings" -string "$(whoami)"

/usr/libexec/PlistBuddy -c "delete ':Window Settings:$(whoami)'" \
  "${HOME}/Library/Preferences/com.apple.Terminal.plist" &> /dev/null

for terminal_prop in \
" dict" \
":name string '$(whoami)'" \
":type string 'Window Settings'" \
":ProfileCurrentVersion real 2.05" \
':BackgroundColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC4xIDAuMSAwLjE=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
":BackgroundBlur real 0" \
":BackgroundSettingsForInactiveWindows bool false" \
":BackgroundAlphaInactive real 1" \
":BackgroundBlurInactive real 0" \
':Font data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>3</integer></dict><key>NSName</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSSize</key><real>13</real><key>NSfFlags</key><integer>16</integer></dict><string>InconsolataLGC</string><dict><key>$classes</key><array><string>NSFont</string><string>NSObject</string></array><key>$classname</key><string>NSFont</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
":FontWidthSpacing real 1" \
":FontHeightSpacing real 1" \
":FontAntialias bool true" \
":UseBoldFonts bool true" \
":BlinkText bool false" \
":DisableANSIColor bool false" \
":UseBrightBold bool false" \
':TextColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDAuOCAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':TextBoldColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDAuOCAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':SelectionColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC4zIDAuMyAwLjM=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBlackColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC4zIDAuMyAwLjM=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIRedColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC45NSAwLjUgMC41</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIGreenColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC42IDAuOCAwLjY=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIYellowColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MSAwLjggMC40</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBlueColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC40IDAuNiAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIMagentaColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDAuNiAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSICyanColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC40IDAuOCAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIWhiteColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDAuOCAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBrightBlackColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC41IDAuNSAwLjU=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBrightRedColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MSAwLjcgMC43</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBrightGreenColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDEgMC44</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBrightYellowColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MSAxIDAuNg==</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBrightBlueColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC42IDAuOCAx</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBrightMagentaColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MSAwLjggMQ==</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBrightCyanColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC42IDEgMQ==</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
':ANSIBrightWhiteColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC45IDAuOSAwLjk=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
":CursorType integer 0" \
":CursorBlink bool false" \
':CursorColor data <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC43IDAuNyAwLjc=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>' \
":ShowRepresentedURLInTitle bool true" \
":ShowRepresentedURLPathInTitle bool true" \
":ShowActiveProcessInTitle bool true" \
":ShowActiveProcessArgumentsInTitle bool false" \
":ShowShellCommandInTitle bool false" \
":ShowWindowSettingsNameInTitle bool false" \
":ShowTTYNameInTitle bool false" \
":ShowDimensionsInTitle bool false" \
":ShowCommandKeyInTitle bool false" \
":columnCount integer 124" \
":rowCount integer 20" \
":ShouldLimitScrollback integer 0" \
":ScrollbackLines integer 0" \
":ShouldRestoreContent bool false" \
":ShowRepresentedURLInTabTitle bool false" \
":ShowRepresentedURLPathInTabTitle bool false" \
":ShowActiveProcessInTabTitle bool true" \
":ShowActiveProcessArgumentsInTabTitle bool false" \
":ShowTTYNameInTabTitle bool false" \
":ShowComponentsWhenTabHasCustomTitle bool true" \
":ShowActivityIndicatorInTab bool true" \
":shellExitAction integer 1" \
":warnOnShellCloseAction integer 1" \
":useOptionAsMetaKey bool false" \
":ScrollAlternateScreen bool true" \
":TerminalType string 'xterm-256color'" \
":deleteSendsBackspace bool false" \
":EscapeNonASCIICharacters bool true" \
":ConvertNewlinesOnPaste bool true" \
":StrictVTKeypad bool true" \
":scrollOnInput bool true" \
":Bell bool false" \
":VisualBell bool false" \
":VisualBellOnlyWhenMuted bool false" \
":BellBadge bool false" \
":BellBounce bool false" \
":BellBounceCritical bool false" \
":CharacterEncoding integer 4" \
":SetLanguageEnvironmentVariables bool true" \
":EastAsianAmbiguousWide bool false" \
; do
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.Terminal.plist" \
    -c "add ':Window Settings:$(whoami)'${terminal_prop}"
done
}

function config_dovecot () {
  p "Enable email authentication with macOS accounts"

  sudo tee "/etc/pam.d/dovecot" > /dev/null << EOF
auth		required	pam_opendirectory.so try_first_pass
account		required	pam_nologin.so
account		required	pam_opendirectory.so
password	required	pam_opendirectory.so
EOF

  p "Configure Dovecot email server"

  cat > "/usr/local/etc/dovecot/dovecot.conf" << EOF
auth_mechanisms = cram-md5
default_internal_user = _dovecot
default_login_user = _dovenull
log_path = /dev/stderr
mail_location = maildir:~/.mail:INBOX=~/.mail/Inbox:LAYOUT=fs
mail_plugins = zlib
maildir_copy_with_hardlinks = no
namespace {
  inbox = yes
  mailbox Drafts {
    auto = subscribe
    special_use = \Drafts
  }
  mailbox Junk {
    auto = subscribe
    special_use = \Junk
  }
  mailbox Sent {
    auto = subscribe
    special_use = \Sent
  }
  mailbox "Sent Messages" {
    special_use = \Sent
  }
  mailbox Trash {
    auto = subscribe
    special_use = \Trash
  }
  separator = .
  type = private
}
passdb {
  args = scheme=cram-md5 /usr/local/etc/dovecot/cram-md5.pwd
  driver = passwd-file

  # driver = pam

  # args = nopassword=y
  # driver = static
}
plugin {
  sieve = file:/Users/%u/.sieve
  zlib_save = bz2
  zlib_save_level = 9
}
postmaster_address = ${USER}@${DOMAIN}
protocols = imap
service imap-login {
  inet_listener imap {
    port = 0
  }
}
ssl = required
ssl_cert = <${SSL}/certs/${MAIL}/${MAIL}.crt
ssl_cipher_list = AES128+EECDH:AES128+EDH
ssl_dh_parameters_length = 4096
ssl_key = <${SSL}/certs/${MAIL}/${MAIL}.key
ssl_prefer_server_ciphers = yes
ssl_protocols = !SSLv2 !SSLv3
userdb {
  driver = passwd
}
protocol lda {
  mail_plugins = sieve
}

# auth_debug = yes
# auth_debug_passwords = yes
# auth_verbose = yes
# auth_verbose_passwords = plain
# mail_debug = yes
# verbose_ssl = yes
EOF

  if [ ! -f "/usr/local/etc/dovecot/cram-md5.pwd" ]; then
    p "Create email account for '${USER}' with 'CRAM-MD5' authentication: "
    doveadm pw | sed -e "s/^/${USER}:/" > "/usr/local/etc/dovecot/cram-md5.pwd"
    sudo chown _dovecot "/usr/local/etc/dovecot/cram-md5.pwd"
    sudo chmod go= "/usr/local/etc/dovecot/cram-md5.pwd"
  fi

  if ! /usr/bin/grep -Fq ${MAIL} "/etc/hosts"; then
    printf "127.0.0.1\t${MAIL}\n" | sudo tee -a /etc/hosts > /dev/null
  fi

  sudo brew services start dovecot
}

function config_getmail () {
  p "Configure getmail"

  mkdir -m go= -p "${HOME}/.getmail" "${HOME}/Library/LaunchAgents"

  printf "%s\n" \
    "add ':KeepAlive' bool false" \
    "add ':Label' string 'ca.pyropus.getmail'" \
    "add ':ProgramArguments' array" \
    "add ':ProgramArguments:0' string '/usr/local/bin/getmail'" \
    "add ':RunAtLoad' bool true" \
    "add ':StandardOutPath' string '${HOME}/.getmail/getmail.log'" \
    "add ':StandardErrorPath' string '${HOME}/.getmail/getmail.err'" \
    "add ':StartInterval' integer 300" \
  | while read a; do
    /usr/libexec/PlistBuddy "${HOME}/Library/LaunchAgents/ca.pyropus.getmail.plist" -c "${a}" &> /dev/null
  done

  for email in \
    "pbosse@gmail.com" \
    "ptb@ioutime.com" \
  ; do
    p "Add password for '${email}' to Keychain"

    security add-internet-password -a "${email}" -s "imap.gmail.com" -r "imap" \
      -l "${email}" -D "getmail password" -P 993 -w

    cat > "${HOME}/.getmail/${email}" << EOF
[retriever]
type = SimpleIMAPSSLRetriever
server = imap.gmail.com
port = 993
username = ${email}
mailboxes = ("[Gmail]/All Mail",)

[destination]
type = MDA_external
path = /usr/local/Cellar/dovecot/2.2.31/libexec/dovecot/dovecot-lda
arguments = ("-c","/usr/local/etc/dovecot/dovecot.conf","-d","$(whoami)",)
ignore_stderr = true

[options]
# delete = true
delete_after = 30
delivered_to = false
read_all = false
received = false
verbose = 1
EOF

  defaults write "${HOME}/Library/LaunchAgents/ca.pyropus.getmail" \
    ProgramArguments -array-add "--rcfile"
  defaults write "${HOME}/Library/LaunchAgents/ca.pyropus.getmail" \
    ProgramArguments -array-add "${email}"
  done

  plutil -convert xml1 "${HOME}/Library/LaunchAgents/ca.pyropus.getmail.plist"
  launchctl load "${HOME}/Library/LaunchAgents/ca.pyropus.getmail.plist"

  # http://shadow-file.blogspot.com/2012/06/parsing-email-and-fixing-timestamps-in.html
  curl -L https://pastebin.com/raw/ZBq7euid | tr -d '\015' > /usr/local/bin/timestamp.py
  chmod +x /usr/local/bin/timestamp.py
}

function config_git () {
  p "Configure git"

  KEY="$(gpg -K --with-colons | awk -F: '/^sec/ { a=$5 } END { print a }')"

  git config --global user.name "Peter T Bosse II"
  git config --global user.email "ptb@ioutime.com"

  git config --global alias.cm "commit --allow-empty-message --message="
  git config --global alias.co "checkout"
  git config --global alias.st "status"

  git config --global push.default "simple"

  if [ ! -z ${KEY} ]; then
    git config --global user.signingkey "${KEY}"
    git config --global gpg.program "$(which gpg)"
    git config --global commit.gpgsign "true"
    git config --global tag.gpgsign "true"
    git config --global log.showSignature "true"
  fi
}

function config_gpg () {
  p "Create GPG keys"

  mkdir -m go= -p "${HOME}/.gnupg"

  echo "keyid-format long" \
    > "${HOME}/.gnupg/gpg.conf"
  echo "pinentry-program $(which pinentry-mac)" \
    > "${HOME}/.gnupg/gpg-agent.conf"

  gpg --faked-system-time '20170701T120000!' \
    --quick-generate-key "Peter T Bosse II <ptb@ioutime.com>" \
    future-default default never
}

function config_gpg_help () {
  KEY="$(gpg -K --with-colons | awk -F: '/^sec/ { a=$5 } END { print a }')"
  gpg --armor --export "${KEY}" | pbcopy
  open "https://github.com/settings/keys"
}

function config_openssl () {
  p "Create OpenSSL certificates"

  SSL="/usr/local/etc/openssl"
  DOMAIN="ptb2.me"
  MAIL="mail.${DOMAIN}"
  FAKE="0701080017"
  DAYS=3652

mkdir -p "${SSL}/certs/${DOMAIN}"
cat > "${SSL}/certs/${DOMAIN}/${DOMAIN}.cnf" << EOF
[ req ]
default_bits = 4096
default_keyfile = ${SSL}/certs/${DOMAIN}/${DOMAIN}.key
default_md = sha256
distinguished_name = dn
encrypt_key = no
prompt = no
utf8 = yes
x509_extensions = v3_ca

[ dn ]
CN = ${DOMAIN}

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = CA:true
EOF

openssl genrsa -out "${SSL}/certs/${DOMAIN}/${DOMAIN}.key" 4096

p "Set fake '${DOMAIN}' certificate creation date"
sudo date "${FAKE}" && \
openssl req -days ${DAYS} -new -x509 \
  -config "${SSL}/certs/${DOMAIN}/${DOMAIN}.cnf" \
  -key "${SSL}/certs/${DOMAIN}/${DOMAIN}.key" \
  -out "${SSL}/certs/${DOMAIN}/${DOMAIN}.crt" && \
sudo ntpdate -u time.apple.com

p "Password for adding certificate to Keychain Access"
openssl pkcs12 -aes256 -clcerts -export \
  -in "${SSL}/certs/${DOMAIN}/${DOMAIN}.crt" \
  -inkey "${SSL}/certs/${DOMAIN}/${DOMAIN}.key" \
  -out "${SSL}/certs/${DOMAIN}/${DOMAIN}.p12"

open -g "${SSL}/certs/${DOMAIN}/${DOMAIN}.p12"

mkdir -p "${SSL}/certs/${MAIL}"
cat > "${SSL}/certs/${MAIL}/${MAIL}.cnf" << EOF
[ req ]
default_bits = 4096
default_keyfile = ${SSL}/certs/${DOMAIN}/${DOMAIN}.key
default_md = sha256
distinguished_name = dn
encrypt_key = no
prompt = no
utf8 = yes
x509_extensions = v3_ca

[ dn ]
CN = ${MAIL}

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = CA:true
EOF

openssl genrsa -out "${SSL}/certs/${MAIL}/${MAIL}.key" 4096

  openssl req -new \
    -config "${SSL}/certs/${MAIL}/${MAIL}.cnf" \
    -key "${SSL}/certs/${MAIL}/${MAIL}.key" \
    -out "${SSL}/certs/${MAIL}/${MAIL}.csr"

  p "Set fake '${MAIL}' certificate creation date"
  sudo date "${FAKE}" && \
  openssl x509 -days ${DAYS} -req -set_serial 01 -sha256 \
    -CA "${SSL}/certs/${DOMAIN}/${DOMAIN}.crt" \
    -CAkey "${SSL}/certs/${DOMAIN}/${DOMAIN}.key" \
    -in "${SSL}/certs/${MAIL}/${MAIL}.csr" \
    -out "${SSL}/certs/${MAIL}/${MAIL}.crt" && \
  sudo ntpdate -u time.apple.com
}

function config_shell () {
  if [ -x "/usr/local/bin/zsh" ]; then
    # Current User > Advanced Options… > Login shell: /usr/local/bin/zsh
    p "Set '/usr/local/bin/zsh' as the default shell"

    sudo sh -c "printf '%s\n' '/usr/local/bin/zsh' >> /etc/shells" && \
    sudo chsh -s /usr/local/bin/zsh && \
    sudo mkdir -m go= -p /private/var/root/Library/Caches/ && \
    sudo touch "/private/var/root/.zshrc"
    chsh -s /usr/local/bin/zsh
    touch "${HOME}/.zshrc"
  fi
}

function config_sieve () {
  p "Configure sieve"

  cat > "${HOME}/.sieve" << EOF
require ["date", "fileinto", "imap4flags", "mailbox", "relational", "variables"];

setflag "\\Seen";

if date :is "date" "year" "1995" { fileinto :create "Archives.1995"; }
if date :is "date" "year" "1996" { fileinto :create "Archives.1996"; }
if date :is "date" "year" "1997" { fileinto :create "Archives.1997"; }
if date :is "date" "year" "1998" { fileinto :create "Archives.1998"; }
if date :is "date" "year" "1999" { fileinto :create "Archives.1999"; }
if date :is "date" "year" "2000" { fileinto :create "Archives.2000"; }
if date :is "date" "year" "2001" { fileinto :create "Archives.2001"; }
if date :is "date" "year" "2002" { fileinto :create "Archives.2002"; }
if date :is "date" "year" "2003" { fileinto :create "Archives.2003"; }
if date :is "date" "year" "2004" { fileinto :create "Archives.2004"; }
if date :is "date" "year" "2005" { fileinto :create "Archives.2005"; }
if date :is "date" "year" "2006" { fileinto :create "Archives.2006"; }
if date :is "date" "year" "2007" { fileinto :create "Archives.2007"; }
if date :is "date" "year" "2008" { fileinto :create "Archives.2008"; }
if date :is "date" "year" "2009" { fileinto :create "Archives.2009"; }
if date :is "date" "year" "2010" { fileinto :create "Archives.2010"; }
if date :is "date" "year" "2011" { fileinto :create "Archives.2011"; }
if date :is "date" "year" "2012" { fileinto :create "Archives.2012"; }
if date :is "date" "year" "2013" { fileinto :create "Archives.2013"; }
if date :is "date" "year" "2014" { fileinto :create "Archives.2014"; }
if date :is "date" "year" "2015" { fileinto :create "Archives.2015"; }
if date :is "date" "year" "2016" { fileinto :create "Archives.2016"; }
if date :is "date" "year" "2017" { fileinto :create "Archives.2017"; }
if date :is "date" "year" "2018" { fileinto :create "Archives.2018"; }
if date :is "date" "year" "2019" { fileinto :create "Archives.2019"; }
if date :is "date" "year" "2020" { fileinto :create "Archives.2020"; }
EOF
}

function config_ssh () {
  p "Create ssh keys"

  mkdir -m go= -p "${HOME}/.ssh"

  ssh-keygen -t ed25519 -a 100 -C "ptb@ioutime.com"

  cat > "${HOME}/.ssh/config" <<-EOF
Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOF

  p "Adding ssh key to macOS keychain"

  ssh-add -K
  echo "ssh-add -A &> /dev/null" > "${HOME}/.zshrc"
}

function config_ssh_help () {
  pbcopy < "${HOME}/.ssh/id_ed25519.pub"
  open "https://github.com/settings/keys"
}

function config_zsh () {
  p "Create system default '/etc/zshrc'"

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
stty erase 
# Correctly display UTF-8 with combining characters.
if [ "\$TERM_PROGRAM" = "Apple_Terminal" ]; then
  setopt combiningchars
fi
function precmd () {
  print -Pn "\\e]7;file://%M\${PWD// /%%20}\a";
  print -Pn "\\e]2;%n@%m\a";
  print -Pn "\\e]1;%~\a";
}
function gb () {
  git branch --no-color 2> /dev/null | \
    sed -e "/^[^*]/d" -e "s/* \(.*\)/ (\1)/"
}
function xd () {
  xattr -d com.apple.diskimages.fsck \$* 2> /dev/null;
  xattr -d com.apple.diskimages.recentcksum \$* 2> /dev/null;
  xattr -d com.apple.metadata:kMDItemFinderComment \$* 2> /dev/null;
  xattr -d com.apple.metadata:kMDItemDownloadedDate \$* 2> /dev/null;
  xattr -d com.apple.metadata:kMDItemWhereFroms \$* 2> /dev/null;
  xattr -d com.apple.quarantine \$* 2> /dev/null;
  find . -name .DS_Store -delete;
  find . -name 'Icon' -delete
}
function sf () {
  SetFile -P -d "\$1 12:00:00" -m "\$1 12:00:00" \$argv[2,\$]
}
function sd () {
  xd **/*;
  sf \$1 .;
  for i in **/*; do sf \$1 \$i; done;
  chown -R root:wheel .;
  chmod -R a+r,u+w,go-w .;
  find . -type d -exec chmod a+x '{}' ';';
  chgrp -R admin ./Applications;
  chmod -R g+w ./Applications;
  chgrp -R admin ./Library;
  chmod -R g+w ./Library;
  chgrp -R staff "./Library/Application Support/Adobe";
  chmod -R g-w ./Library/Keychains;
  chmod -R g-w ./Library/ScriptingAdditions;
  chgrp -R wheel ./Library/Filesystems;
  chmod -R g-w ./Library/Filesystems;
  chgrp -R wheel ./Library/LaunchAgents;
  chmod -R g-w ./Library/LaunchAgents;
  chgrp -R wheel ./Library/LaunchDaemons;
  chmod -R g-w ./Library/LaunchDaemons;
  chgrp -R wheel ./Library/PreferencePanes;
  chmod -R g-w ./Library/PreferencePanes;
  chgrp -R wheel ./Library/StartupItems;
  chmod -R g-w ./Library/StartupItems;
  chgrp -R wheel ./Library/Widgets;
  chmod -R g-w ./Library/Widgets;
  find . -name "kexts" -type d -exec chmod -R g-w '{}' ';';
  find . -name "*.kext" -exec chown -R root:wheel '{}' ';';
  find . -name "*.kext" -exec chmod -R g-w '{}' ';'
}
MAS="\$(getconf DARWIN_USER_CACHE_DIR)com.apple.appstore"
PROMPT="%B%n@%m%b:%2~%B\$(gb) %#%b "
EOF
}

function config_loginitems () {
  p "Create login items"

  osascript > /dev/null << EOF
    tell app "System Events"
      make new login item with properties ¬
        { path: "/Applications/Alfred 3.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/autoping.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/Caffeine.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/Coffitivity.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/Dropbox.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/HardwareGrowler.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/I Love Stars.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/IPMenulet.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/iTunes.app/Contents/MacOS/iTunesHelper.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/Menubar Countdown.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/Meteorologist.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/Moom.app", hidden: true }
      make new login item with properties ¬
        { path: "/Applications/Plex Media Server.app", hidden: true }
      make new login item with properties ¬
        { path: "/Library/PreferencePanes/SteerMouse.prefPane/Contents/MacOS/SteerMouse Manager.app", hidden: true }
    end tell
EOF

  mkdir -m go= -p "${HOME}/Library/LaunchAgents"
  printf "%s\t%s\n" \
    "net.elasticthreads.nv" "add ':KeepAlive' bool true" \
    "net.elasticthreads.nv" "add ':Label' string 'net.elasticthreads.nv'" \
    "net.elasticthreads.nv" "add ':Program' string '/Applications/nvALT.app/Contents/MacOS/nvALT'" \
  | while IFS=$'\t' read a b; do
    /usr/libexec/PlistBuddy "${HOME}/Library/LaunchAgents/${a}.plist" -c "${b}" &> /dev/null
  done
}

function config_handlers () {
  if [ -f "${HOME}/Library/Preferences/org.duti.plist" ]; then
    rm "${HOME}/Library/Preferences/org.duti.plist"
  fi

  printf "%s\t%s\t%s\n" \
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
    "com.sketchup.SketchUp.2017" "com.sketchup.skp" "all" \
    "com.VortexApps.NZBVortex3" "dyn.ah62d4rv4ge8068xc" "all" \
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
    "org.videolan.vlc" "org.videolan.3gp" "all" \
    "org.videolan.vlc" "org.videolan.aac" "all" \
    "org.videolan.vlc" "org.videolan.ac3" "all" \
    "org.videolan.vlc" "org.videolan.aiff" "all" \
    "org.videolan.vlc" "org.videolan.amr" "all" \
    "org.videolan.vlc" "org.videolan.aob" "all" \
    "org.videolan.vlc" "org.videolan.ape" "all" \
    "org.videolan.vlc" "org.videolan.asf" "all" \
    "org.videolan.vlc" "org.videolan.avi" "all" \
    "org.videolan.vlc" "org.videolan.axa" "all" \
    "org.videolan.vlc" "org.videolan.axv" "all" \
    "org.videolan.vlc" "org.videolan.divx" "all" \
    "org.videolan.vlc" "org.videolan.dts" "all" \
    "org.videolan.vlc" "org.videolan.dv" "all" \
    "org.videolan.vlc" "org.videolan.flac" "all" \
    "org.videolan.vlc" "org.videolan.flash" "all" \
    "org.videolan.vlc" "org.videolan.gxf" "all" \
    "org.videolan.vlc" "org.videolan.it" "all" \
    "org.videolan.vlc" "org.videolan.mid" "all" \
    "org.videolan.vlc" "org.videolan.mka" "all" \
    "org.videolan.vlc" "org.videolan.mkv" "all" \
    "org.videolan.vlc" "org.videolan.mlp" "all" \
    "org.videolan.vlc" "org.videolan.mod" "all" \
    "org.videolan.vlc" "org.videolan.mpc" "all" \
    "org.videolan.vlc" "org.videolan.mpeg-audio" "all" \
    "org.videolan.vlc" "org.videolan.mpeg-stream" "all" \
    "org.videolan.vlc" "org.videolan.mpeg-video" "all" \
    "org.videolan.vlc" "org.videolan.mxf" "all" \
    "org.videolan.vlc" "org.videolan.nsv" "all" \
    "org.videolan.vlc" "org.videolan.nuv" "all" \
    "org.videolan.vlc" "org.videolan.ogg-audio" "all" \
    "org.videolan.vlc" "org.videolan.ogg-video" "all" \
    "org.videolan.vlc" "org.videolan.oma" "all" \
    "org.videolan.vlc" "org.videolan.opus" "all" \
    "org.videolan.vlc" "org.videolan.quicktime" "all" \
    "org.videolan.vlc" "org.videolan.realmedia" "all" \
    "org.videolan.vlc" "org.videolan.rec" "all" \
    "org.videolan.vlc" "org.videolan.rmi" "all" \
    "org.videolan.vlc" "org.videolan.s3m" "all" \
    "org.videolan.vlc" "org.videolan.spx" "all" \
    "org.videolan.vlc" "org.videolan.tod" "all" \
    "org.videolan.vlc" "org.videolan.tta" "all" \
    "org.videolan.vlc" "org.videolan.vob" "all" \
    "org.videolan.vlc" "org.videolan.voc" "all" \
    "org.videolan.vlc" "org.videolan.vqf" "all" \
    "org.videolan.vlc" "org.videolan.vro" "all" \
    "org.videolan.vlc" "org.videolan.wav" "all" \
    "org.videolan.vlc" "org.videolan.webm" "all" \
    "org.videolan.vlc" "org.videolan.wma" "all" \
    "org.videolan.vlc" "org.videolan.wmv" "all" \
    "org.videolan.vlc" "org.videolan.wtv" "all" \
    "org.videolan.vlc" "org.videolan.wv" "all" \
    "org.videolan.vlc" "org.videolan.xa" "all" \
    "org.videolan.vlc" "org.videolan.xesc" "all" \
    "org.videolan.vlc" "org.videolan.xm" "all" \
    "org.videolan.vlc" "public.ac3-audio" "all" \
    "org.videolan.vlc" "public.audiovisual-content" "all" \
    "org.videolan.vlc" "public.avi" "all" \
    "org.videolan.vlc" "public.movie" "all" \
    "org.videolan.vlc" "public.mpeg" "all" \
    "org.videolan.vlc" "public.mpeg-2-video" "all" \
    "org.videolan.vlc" "public.mpeg-4" "all" \
  | while IFS=$'\t' read a b c; do
      defaults write org.duti DUTISettings -array-add \
        "{
          DUTIBundleIdentifier = '$a';
          DUTIUniformTypeIdentifier = '$b';
          DUTIRole = '$c';
        }"
  done

  if [ -x "/usr/local/bin/duti" ]; then
    p "Set document file handlers"

    duti "${HOME}/Library/Preferences/org.duti.plist" 2> /dev/null
  fi

  /System/Library/Frameworks/CoreServices.framework/Versions/Current/Frameworks/LaunchServices.framework/Versions/Current/Support/lsregister -kill -r -domain local -domain system -domain user

  sudo rm -rf /Library/Caches/com.apple.iconservices.store
  sudo find /private/var/folders -depth \( -name com.apple.dock.iconcache -or -name com.apple.iconservices \) -exec rm -rf {} \;
  sudo touch /Applications/* /Applications/Utilities/* 2> /dev/null

  sleep 5
  osascript -e 'tell app "Dock" to quit'
  killall Finder
}

function config_done () {
  p "To copy gpg public key, enter 'config_gpg_help'"
  p "To copy ssh public key, enter 'config_ssh_help'"
  p "Otherwise, enter 'private' (if configured) or 'reboot' now"
}

function config () {
  config_mas
  config_atom
  config_bbedit
  config_desktop
  config_dock
  config_emacs
  config_vi_script
  config_terminal
  config_openssl
  config_dovecot
  config_sieve
  config_getmail
  config_gpg
  config_git
  config_shell
  config_ssh
  #config_vim
  config_zsh
  config_loginitems
  config_handlers
  config_done
}

function private () {
  printf "%s\n"

}

function display_help () {
  cat << EOF

  Initialize:
    $(which init)

  Install:
    $(which install)

EOF
}

display_help
fi
