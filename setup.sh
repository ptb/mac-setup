#!/bin/sh

COMPUTERNAME='Mac'
LOCALHOSTNAME='mac'

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
    /usr/bin/defaults write com.apple.dock 'dashboard-in-overlay' bool true


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


  ## System Preferences > Sharing

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
