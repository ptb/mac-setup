#!/bin/sh

# COMPUTERNAME='Mac'
# LOCALHOSTNAME='mac'

function set_system_preferences () {
# System Preferences

  ## System Preferences > General

    ### Appearance: Graphite
    /usr/bin/defaults write -g 'AppleAquaColorVariant' -int 6

    ### Highlight color: #CC99CC
    /usr/bin/defaults write -g 'AppleHighlightColor' -string '0.600000 0.800000 0.600000'

    ### Show scroll bars: Always
    /usr/bin/defaults write -g 'AppleShowScrollBars' -string 'Always'

    ### Sidebar icon size: Small
    /usr/bin/defaults write -g 'NSTableViewDefaultSizeMode' -int 1

    ### Number of recent items: Applications: None
    /usr/bin/osascript -e 'tell application "System Events" to tell appearance preferences to set recent applications limit to 0'

    ### Number of recent items: Documents: None
    /usr/bin/osascript -e 'tell application "System Events" to tell appearance preferences to set recent documents limit to 0'

    ### Number of recent items: Servers: None
    /usr/bin/osascript -e 'tell application "System Events" to tell appearance preferences to set recent servers limit to 0'

    ### Restore windows when quitting and re-opening apps: off
    /usr/bin/defaults write -g 'NSQuitAlwaysKeepsWindows' -bool false


  ## System Preferences > Desktop & Screen Saver > Desktop

    ### Solid Colors: black
    /bin/rm "$HOME/Library/Preferences/com.apple.desktop.plist" > /dev/null 2>&1
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.desktop.plist" -c 'Add Background:default:BackgroundColor array' > /dev/null 2>&1
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.desktop.plist" -c 'Add Background:default:BackgroundColor:0 real 0'
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.desktop.plist" -c 'Add Background:default:BackgroundColor:1 real 0'
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.desktop.plist" -c 'Add Background:default:BackgroundColor:2 real 0'
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.desktop.plist" -c 'Add Background:default:DrawBackgroundColor bool true'
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.desktop.plist" -c 'Add Background:default:ImageFilePath string /System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane/Contents/Resources/DesktopPictures.prefPane/Contents/Resources/Transparent.png'
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.desktop.plist" -c 'Add Background:default:NoImage bool true'

    ### Translucent menu bar: off
    /usr/bin/defaults write -g 'AppleEnableMenuBarTransparency' -bool false

  ## System Preferences > Desktop & Screen Saver > Screen Saver

    ### Screen Savers: Spectrum
    ### Start screen saver: Never
    /usr/bin/defaults -currentHost write com.apple.screensaver '{ idleTime = 0; moduleDict = { moduleName = Spectrum; path = "/System/Library/Screen Savers/Spectrum.qtz"; type = 1; }; }';

    ### Hot Corners… > Top Left: ⌘ Mission Control
    /usr/bin/defaults write com.apple.dock 'wvous-tl-corner' -int 2
    /usr/bin/defaults write com.apple.dock 'wvous-tl-modifier' -int 1048576

    ### Hot Corners… > Bottom Left: Put Display to Sleep
    /usr/bin/defaults write com.apple.dock 'wvous-bl-corner' -int 10
    /usr/bin/defaults write com.apple.dock 'wvous-bl-modifier' -int 0


  ## System Preferences > Dock

    ### Size: 32 pixels
    /usr/bin/defaults write com.apple.dock 'tilesize' -int 32

    ### Magnification: off, 64 pixels
    /usr/bin/defaults write com.apple.dock 'magnification' -bool false
    /usr/bin/defaults write com.apple.dock 'largesize' -int 64

    ### Position on screen: Left
    /usr/bin/defaults write com.apple.dock 'orientation' -string 'left'

    ### Minimize windows using: Scale effect
    /usr/bin/defaults write com.apple.dock 'mineffect' -string 'scale'


  ## System Preferences > Mission Control

    ### Show Dashboard as a space
    /usr/bin/defaults write com.apple.dock 'dashboard-in-overlay' -bool true


  ## System Preferences > Security & Privacy > General

    ### Require password: '5 seconds' after sleep or screen saver begins
    /usr/bin/defaults write com.apple.screensaver 'askForPassword' -int 1
    /usr/bin/defaults write com.apple.screensaver 'askForPasswordDelay' -int 5


  ## System Preferences > Spotlight

    ### Spotlight menu keyboard shortcut: none
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" -c 'Delete AppleSymbolicHotKeys:64' > /dev/null 2>&1
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" -c 'Add AppleSymbolicHotKeys:64:enabled bool false'

    ### Spotlight window keyboard shortcut: none
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" -c 'Delete AppleSymbolicHotKeys:65' > /dev/null 2>&1
    /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" -c 'Add AppleSymbolicHotKeys:65:enabled bool false'


  ## System Preferences > Universal Access

    ### Enable access for assistive devices
    # /usr/bin/osascript -e 'tell application "System Events" to set UI elements enabled to true'
    /bin/echo -n 'a' | /usr/bin/sudo /usr/bin/tee /private/var/db/.AccessibilityAPIEnabled > /dev/null 2>&1 
    /usr/bin/sudo /bin/chmod 444 /private/var/db/.AccessibilityAPIEnabled

  ## System Preferences > Universal Access > Seeing

    ### Zoom: Options… > Smooth images (Press ⌥ ⌘\ to turn smoothing on or off): off
    /usr/bin/defaults write com.apple.universalaccess 'closeViewSmoothImages' -bool false

    ### Zoom: Options… > Use scroll wheel with modifier keys to zoom: on
    /usr/bin/defaults write com.apple.universalaccess 'closeViewScrollWheelToggle' -bool true
    ### Zoom: Options… > Use scroll wheel with modifier keys to zoom: ^ [control]
    /usr/bin/defaults write com.apple.universalaccess 'HIDScrollZoomModifierMask' -int 262144

  ## System Preferences > Universal Access > Mouse & Trackpad

    ### For difficulties seeing the cursor > Cursor Size: 1.5x
    /usr/bin/defaults write com.apple.universalaccess 'mouseDriverCursorSize' -float 1.5


  ## System Preferences > CDs & DVDs
    ### When you insert a video DVD: Open HandBrake
    /usr/bin/defaults write com.apple.digihub 'com.apple.digihub.dvd.video.appeared' '<dict><key>action</key><integer>5</integer><key>otherapp</key><dict><key>_CFURLString</key><string>/Applications/Utilities/HandBrake.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict>'


  ## System Preferences > Displays > Display

    ### Automatically adjust brightness: off
    /usr/bin/defaults write com.apple.BezelServices 'dAuto' -bool false

  ## System Preferences > Displays > Arrangement

    /usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.windowserver 'DisplayLayoutToRight' -bool true
    /usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.windowserver 'DisplayMainOnInternal' -bool false


  ## System Preferences > Energy Saver > Battery

    ### Computer sleep: Never
    /usr/bin/sudo /usr/bin/pmset -b sleep 0

    ### Display sleep: 10 min
    /usr/bin/sudo /usr/bin/pmset -b displaysleep 10

    ### Put the hard disk(s) to sleep when possible: 10 min
    /usr/bin/sudo /usr/bin/pmset -b disksleep 10

    ### Slightly dim the display when using this power source
    /usr/bin/sudo /usr/bin/pmset -b lessbright 0

    ### Automatically reduce brightness before display goes to sleep
    /usr/bin/sudo /usr/bin/pmset -b halfdim 0

    ### Restart automatically if the computer freezes
    /usr/bin/sudo /usr/bin/pmset -b panicrestart 15

  ## System Preferences > Energy Saver > Power Adapter

    ### Computer sleep: Never
    /usr/bin/sudo /usr/bin/pmset -c sleep 0

    ### Display sleep: 10 min
    /usr/bin/sudo /usr/bin/pmset -c displaysleep 10

    ### Put the hard disk(s) to sleep when possible: 10 min
    /usr/bin/sudo /usr/bin/pmset -c disksleep 10

    ### Wake for network access
    /usr/bin/sudo /usr/bin/pmset -c womp 1

    ### Automatically reduce brightness before display goes to sleep
    /usr/bin/sudo /usr/bin/pmset -c halfdim 0

    ### Start up automatically after a power failure
    /usr/bin/sudo /usr/bin/pmset -c autorestart 1

    ### Restart automatically if the computer freezes
    /usr/bin/sudo /usr/bin/pmset -c panicrestart 15

  ## System Preferences > Energy Saver

    ### Show battery status in menu bar: off
    /usr/bin/defaults -currentHost write com.apple.systemuiserver 'dontAutoLoad' -array-add '/System/Library/CoreServices/Menu Extras/Battery.menu'


  ## System Preferences > Keyboard > Keyboard

    ### Automatically illuminate keyboard in low light: on
    /usr/bin/defaults write com.apple.BezelServices 'kDim' -bool true

    ### Turn off when computer is not used for: 5 mins
    /usr/bin/defaults write com.apple.BezelServices 'kDimTime' -int 300

    ### Modifier Keys… > Apple Internal Keyboard / Trackpad > Caps Lock ( ⇪) Key: No Action
    /usr/bin/defaults -currentHost write -g 'com.apple.keyboard.modifiermapping.1452-566-0' -array '<dict><key>HIDKeyboardModifierMappingDst</key><integer>-1</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'

    ### Modifier Keys… > Apple Keyboard [External] > Caps Lock ( ⇪) Key: No Action
    /usr/bin/defaults -currentHost write -g 'com.apple.keyboard.modifiermapping.1452-544-0' -array '<dict><key>HIDKeyboardModifierMappingDst</key><integer>-1</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'


  ## System Preferences > Mouse

    ### Move content in the direction of finger movement when scrolling or navigating: off
    /usr/bin/defaults write -g 'com.apple.swipescrolldirection' -bool false


  ## System Preferences > Trackpad

    ### Active Tab: Point & Click
    /usr/bin/defaults write com.apple.systempreferences 'trackpad.lastselectedtab' -int 0

  ## System Preferences > Trackpad > Point & Click

    ### FIXME: Tap to click
    /usr/bin/sudo /usr/bin/defaults write /Library/Preferences/.GlobalPreferences 'com.apple.mouse.tapBehavior' -bool true
    /usr/bin/defaults -currentHost write -g 'com.apple.mouse.tapBehavior' -bool true

  ## System Preferences > Trackpad > Scroll & Zoom

    ### Scroll direction: natural: no
    /usr/bin/defaults write -g 'com.apple.swipescrolldirection' -bool false

  ## System Preferences > Trackpad > More Gestures

    ### Launchpad: no
    /usr/bin/defaults write com.apple.dock 'showLaunchpadGestureEnabled' -bool false

    ### Show Desktop: no
    /usr/bin/defaults write com.apple.dock 'showDesktopGestureEnabled' -bool false


  ## System Preferences > Sound

    ### Select an alert sound: Sosumi
    /usr/bin/defaults write com.apple.systemsound 'com.apple.sound.beep.sound' -string '/System/Library/Sounds/Sosumi.aiff'

    ### Play user interface sound effects
    /usr/bin/defaults write com.apple.systemsound 'com.apple.sound.uiaudio.enabled' -int 0

    ### FIXME: Play feedback when volume is changed
    /usr/bin/defaults write -g 'com.apple.sound.beep.feedback' -bool false


  ## System Preferences > Network

    ### Ethernet > Advanced… > DNS
    EN0=$(/usr/sbin/networksetup -listnetworkserviceorder | /usr/bin/awk -F'\\) ' '/Ethernet/ { printf $2 }')
    /usr/sbin/networksetup -setdnsservers "$EN0" 127.0.0.1

    ### Wi-Fi > Advanced… > DNS
    EN1=$(/usr/sbin/networksetup -listnetworkserviceorder | /usr/bin/awk -F'\\) ' '/Wi-Fi/ { printf $2 }')
    /usr/sbin/networksetup -setdnsservers "$EN1" 127.0.0.1


  ## System Preferences > Sharing

    # IP1=$(/sbin/ifconfig en1 | /usr/bin/grep 'inet ' | /usr/bin/awk '{ print $2 }')
    # COMPUTERNAME=$(/usr/bin/host "$IP1" | /usr/bin/awk '{ print $5 }' | /usr/bin/awk -F. '{ print $1 }')
    # LOCALHOSTNAME=$(/usr/bin/host "$IP1" | /usr/bin/awk '{ print $5 }' | /usr/bin/awk -F. '{ print $1 }')

    ### Computer Name: $COMPUTERNAME
    if [ ! "$(/usr/sbin/networksetup -getcomputername)" = "$COMPUTERNAME" ]; then
      /usr/bin/sudo /usr/sbin/networksetup -setcomputername $COMPUTERNAME
    fi

    ### Local Hostname: $LOCALHOSTNAME
    if [ ! "$(/usr/sbin/systemsetup -getlocalsubnetname)" = "Local Subnet Name: $LOCALHOSTNAME" ]; then
      /usr/bin/sudo /usr/sbin/systemsetup -setlocalsubnetname $LOCALHOSTNAME > /dev/null 2>&1
    fi


  ## System Preferences > Users & Groups

    ### [Right Click] > Advanced Options… > Login shell: /bin/zsh
    if [ ! $SHELL = '/bin/zsh' ]; then
      /usr/bin/chsh -s /bin/zsh
      /usr/bin/sudo /usr/bin/chsh -s /bin/zsh
    fi

    ### Login Options > Display login window as: Name and password
    /usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.loginwindow 'SHOWFULLNAME' -bool true


  ## System Preferences > Date & Time > Clock

    ### Show date and time in menu bar: no
    /usr/bin/defaults -currentHost write com.apple.systemuiserver 'dontAutoLoad' -array-add '/System/Library/CoreServices/Menu Extras/Clock.menu'

    ### Time options: Display the time with seconds: on
    ### Date options: Show the day of the week: on
    ### Date options: Show date: on
    /usr/bin/defaults write com.apple.menuextra.clock 'DateFormat' -string 'EEE MMM d   h:mm:ss a'


  ## System Preferences > Software Update > Scheduled Check

    ### Check for updates: off
    /usr/bin/sudo /usr/sbin/softwareupdate --schedule off > /dev/null 2>&1
    /usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate 'ScheduleFrequency' -int -1
    /usr/bin/sudo /usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides 'com.apple.softwareupdatecheck.initial' -dict 'Disabled' -bool true
    /usr/bin/sudo /usr/bin/defaults write /private/var/db/launchd.db/com.apple.launchd/overrides 'com.apple.softwareupdatecheck.periodic' -dict 'Disabled' -bool true
    /usr/bin/sudo /usr/bin/plutil -convert xml1 /private/var/db/launchd.db/com.apple.launchd/overrides.plist

    ### Download updates automatically: off
    /usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate 'AutomaticDownload' -bool false


  ## System Preferences > Speech > Text to Speech

    ### System Voice: Samantha
    /usr/bin/defaults write com.apple.speech.voice.prefs 'SelectedVoiceCreator' -int 1919902066
    /usr/bin/defaults write com.apple.speech.voice.prefs 'SelectedVoiceID' -int 745
    /usr/bin/defaults write com.apple.speech.voice.prefs 'SelectedVoiceName' -string 'Samantha'

    ### System Voice > Customize… > English (United States) - Female: Jill: on
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.jill.premium' 1

    ### System Voice > Customize… > English (United States) - Female: Kathy: off
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.Kathy' 0

    ### System Voice > Customize… > English (United States) - Female: Samantha: on
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.samantha.premium' 1

    ### System Voice > Customize… > English (United States) - Female: Vicki: off
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.Vicki' 0

    ### System Voice > Customize… > English (United States) - Female: Victoria: off
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.Victoria' 0

    ### System Voice > Customize… > English (United States) - Male: Alex: off
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.Alex' 0

    ### System Voice > Customize… > English (United States) - Male: Bruce: off
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.Bruce' 0 

    ### System Voice > Customize… > English (United States) - Male: Fred: off
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.Fred' 0

    ### System Voice > Customize… > English (United States) - Male: Tom: on
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.tom.premium' 1

    ### System Voice > Customize… > English (United Kingdom): Daniel: on
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.daniel.premium' 1

    ### System Voice > Customize… > English (United Kingdom): Emily: on
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.emily.premium' 1

    ### System Voice > Customize… > English (United Kingdom): Serena: on
    /usr/bin/defaults write com.apple.speech.voice.prefs 'VisibleIdentifiers' -dict-add 'com.apple.speech.synthesis.voice.serena.premium' 1

    ### Speak selected text when the key is pressed: on
    /usr/bin/defaults write com.apple.speech.synthesis.general.prefs 'SpokenUIUseSpeakingHotKeyFlag' -bool true


  ## System Preferences > Time Machine

    ### Time Machine: off
    /usr/bin/defaults write com.apple.TimeMachine 'AutoBackup' -bool false

}

function set_hidden_preferences () {

  # <http://support.apple.com/kb/HT3789>
  /usr/bin/sudo /usr/bin/defaults write /System/Library/LaunchDaemons/com.apple.mDNSResponder 'ProgramArguments' -array-add '-NoMulticastAdvertisements'
  /usr/bin/sudo /usr/bin/plutil -convert xml1 /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
  /usr/bin/sudo /bin/chmod 644 /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist

  # <http://www.macrumors.com/2011/07/25/os-x-lions-hidpi-modes-lay-groundwork-for-retina-monitors/>
  /usr/bin/sudo /usr/bin/defaults delete /Library/Preferences/com.apple.windowserver 'DisplayResolutionDisabled' > /dev/null 2>&1
  /usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.windowserver 'DisplayResolutionEnabled' -bool true

  # <http://hints.macworld.com/article.php?story=20110721122558299>
  /usr/bin/defaults write -g 'ApplePressAndHoldEnabled' -bool false

  # <http://twitter.com/siracusa/statuses/95240123494572032>
  /usr/bin/defaults write -g 'NSAutomaticWindowAnimationsEnabled' -bool false

  # <http://hints.macworld.com/article.php?story=20061106184904899>
  /usr/bin/defaults write -g 'NSNavPanelExpandedStateForSaveMode' -bool true

  # <http://hints.macworld.com/article.php?story=20050919045154542>
  /usr/bin/defaults write -g 'NSRecentDocumentsLimit' -int 0

  # <http://hints.macworld.com/article.php?story=2004051208143172>
  /usr/bin/defaults write -g 'NSWindowResizeTime' -float .001

  # <http://hints.macworld.com/article.php?story=20071109163914940>
  /usr/bin/defaults write -g 'PMPrintingExpandedStateForPrint' -bool true

  # <http://hints.macworld.com/article.php?story=20050723123302403>
  /usr/bin/defaults write com.apple.dashboard 'mcx-disabled' -bool true

  # <http://hints.macworld.com/article.php?story=2007101815375480>
  /usr/bin/defaults write com.apple.dock 'no-glass' -bool true

  # <http://hints.macworld.com/article.php?story=20040423170608616>
  /usr/bin/defaults write com.apple.dock 'pinning' -string 'start'

  # <http://hints.macworld.com/article.php?story=20031027022943749>
  /usr/bin/defaults write com.apple.dock 'showhidden' -bool true

  # FIXME: <https://discussions.apple.com/thread/3208633>
  /usr/bin/defaults write com.apple.loginwindow 'TALLogoutSavesState' -bool false

  # <http://mattdanger.net/2008/12/common-mac-os-x-tweaks/>
  /usr/bin/defaults write com.apple.print.PrintingPrefs 'Quit When Finished' -bool true

  # <http://hints.macworld.com/article.php?story=20080114082057330>
  /usr/bin/defaults write com.apple.TimeMachine 'DoNotOfferNewDisksForBackup' -bool true

}

function set_application_preferences () {

  ## System / Library / CoreServices / Finder

  /usr/bin/defaults write com.apple.finder 'PreferencesWindow.LastSelection' -string 'SDBR'

  /usr/bin/defaults write com.apple.finder 'NewWindowTarget' -string 'PfHm'

  /usr/bin/defaults write com.apple.finder 'QuitMenuItem' -bool true

  /usr/bin/defaults write com.apple.finder 'ShowPathbar' -bool true
  /usr/bin/defaults write com.apple.finder 'ShowStatusBar' -bool true

  /usr/bin/defaults write com.apple.finder 'WarnOnEmptyTrash' -bool false
  /usr/bin/defaults write com.apple.finder 'FXEnableExtensionChangeWarning' -bool false

  /usr/bin/defaults write com.apple.finder 'FinderSounds' -bool false

  /usr/bin/defaults write com.apple.finder 'AnimateInfoPanes' -bool false
  /usr/bin/defaults write com.apple.finder 'AnimateWindowZoom' -bool false
  /usr/bin/defaults write com.apple.finder 'DisableAllAnimations' -bool true
  /usr/bin/defaults write com.apple.finder 'ZoomRects' -bool false

  /usr/bin/defaults write com.apple.desktopservices 'DSDontWriteNetworkStores' -bool true

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Delete "NSToolbar Configuration Browser" dict' > /dev/null 2>&1
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Display Mode" integer 2'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Icon Size Mode" integer 1'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Is Shown" integer 1'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers" array'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:0" string "com.apple.finder.BACK"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:1" string "com.apple.finder.PATH"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:2" string "com.apple.finder.ARNG"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:3" string "com.apple.finder.ACTN"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:4" string "com.apple.finder.SWCH"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:5" string "NSToolbarSpaceItem"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:6" string "NSToolbarFlexibleSpaceItem"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:7" string "com.apple.finder.INFO"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:8" string "com.apple.finder.CNCT"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:9" string "com.apple.finder.EJCT"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Item Identifiers:10" string "com.apple.finder.TRSH"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "NSToolbar Configuration Browser:TB Size Mode" integer 1'

  /usr/bin/defaults write com.apple.finder 'FXPreferredGroupBy' -string 'Kind'

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Delete "StandardViewSettings:ExtendedListViewSettings:calculateAllSizes" bool'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "StandardViewSettings:ExtendedListViewSettings:calculateAllSizes" bool true'

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Delete "StandardViewSettings:ExtendedListViewSettings:useRelativeDates" bool'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "StandardViewSettings:ExtendedListViewSettings:useRelativeDates" bool false'

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Delete "StandardViewSettings:ListViewSettings:calculateAllSizes" bool'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "StandardViewSettings:ListViewSettings:calculateAllSizes" bool true'

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Delete "StandardViewSettings:ListViewSettings:useRelativeDates" bool'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.finder.plist" -c 'Add "StandardViewSettings:ListViewSettings:useRelativeDates" bool false'

  # /usr/bin/killall Finder


  ## System / Library / CoreServices / HelpViewer

  /usr/bin/defaults write com.apple.helpviewer 'DevMode' -bool true


  ## System / Library / CoreServices / ReportCrash

  /usr/bin/defaults write com.apple.CrashReporter 'DialogType' -string 'none'


  ## System / Library / CoreServices / SystemUIServer

  /usr/bin/defaults write com.apple.systemuiserver 'menuExtras' -array '/Library/Application Support/iStat local/extras/iStatMenusBattery.menu' '/System/Library/CoreServices/Menu Extras/Bluetooth.menu' '/System/Library/CoreServices/Menu Extras/TimeMachine.menu' '/System/Library/CoreServices/Menu Extras/Sync.menu' '/System/Library/CoreServices/Menu Extras/Volume.menu' '/System/Library/CoreServices/Menu Extras/AirPort.menu' '/System/Library/CoreServices/Menu Extras/Displays.menu' '/Applications/Utilities/Keychain Access.app/Contents/Resources/Keychain.menu' '/System/Library/CoreServices/Menu Extras/Script Menu.menu' '/Library/Application Support/iStat local/extras/iStatMenusMemory.menu' '/Library/Application Support/iStat local/extras/iStatMenusCPU.menu' '/Library/Application Support/iStat local/extras/iStatMenusNetwork.menu' '/Library/Application Support/iStat local/extras/iStatMenusDateAndTimes.menu' '/Library/Application Support/iStat local/extras/MenuCracker.menu'

  # <http://hints.macworld.com/article.php?story=20091030173117381>
  /usr/bin/sudo /bin/chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

  /usr/bin/killall SystemUIServer


  ## System Preferences > Users & Groups > Login Items

  # /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.loginitems.plist" -c 'Delete SessionItems:CustomListItems'
  # /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.loginitems.plist" -c 'Add SessionItems:CustomListItems array'

  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/SteerMouse.app/Contents/Resources/SteerMouse Manager.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/Quicksilver.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/TotalFinder.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/Menubar Countdown.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/gfxCardStatus.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/ExpanDrive.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/SizeUp.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/Synergy Preferences.app/Contents/PreferencePanes/Synergy.prefPane/Contents/Helpers/Synergy.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/I Love Stars.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/WeatherDock.app" }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/SpeechSynthesis.framework/Versions/A/SpeechSynthesisServer.app", hidden: true }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/iTunes.app/Contents/MacOS/iTunesHelper.app", hidden: true }' > /dev/null 2>&1
  /usr/bin/osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Utilities/SMARTReporter.app", hidden: true }' > /dev/null 2>&1


  ## System Preferences > Growl

  /usr/bin/defaults write com.Growl.GrowlHelperApp 'GrowlDisplayPluginName' -string 'Smokestack'
  /usr/bin/defaults write com.Growl.GrowlHelperApp 'GrowlMenuExtra' -bool false
  /usr/bin/defaults write com.Growl.GrowlHelperApp 'GrowlSelectedPosition' -int 2
  /usr/bin/defaults write com.Growl.GrowlHelperApp 'GrowlStartServer' -bool false


  ## System Preferences > Choosy

  /usr/bin/defaults write com.choosyosx.Choosy 'browsers' -array '/Applications/Safari.app' '/Applications/Firefox.app' '/Applications/Google Chrome.app' '/Applications/Opera.app'
  /usr/bin/defaults write com.choosyosx.Choosy 'displayMenuBarItem' -bool false
  /usr/bin/defaults write com.choosyosx.Choosy 'runningMode' -int 2


  ## Applications / BBEdit

  /usr/bin/defaults write com.barebones.bbedit 'CopiedPreferencesToNewKeys_v1' -bool true
  /usr/bin/defaults write com.barebones.bbedit 'CopiedPreferencesToNewKeys_v2' -bool true
  /usr/bin/defaults write com.barebones.bbedit 'CopiedPreferencesToNewKeys_v3' -bool true
  /usr/bin/defaults write com.barebones.bbedit 'LastAppVersion' -string '16.0'

  /usr/bin/defaults write com.barebones.bbedit 'FirstRunDialogVersion' -int 1
  /usr/bin/defaults write com.barebones.bbedit 'NewAndOpenPrefersSharedWindow' -bool true

  /usr/bin/defaults write com.barebones.bbedit 'NavbarShowDocumentNavigation' -bool false
  /usr/bin/defaults write com.barebones.bbedit 'NavbarShowMarkerMenu' -bool false
  /usr/bin/defaults write com.barebones.bbedit 'NavbarShowCounterpartButton' -bool false
  /usr/bin/defaults write com.barebones.bbedit 'NavbarShowIncludedFilesMenu' -bool false
  /usr/bin/defaults write com.barebones.bbedit 'NavbarShowFunctionMenu' -bool false
  /usr/bin/defaults write com.barebones.bbedit 'EditingWindowShowPageGuide' -bool false
  /usr/bin/defaults write com.barebones.bbedit 'EditingWindowPageGuideWidth' -int 72
  /usr/bin/defaults write com.barebones.bbedit 'TextStatusBarShowLanguageMenu' -bool false
  /usr/bin/defaults write com.barebones.bbedit 'TextStatusBarShowTextEncodingMenu' -bool false
  /usr/bin/defaults write com.barebones.bbedit 'TextStatusBarShowLineBreakMenu' -bool false
  /usr/bin/defaults write com.barebones.bbedit 'TextStatusBarShowDocumentStatistics' -bool false

  /usr/bin/defaults write com.barebones.bbedit 'SoftWrapStyle' -int 1
  /usr/bin/defaults write com.barebones.bbedit 'EditorSoftWrapWidth' -int 72
  /usr/bin/defaults write com.barebones.bbedit 'BBEditorFont' -data '62706c6973743030d401020304050828295424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a9090a0f191a1b1c1d2455246e756c6cd20b0c0d0e5f101a4e53466f6e7444657363726970746f72417474726962757465735624636c61737380028008d310110c1215185a4e532e6f626a65637473574e532e6b657973a2131480058006a216178003800480075f10134e53466f6e744e616d654174747269627574655f10134e53466f6e7453697a654174747269627574655b496e636f6e736f6c6174612241700000d21e1f20215824636c61737365735a24636c6173736e616d65a32122235f10134e534d757461626c6544696374696f6e6172795c4e5344696374696f6e617279584e534f626a656374d21e1f2527a226235f10104e53466f6e7444657363726970746f725f10104e53466f6e7444657363726970746f7212000186a05f100f4e534b657965644172636869766572000800110016001f002800320035003a003c0046004c0051006e0075007700790080008b009300960098009a009d009f00a100a300b900cf00db00e000e500ee00f900fd011301200129012e013101440157015c0000000000000201000000000000002a0000000000000000000000000000016e'
  /usr/bin/defaults write com.barebones.bbedit 'EditorDefaultTabWidth' -int 2

  /usr/bin/defaults write com.barebones.bbedit 'StripTrailingWhitespace' -bool true


  ## Applications / iChat

  /usr/bin/defaults write com.apple.iChat 'AutosaveChats' -bool true
  /usr/bin/defaults write com.apple.iChat 'UseSingleChatWindow' -bool true


  ## Applications / iTunes

  /usr/bin/defaults write com.apple.iTunes 'disablePing' -bool true
  /usr/bin/defaults write com.apple.iTunes 'hide-ping-dropdown' -bool true

  /usr/bin/defaults write com.apple.iTunes 'show-store-link-arrows' -bool true
  /usr/bin/defaults write com.apple.iTunes 'invertStoreLinks' -bool true

  /usr/bin/defaults write com.apple.iTunes 'allow-half-stars' -bool true


  ## Applications / iWork

  /usr/bin/defaults write com.apple.iWork.Keynote 'ShowStartingPointsForNewDocument' -bool false
  /usr/bin/defaults write com.apple.iWork.Keynote 'dontShowWhatsNew' -bool true
  /usr/bin/defaults write com.apple.iWork.Keynote 'FirstRunFlag' -bool true

  /usr/bin/defaults write com.apple.iWork.Numbers 'ShowStartingPointsForNewDocument' -bool false
  /usr/bin/defaults write com.apple.iWork.Numbers 'dontShowWhatsNew' -bool true
  /usr/bin/defaults write com.apple.iWork.Numbers 'FirstRunFlag' -bool true

  /usr/bin/defaults write com.apple.iWork.Pages 'ShowStartingPointsForNewDocument' -bool false
  /usr/bin/defaults write com.apple.iWork.Pages 'dontShowWhatsNew' -bool true
  /usr/bin/defaults write com.apple.iWork.Pages 'FirstRunFlag' -bool true


  ## Applications / Mail

  /usr/bin/defaults write com.apple.mail 'PreferPlainText' -bool true
  /usr/bin/defaults write com.apple.mail 'DisableReplyAnimations' -bool true
  /usr/bin/defaults write com.apple.mail 'DisableSendAnimations' -bool true


  ## Applications / QuickTime Player

  /usr/bin/defaults write com.apple.QuickTimePlayerX 'MGCinematicWindowDebugForceNoRoundedCorners' -bool true


  ## Applications / Quinn

  /usr/bin/defaults write Quinn 'QuinnDidShowOnlineHighscoreHint' -string 'YES'


  ## Applications / Remote Desktop

  /usr/bin/sudo /usr/bin/defaults write /Library/Preferences/com.apple.RemoteManagement 'AdminConsoleAllowsRemoteControl' -bool true

  /usr/bin/defaults write com.apple.RemoteDesktop 'doubleClick' -int 1
  /usr/bin/defaults write com.apple.RemoteDesktop 'useKeychain' -bool true


  ## Applications / Safari

  /usr/bin/defaults write com.apple.Safari 'ShowStatusBar' -bool true

  ### Applications / Safari > General

  /usr/bin/defaults write com.apple.Safari 'NewWindowBehavior' -int 1
  /usr/bin/defaults write com.apple.Safari 'NewTabBehavior' -int 1
  /usr/bin/defaults write com.apple.Safari 'HomePage' -string ''
  /usr/bin/defaults write com.apple.Safari 'AutoOpenSafeDownloads' -bool false

  /usr/bin/defaults write com.apple.LaunchServices 'LSQuarantine' -bool false

  /usr/bin/defaults write com.apple.Safari 'LastDisplayedWelcomePageVersionString' -string 4.0

  /usr/bin/defaults write com.apple.Safari 'DidAddReadingListToBookmarksBar' -bool true
  /usr/bin/defaults write com.apple.Safari 'DidMigrateNewBookmarkSheetToReadingListDefault' -bool true

  /usr/bin/defaults write com.apple.Safari 'ConvertedNewWindowBehaviorForTopSites' -bool true
  /usr/bin/defaults write com.apple.Safari 'BookmarksToolbarProxiesWereConvertedForSafari4' -bool true

  ### Applications / Safari > Bookmarks

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.Safari.plist" -c 'Delete ProxiesInBookmarksBar array' > /dev/null 2>&1
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.Safari.plist" -c 'Add ProxiesInBookmarksBar array'

  ### Applications / Safari > Tabs

  /usr/bin/defaults write com.apple.Safari 'TabCreationPolicy' -int 2
  /usr/bin/defaults write com.apple.Safari 'CommandClickMakesTabs' -bool true

  /usr/bin/defaults write com.apple.Safari 'OpenExternalLinksInExistingWindow' -bool true

  ### Applications / Safari > RSS

  /usr/bin/defaults write com.apple.Safari 'RSSBookmarksInBarAreSubscribed' -bool false

  ### Applications / Safari > Autofill

  /usr/bin/defaults write com.apple.Safari 'AutoFillFromAddressBook' -bool false
  /usr/bin/defaults write com.apple.Safari 'AutoFillMiscellaneousForms' -bool false

  ### Applications / Safari > Advanced

  /usr/bin/defaults write com.apple.Safari 'IncludeDevelopMenu' -bool true


  ## Applications / Seashore

  /usr/bin/defaults write net.sourceforge.seashore 'width' -int 1920
  /usr/bin/defaults write net.sourceforge.seashore 'height' -int 1200
  /usr/bin/defaults write net.sourceforge.seashore 'transparentBackground' -string 'YES'


  ## Applications / SketchUp

  /usr/bin/defaults write com.google.sketchupfree8 'displayWelcomeOnStartup' -bool false
  /usr/bin/defaults write com.google.sketchupfree8 'SketchUp.Preferences.AlwaysFixValidityErrors' -string 'YES'
  /usr/bin/defaults write com.google.sketchupfree8 'SketchUp.Preferences.DefaultTemplate' -string '/Library/Application Support/Google SketchUp 8/SketchUp/Resources/en-US/Templates/Temp02a - Arch.skp'
  /usr/bin/defaults write com.google.sketchupfree8 'OpenInspectors' -array

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Delete "NSToolbar Configuration SketchUpToolbar:TB Icon Size Mode"' > /dev/null 2>&1
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Icon Size Mode" integer 2'

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Delete "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers"' > /dev/null 2>&1
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers" array'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:0" string "SelectTool"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:1" string "LineTool"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:2" string "TapeMeasure"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:3" string "MoveTool"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:4" string "RotateTool"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:5" string "NSToolbarSpaceItem"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:6" string "Orbit"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:7" string "Pan"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:8" string "Zoom"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:9" string "ZoomExtents"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:10" string "NSToolbarSpaceItem"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:11" string "PositionCamera"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:12" string "LookAround"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:13" string "Walk"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:14" string "NSToolbarSpaceItem"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:15" string "ToggleTransparency"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:16" string "NSToolbarFlexibleSpaceItem"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:17" string "Measurements"'
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.google.sketchupfree8.plist" -c 'Add "NSToolbar Configuration SketchUpToolbar:TB Item Identifiers:18" string "ShowInspector"'


  ## Applications / Skype

  /usr/bin/defaults write com.skype.skype 'SKShowWelcomeOnLogin' -bool false
  /usr/bin/defaults write com.skype.skype 'SKMacUserSkypeVersion' -string '5.2.0.1572'
  /usr/bin/defaults write com.skype.skype 'ShowDialpadOnLogin' -bool false

  /usr/bin/defaults write com.skype.skype 'SKShowSystemStatusBarItem' -bool false

  /usr/bin/defaults write com.skype.skype 'SKDefaultPSTNCountryCode' -string 'us'

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.skype.skype.plist" -c 'Delete UserDefinedEvents' > /dev/null 2>&1
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.skype.skype.plist" -c 'Add UserDefinedEvents:SignIn:PlaySound integer 0' > /dev/null 2>&1
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.skype.skype.plist" -c 'Add UserDefinedEvents:ContactBecomesAvailable:PlaySound integer 0' > /dev/null 2>&1
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.skype.skype.plist" -c 'Add UserDefinedEvents:ContactBecomesAvailable:Display integer 0' > /dev/null 2>&1
  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.skype.skype.plist" -c 'Add UserDefinedEvents:ContactBecomesUnavailable:Display integer 0' > /dev/null 2>&1


  ## Applications / TextEdit

  /usr/bin/defaults write com.apple.TextEdit 'NSFixedPitchFont' -string 'Inconsolata'
  /usr/bin/defaults write com.apple.TextEdit 'NSFixedPitchFontSize' -string '15'
  /usr/bin/defaults write com.apple.TextEdit 'RichText' -int 0


  ## Applications / TextMate

  /usr/bin/defaults write com.macromates.textmate 'OakThemeManagerSelectedTheme' -string 'B80CD0D8-613C-46FD-9C06-A1201108BC2A'
  /usr/bin/defaults write com.macromates.textmate 'OakTextViewNormalFontName' -string 'Inconsolata'
  /usr/bin/defaults write com.macromates.textmate 'OakTextViewNormalFontSize' -int 15

  /usr/bin/defaults write com.macromates.textmate 'OakCreatorCodeAction' -string 'textmate'
  /usr/bin/defaults write com.macromates.textmate 'OakCreatorCodePreserve' -bool false
  /usr/bin/defaults write com.macromates.textmate 'OakSaveAtomically' -bool true

  /usr/bin/defaults write com.macromates.textmate 'OakTextViewLineNumbersEnabled' -bool true
  /usr/bin/defaults write com.macromates.textmate 'OakWrapColumns' '( 40, 72, 78 )'
  /usr/bin/defaults write com.macromates.textmate 'OakTextViewRightMarginColumn' -int 72

  /usr/bin/defaults write com.macromates.textmate 'MDSideViewLeft' -bool false

  /usr/bin/defaults write com.macromates.textmate 'OakDocumentWindowFrame' -string '{{51, 0}, {776, 1178}}'
  /usr/bin/defaults write com.macromates.textmate 'OakProjectWindowFrame' -string '{{51, 0}, {1027, 1178}}'
  /usr/bin/defaults write com.macromates.textmate 'MDMainViewFrame' -string '{{0, 0}, {776, 1156}}'
  /usr/bin/defaults write com.macromates.textmate 'MDSideViewFrame' -string '{{777, 0}, {250, 1156}}'

  /usr/bin/defaults write com.macromates.textmate 'OakEnhancedTerminalUsage' -dict 'didCreateLink' -bool false


  ## Applications / Things

  /usr/bin/defaults write com.culturedcode.things 'autoCleanupInterval' -int 0
  /usr/bin/defaults write com.culturedcode.things 'QuickEntryHotkeyEmpty' '<dict><key>characters</key><string>(null)</string><key>keyCode</key><integer>65535</integer><key>keyModifiers</key><integer>0</integer></dict>'
  /usr/bin/defaults write com.culturedcode.things 'QuickEntryHotkeyAutofill' '<dict><key>characters</key><string>(null)</string><key>keyCode</key><integer>65535</integer><key>keyModifiers</key><integer>0</integer></dict>'


  ## Applications / TotalFinder

  /usr/bin/defaults write com.apple.finder 'TotalFinderShowStatusItem' -bool false

  /usr/bin/defaults write com.apple.finder 'TotalFinderDontCustomizeDockIcon' -bool true


  /usr/bin/defaults write com.apple.finder 'TotalFinderSavedWindowPosTop' -int 612
  /usr/bin/defaults write com.apple.finder 'TotalFinderSavedWindowPosRight' -int 1920
  /usr/bin/defaults write com.apple.finder 'TotalFinderSavedWindowPosBottom' -int 1200
  /usr/bin/defaults write com.apple.finder 'TotalFinderSavedWindowPosLeft' -int 1080


  ## Applications / Tower

  /usr/bin/defaults write com.fournova.Tower 'GitConfigDiffTool' -string 'BBEdit'
  /usr/bin/defaults write com.fournova.Tower 'GitConfigMergeTool' -string 'BBEdit'
  /usr/bin/defaults write com.fournova.Tower 'GitHubUsername' -string 'ptb'
  /usr/bin/defaults write com.fournova.Tower 'PathToGitBinary' -string '/usr/local/bin/git'


  ## Applications / Transmission

  /usr/bin/defaults write org.m0k.transmission 'WarningLegal' -bool false

  /usr/bin/defaults write org.m0k.transmission 'AutoSize' -bool true

  /usr/bin/defaults write org.m0k.transmission 'DownloadLocationConstant' -bool true
  /usr/bin/defaults write org.m0k.transmission 'UseIncompleteDownloadFolder' -bool true

  /usr/bin/defaults write org.m0k.transmission 'PlayDownloadSound' -bool false


  ## Applications / VisualHub

  /usr/bin/defaults write com.techspansion.visualhub 'ipodh264' -string 'true'
  /usr/bin/defaults write com.techspansion.visualhub 'alwaysfaststart' -string 'true'
  /usr/bin/defaults write com.techspansion.visualhub 'playsound' -bool false


  ## Applications / VMWare Fusion

  /usr/bin/defaults write com.vmware.fusion 'collectOptionalUserData' -bool false

  /bin/mkdir -p -m 700 "$HOME/Library/Preferences/VMware Fusion/"
  /bin/cat > "$HOME/Library/Preferences/VMware Fusion/preferences" <<-EOF
	webUpdate.enabled = "FALSE"
	pref.autoSoftwareUpdatePermission = "deny"
	pref.trayicon.enabled = "false"
	pref.license0.registrationViewed = "TRUE"
	pref.license.maxNum = "1"
	pref.license0.version = "3.0+"
	EOF


  ## Applications / VueScan

  /bin/cat > "$HOME/Library/Preferences/vuescan.ini" <<-EOF
	[VueScan]
	[Prefs]
	StartupTip=0
	EOF


  ## Utilities / 1Password

  /usr/bin/defaults write ws.agile.1Password 'DisableCoreAnimation' -bool true


  ## Utilities / Airfoil

  /usr/bin/defaults write com.rogueamoeba.Airfoil 'didShowAirfoil4WelcomeWindow' -bool true
  /usr/bin/defaults write com.rogueamoeba.AirfoilSpeakers 'didShowAirfoil4WelcomeWindow' -bool true


  ## Utilities / Audio Hijack Pro

  /usr/bin/defaults write com.rogueamoeba.AudioHijackPro2 'didShowAirfoil4WelcomeWindow' -bool true


  ## Utilities / Carbon Copy Cloner

  /usr/bin/defaults write com.bombich.ccc 'cleanSync' -bool true


  ## Utilities / CodeBox

  /usr/bin/defaults write com.shpakovski.mac.codebox 'ActiveSyntaxes' -array-add 'text.haml' 'source.ruby.rails' 'source.sass'
  /usr/bin/defaults write com.shpakovski.mac.codebox 'EditorFont' -data '62706c6973743030d40102030405061819582476657273696f6e58246f626a65637473592461726368697665725424746f7012000186a0a40708111255246e756c6cd4090a0b0c0d0e0f105624636c617373564e534e616d65564e5353697a65584e5366466c6167738003800223402e00000000000010105b496e636f6e736f6c617461d2131415165a24636c6173736e616d655824636c6173736573564e53466f6e74a21517584e534f626a6563745f100f4e534b657965644172636869766572d11a1b54726f6f74800108111a232d32373c424b525960696b6d76788489949da4a7b0c2c5ca0000000000000101000000000000001c000000000000000000000000000000cc'
  /usr/bin/defaults write com.shpakovski.mac.codebox 'TabWidth' -int 2
  /usr/bin/defaults write com.shpakovski.mac.codebox 'ShowTableScrollbar' -bool true
  /usr/bin/defaults write com.shpakovski.mac.codebox 'CodebarShortcut' -string ''
  /usr/bin/defaults write com.shpakovski.mac.codebox 'ThemeID' -string 'B80CD0D8-613C-46FD-9C06-A1201108BC2A'


  ## Utilities / Composer

  /usr/bin/defaults write com.jamfsoftware.composer 'beepWhenDone' -bool false


  ## Utilities / Disk Utility

  /usr/bin/defaults write com.apple.DiskUtility 'DUDebugMenuEnabled' -bool true


  ## Utilities / Dropbox

  /usr/bin/defaults write com.apple.finder 'CreateDesktop' -bool false

  /usr/bin/killall Finder
  /usr/bin/open /Applications/TotalFinder.app


  ## Utilities / ExpanDrive

  /usr/bin/defaults write com.expandrive.ExpanDrive2 'ShowManagerAtLaunch' -bool false


  ## Utilities / gfxCardStatus

  /usr/bin/defaults write com.codykrieger.gfxCardStatus-Preferences 'hasSeenVersionTwoMessage' -bool true
  /usr/bin/defaults write com.codykrieger.gfxCardStatus-Preferences 'shouldUsePowerSourceBasedSwitching' -bool true


  ## Utilities / Handbrake

  /usr/bin/defaults write org.m0k.handbrake 'AlertWhenDone' -string 'Do Nothing'
  /usr/bin/defaults write org.m0k.handbrake 'DefaultAutoNaming' -bool true
  /usr/bin/defaults write org.m0k.handbrake 'DefaultMpegName' -bool true


  ## Utilities / I Love Stars

  /usr/bin/defaults write com.potionfactory.ILoveStars.mac 'flashOnUnrated' -bool false
  /usr/bin/defaults write com.potionfactory.ILoveStars.mac 'beepOnUnrated' -bool false
  /usr/bin/defaults write com.potionfactory.ILoveStars.mac 'hidesCompletely' -bool true
  /usr/bin/defaults write com.potionfactory.ILoveStars.mac 'hidesCompletelyAlertSuppress' -bool true


  ## Utilities / iStat Menus

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'UseMono' -int 0
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'UseRoundedCorners' -int 0
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'skinColor' -int 2

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'CPUDisplayMode' -string '100,0'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'CPUUseCustomGraphColors' -int 1
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'CPUOverallGraphColor' -data '62706c6973743030d401020304050817185424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a3090a1155246e756c6cd30b0c0d0e0f10554e535247425c4e53436f6c6f7253706163655624636c6173734f10103020302e32303030303030303320300010018002d2121314155824636c61737365735a24636c6173736e616d65a21516574e53436f6c6f72584e534f626a65637412000186a05f100f4e534b6579656441726368697665720811161f2832353a3c40464d5360677a7c7e838c979aa2abb000000000000001010000000000000019000000000000000000000000000000c2'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'CPUMultiple' -int 1

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'MemoryDisplayMode' -string '100,6'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'MemoryUseCustomGraphColors' -int 1
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'MemoryOverallGraphColor' -data '62706c6973743030d401020304050817185424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a3090a1155246e756c6cd30b0c0d0e0f10554e535247425c4e53436f6c6f7253706163655624636c6173734f10103020302e32303030303030303320300010018002d2121314155824636c61737365735a24636c6173736e616d65a21516574e53436f6c6f72584e534f626a65637412000186a05f100f4e534b6579656441726368697665720811161f2832353a3c40464d5360677a7c7e838c979aa2abb000000000000001010000000000000019000000000000000000000000000000c2'

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'NetworkDisplayMode' -string '100,0,1'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'NetworkUseCustomGraphColors' -int 1
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'NetworkTxGraphColor' -data '62706c6973743030d401020304050817185424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a3090a1155246e756c6cd30b0c0d0e0f10554e535247425c4e53436f6c6f7253706163655624636c6173734f1010302e343030303030303036203020300010018002d2121314155824636c61737365735a24636c6173736e616d65a21516574e53436f6c6f72584e534f626a65637412000186a05f100f4e534b6579656441726368697665720811161f2832353a3c40464d5360677a7c7e838c979aa2abb000000000000001010000000000000019000000000000000000000000000000c2'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'NetworkRxGraphColor' -data '62706c6973743030d401020304050817185424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a3090a1155246e756c6cd30b0c0d0e0f10554e535247425c4e53436f6c6f7253706163655624636c6173734f10103020302e32303030303030303320300010018002d2121314155824636c61737365735a24636c6173736e616d65a21516574e53436f6c6f72584e534f626a65637412000186a05f100f4e534b6579656441726368697665720811161f2832353a3c40464d5360677a7c7e838c979aa2abb000000000000001010000000000000019000000000000000000000000000000c2'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'NetworkGraphMode' -int 2

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'ClockDisplayMode' -array 'EE' "' '" 'MMM' "' '" 'd' "' · '" 'h' "':'" 'mm' "':'" 'ss' "' '" 'a'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'CalShowWeekNumbers' -int 1
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'ClockTextColor' -data '62706c6973743030d401020304050817185424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a3090a1155246e756c6cd30b0c0d0e0f10554e535247425c4e53436f6c6f7253706163655624636c6173734630203020300010018002d2121314155824636c61737365735a24636c6173736e616d65a21516574e53436f6c6f72584e534f626a65637412000186a05f100f4e534b6579656441726368697665720811161f2832353a3c40464d5360676e707277808b8e969fa400000000000001010000000000000019000000000000000000000000000000b6'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'ClockFontSize' -int 14

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'BatteryColoredGraphUseCustomColors' -int 1

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'BatteryDisplayModeCharged' -string '4'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'BatteryColoredGraphChargedColor' -data '62706c6973743030d401020304050817185424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a3090a1155246e756c6cd30b0c0d0e0f10554e535247425c4e53436f6c6f7253706163655624636c6173734f1027302e3630303030303032333820302e3830303030303031313920302e363030303030303233380010018002d2121314155824636c61737365735a24636c6173736e616d65a21516574e53436f6c6f72584e534f626a65637412000186a05f100f4e534b6579656441726368697665720811161f2832353a3c40464d5360679193959aa3aeb1b9c2c700000000000001010000000000000019000000000000000000000000000000d9'

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'BatteryDisplayModeCharging' -string '4,0'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'BatteryColoredGraphChargingColor' -data '62706c6973743030d401020304050817185424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a3090a1155246e756c6cd30b0c0d0e0f10554e535247425c4e53436f6c6f7253706163655624636c6173734f1027302e3630303030303032333820302e3830303030303031313920302e363030303030303233380010018002d2121314155824636c61737365735a24636c6173736e616d65a21516574e53436f6c6f72584e534f626a65637412000186a05f100f4e534b6579656441726368697665720811161f2832353a3c40464d5360679193959aa3aeb1b9c2c700000000000001010000000000000019000000000000000000000000000000d9'

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'BatteryDisplayModeDraining' -string '4,1'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'BatteryColoredGraphDrainingColor' -data '62706c6973743030d401020304050817185424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a3090a1155246e756c6cd30b0c0d0e0f10554e535247425c4e53436f6c6f7253706163655624636c6173734f1025302e3830303030303031313920302e34303030303030303620302e3430303030303030360010018002d2121314155824636c61737365735a24636c6173736e616d65a21516574e53436f6c6f72584e534f626a65637412000186a05f100f4e534b6579656441726368697665720811161f2832353a3c40464d5360678f919398a1acafb7c0c500000000000001010000000000000019000000000000000000000000000000d7'
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'BatteryColoredGraphLowColor' -data '62706c6973743030d401020304050817185424746f7058246f626a65637473582476657273696f6e59246172636869766572d1060754726f6f748001a3090a1155246e756c6cd30b0c0d0e0f10554e535247425c4e53436f6c6f7253706163655624636c6173734f1025302e3830303030303031313920302e34303030303030303620302e3430303030303030360010018002d2121314155824636c61737365735a24636c6173736e616d65a21516574e53436f6c6f72584e534f626a65637412000186a05f100f4e534b6579656441726368697665720811161f2832353a3c40464d5360678f919398a1acafb7c0c500000000000001010000000000000019000000000000000000000000000000d7'

  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'BatteryCustomizeStates' -int 1


  ## Utilities / Menubar Countdown

  /usr/bin/defaults write net.capablehands.Menubar_Countdown 'ShowStartDialogOnLaunch' -bool false


  ## Utilities / PCalc

  /usr/bin/defaults write uk.co.tla-systems.pcalc 'CalcStyle' -string 'uk.co.tla-systems.pcalc.layout.default'
  /usr/bin/defaults write uk.co.tla-systems.pcalc 'CalcThemeID' -string 'uk.co.tla-systems.pcalc.theme.color'
  /usr/bin/defaults write uk.co.tla-systems.pcalc 'ClearCalculatorsAtStartup' -bool true
  /usr/bin/defaults write uk.co.tla-systems.pcalc 'DontAskAboutWidgetInstall' -bool true
  /usr/bin/defaults write uk.co.tla-systems.pcalc 'DontAskAboutWidgetUpgrade' -bool true


  ## Utilities / Quicksilver

  /usr/bin/defaults write com.blacktree.Quicksilver 'Last Used Version' -string '3850'
  /usr/bin/defaults write com.blacktree.Quicksilver 'Setup Assistant Completed' -bool true
  /usr/bin/defaults write com.blacktree.Quicksilver 'Use Effects' -bool false

  /usr/bin/defaults write com.blacktree.Quicksilver 'QSCommandInterfaceControllers' -string 'QSFlashlightInterface'


  ## Utilities / SizeUp

  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'StartAtLogin' -bool true
  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'ShowPrefsOnNextStart' -bool false
  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'ShowTooltips' -bool false
  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'MarginHorizontal' -int 2
  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'MarginVertical' -int 2
  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'SplitScreenVertical' -int 55
  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'QuarterScreenVertical' -int 55


  ## Utilities / SMARTReporter

  /usr/bin/defaults write org.corecode.SMARTReporter 'iconset' -int 2
  /usr/bin/defaults write org.corecode.SMARTReporter 'look' -int 0
  /usr/bin/defaults write org.corecode.SMARTReporter 'updatecheckMenuindex' -int 6
  /usr/bin/defaults write org.corecode.SMARTReporter 'use_redicon' -bool true


  ## Utilities / Synergy

  /usr/bin/defaults write org.wincent.Synergy 'Launch at login' -bool true
  /usr/bin/defaults write org.wincent.Synergy 'Use floating notification window' -bool false
  /usr/bin/defaults write org.wincent.Synergy 'Activate global hot-keys' -bool false
  /usr/bin/defaults write org.wincent.Synergy 'Display Menu Bar controls only when iTunes running' -bool true
  /usr/bin/defaults write org.wincent.Synergy 'Menu bar button style' -string 'Walt'
  /usr/bin/defaults write org.wincent.Synergy 'Use random button style' -bool false
  /usr/bin/defaults write org.wincent.Synergy 'Activate global menu' -bool false
  /usr/bin/defaults write org.wincent.Synergy 'Automatically connect to Internet' -bool false


  ## Utilities / Viscosity

  /usr/bin/defaults write com.viscosityvpn.Viscosity 'DisplayWelcome' -bool false
  /usr/bin/defaults write com.viscosityvpn.Viscosity 'FirstRun' -string 'NO'


  ## Utilities / WeatherDock

  /usr/bin/defaults write nl.alwintroost.WeatherDock 'bounceOnTemperature' -bool false
  /usr/bin/defaults write nl.alwintroost.WeatherDock 'bounceOnCondition' -bool false
  /usr/bin/defaults write nl.alwintroost.WeatherDock 'badgeOnTemperature' -bool false
  /usr/bin/defaults write nl.alwintroost.WeatherDock 'badgeOnCondition' -bool false
  /usr/bin/defaults write nl.alwintroost.WeatherDock 'hideMainWindowOnStartUp' -bool true
  /usr/bin/defaults write nl.alwintroost.WeatherDock 'allowDockIconHiding' -bool true
  /usr/bin/defaults write nl.alwintroost.WeatherDock 'hideDockIcon' -bool true

}

function disable_software_update_prefs () {
# Library Items Software Update Preferences

  ## Library / ColorPickers / Hex Color Picker

  /usr/bin/defaults -currentHost write -g 'HexColorPickerPrefAskedAboutUpdates' -bool true
  /usr/bin/defaults -currentHost write -g 'HexColorPickerPrefCheckForUpdates' -bool false

  ## Library / Internet Plug-Ins / Flip4Mac
  /usr/bin/defaults write net.telestream.wmv 'UpdateCheck_CheckInterval' -int 9999


# System Preferences Software Update Preferences

  ## System Preferences > Choosy
  /usr/bin/defaults write com.choosyosx.ChoosyPrefPane 'SUAutomaticallyUpdate' -bool false
  /usr/bin/defaults write com.choosyosx.ChoosyPrefPane 'SUEnableAutomaticChecks' -bool false
  /usr/bin/defaults write com.choosyosx.ChoosyPrefPane 'SUSendProfileInfo' -bool false

  ## System Preferences > Growl
  /usr/bin/defaults write com.Growl.GrowlHelperApp 'GrowlUpdateCheck' -bool false

  ## System Preferences > Perian
  /usr/bin/defaults write org.perian.Perian 'NextRunDate' -date '4001-01-01 00:00:00 +0000'


# Application Software Update Preferences

  ## Applications / BBEdit
  /usr/bin/defaults write com.barebones.bbedit 'SUSoftwareUpdateEnabled' -bool false

  ## Applications / iWork
  /usr/bin/defaults write com.apple.iWork 'SFLDefaultsAutoUpdateCheck' -bool false

  ## Applications / iWork / Keynote
  /usr/bin/defaults write com.apple.iWork.Keynote 'SFLDefaultsNextUpdateCheck' -date '2050-01-01T12:00:00Z'

  ## Applications / iWork / Numbers
  /usr/bin/defaults write com.apple.iWork.Numbers 'SFLDefaultsNextUpdateCheck' -date '2050-01-01T12:00:00Z'

  ## Applications / iWork / Pages
  /usr/bin/defaults write com.apple.iWork.Pages 'SFLDefaultsNextUpdateCheck' -date '2050-01-01T12:00:00Z'

  ## Applications / Quinn
  /usr/bin/defaults write Quinn 'SUCheckAtStartup' -bool false

  ## Applications / Radioshift
  /usr/bin/defaults write com.rogueamoeba.Radioshift 'versionChecking' -bool false

  ## Applications / Seashore
  /usr/bin/defaults write net.sourceforge.seashore 'checkForUpdates' -string 'NO'

  ## Applications / SketchUp
  /usr/bin/defaults write com.google.sketchupfree8 'SketchUp.Preferences.CheckForUpdates' -string 'NO'

  ## Applications / Skype
  /usr/bin/defaults write com.skype.skype 'SKCheckUpdatesAutomatically' -bool false

  ## Applications / SubEthaEdit
  /usr/bin/defaults write de.codingmonkeys.SubEthaEdit 'SUEnableAutomaticChecks' -bool false

  ## Applications / TextMate
  /usr/bin/defaults write com.macromates.textmate 'OakSoftwareUpdateAutomaticCheckEnabled' -bool false
  /usr/bin/defaults write com.macromates.textmate 'OakAskBeforeDownloadingUpdate' -bool true

  ## Applications / Things
  /usr/bin/defaults write com.culturedcode.things 'SUEnableAutomaticChecks' -bool false
  /usr/bin/defaults write com.culturedcode.things 'SUSendProfileInfo' -bool false

  ## Applications / TotalFinder
  /usr/bin/defaults write com.binaryage.totalfinder 'SUEnableAutomaticChecks' -bool false
  /usr/bin/defaults write com.binaryage.totalfinder 'SUSendProfileInfo' -bool false

  ## Applications / Tower
  /usr/bin/defaults write com.fournova.Tower 'SUEnableAutomaticChecks' -bool false

  ## Applications / Transmission
  /usr/bin/defaults write org.m0k.transmission 'SUEnableAutomaticChecks' -bool false

  ## Applications / VisualHub
  /usr/bin/defaults write com.techspansion.visualhub 'SUCheckAtStartup' -bool false


# Utilities Software Update Preferences

  ## Utilities / 1Password
  /usr/bin/defaults write ws.agile.1Password 'AGUpdateEnabled' -bool false

  ## Utilities / Airfoil
  /usr/bin/defaults write com.rogueamoeba.Airfoil 'versionChecking' -bool false

  ## Utilities / Airfoil Speakers
  /usr/bin/defaults write com.rogueamoeba.AirfoilSpeakers 'versionChecking' -bool false

  ## Utilities / AirPort Utility

  /usr/bin/defaults write com.apple.airport.airportutility 'confirmedAutoUpdatesAndMonitoring' -bool true
  /usr/bin/defaults write com.apple.airport.airportutility 'dontCheckForUpdates' -bool true

  ## Utilities / Audio Hijack Pro
  /usr/bin/defaults write com.rogueamoeba.AudioHijackPro2 'versionChecking' -bool false

  ## Utilities / Carbon Copy Cloner
  /usr/bin/defaults write com.bombich.ccc 'SUCheckAtStartup' -bool false
  /usr/bin/defaults write com.bombich.ccc 'SUScheduledCheckInterval' -int 0

  ## Utilities / ExpanDrive
  /usr/bin/defaults write com.expandrive.ExpanDrive2 'SUEnableAutomaticChecks' -bool false
  /usr/bin/defaults write com.expandrive.ExpanDrive2 'SUSendProfileInfo' -bool false

  ## Utilities / gfxCardStatus
  /usr/bin/defaults write com.codykrieger.gfxCardStatus-Preferences 'shouldCheckForUpdatesOnStartup' -bool false

  ## Utilities / Handbrake
  /usr/bin/defaults write org.m0k.handbrake 'SUCheckAtStartup' -bool false

  ## Utilities / iStat Menus
  /usr/bin/defaults write com.iSlayer.iStatMenusPreferences 'updateCheckerEnabled' -int 0

  ## Utilities / PCalc
  /usr/bin/defaults write uk.co.tla-systems.pcalc 'AutomaticallyCheckForUpdates' -bool false

  ## Utilities / SizeUp
  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'SUEnableAutomaticChecks' -bool false
  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'SUSendProfileInfo' -bool false
  /usr/bin/defaults write com.irradiatedsoftware.SizeUp 'SUHasLaunchedBefore' -bool true

  ## Utilities / SMARTReporter
  /usr/bin/defaults write org.corecode.SMARTReporter 'SUEnableAutomaticChecks' -bool false

  ## Utilities / Synergy
  /usr/bin/defaults write org.wincent.Synergy 'Automatic Internet version checking interval' -int 99999999

  ## Utilities / Viscosity
  /usr/bin/defaults write com.viscosityvpn.Viscosity 'SUEnableAutomaticChecks' -bool false
  /usr/bin/defaults write com.viscosityvpn.Viscosity 'SUHasLaunchedBefore' -bool true
  /usr/bin/defaults write com.viscosityvpn.Viscosity 'SUSendProfileInfo' -bool false

}

function configure_dock_apps () {

  /usr/bin/defaults write com.apple.dock 'checked-for-launchpad' -bool true

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.dock.plist" -c 'Delete :persistent-apps'

  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTunes.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Mail.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Safari.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Things.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Skype.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/SketchUp.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Preview.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/TextMate.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Utilities/Terminal.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
  /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/System Preferences.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

  # /usr/bin/defaults write com.apple.dock 'persistent-apps' -array-add '{ tile-data = {}; tile-type = "spacer-tile"; }'

  /usr/libexec/PlistBuddy "$HOME/Library/Preferences/com.apple.dock.plist" -c 'Delete :persistent-others'

  /usr/bin/defaults write com.apple.dock 'persistent-others' -array-add "<dict><key>tile-data</key><dict><key>arrangement</key><integer>0</integer><key>displayas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>$HOME/Dropbox/</string><key>_CFURLStringType</key><integer>0</integer></dict><key>preferreditemsize</key><integer>-1</integer><key>showas</key><integer>3</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"

  # /usr/bin/defaults write com.apple.dock 'persistent-others' -array-add '{ tile-data = {}; tile-type = "spacer-tile"; }'

  /usr/bin/osascript -e 'tell application "Dock" to quit'

}

function setup_help () {
  /bin/cat <<-EOF
		Set these environment variables:
		  COMPUTERNAME='Mac'
		  LOCALHOSTNAME='mac'

		Then enter any of these functions:
		  set_system_preferences
		  set_hidden_preferences
		  disable_software_update_prefs
		  set_application_preferences
		  configure_dock_apps
	EOF
}

setup_help
