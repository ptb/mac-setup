#!/bin/sh
sudo tee -a /etc/sudoers > /dev/null <<-EOF
Defaults  timestamp_timeout=-1
%admin ALL=(ALL) NOPASSWD:SETENV: /usr/sbin/installer
EOF

sudo pmset -a sleep 0
sudo pmset -a disksleep 0

if ! grep -Fq '/usr/local/sbin' /etc/paths; then
  sudo sed -i -e '/\/usr\/sbin/i\
\/usr\/local\/sbin\
' /etc/paths
fi

sudo mkdir -p '/usr/local/Caskroom' "${HOME}/Library/Caches/Homebrew/"
sudo chgrp admin '/usr/local/' '/usr/local/Caskroom/' "${HOME}/Library/Caches/Homebrew/" '/Library/ColorPickers/' '/Library/Screen Savers/'
sudo chmod g+w '/usr/local/' '/usr/local/Caskroom/' "${HOME}/Library/Caches/Homebrew/" '/Library/ColorPickers/' '/Library/Screen Savers/'

sudo tee /etc/environment > /dev/null <<-EOF
#!/bin/sh

set -e

syslog -s -l warn "Set environment variables for \$(whoami) - start"

CASK_OPTS="--appdir=/Applications"
CASK_OPTS="\${CASK_OPTS} --caskroom=/usr/local/Caskroom"
CASK_OPTS="\${CASK_OPTS} --colorpickerdir=/Library/ColorPickers"
CASK_OPTS="\${CASK_OPTS} --fontdir=/Library/Fonts"
CASK_OPTS="\${CASK_OPTS} --prefpanedir=/Library/PreferencePanes"
CASK_OPTS="\${CASK_OPTS} --screen_saverdir='/Library/Screen Savers'"
export HOMEBREW_CASK_OPTS=\$CASK_OPTS
launchctl setenv HOMEBREW_CASK_OPTS "\$CASK_OPTS"

if [ -x /usr/libexec/path_helper ]; then
  export PATH=""
  eval \`/usr/libexec/path_helper -s\`
  launchctl setenv PATH \$PATH
fi

osascript -e 'tell app "Dock" to quit'

syslog -s -l warn "Set environment variables for \$(whoami) - complete"
EOF

sudo chmod a+x /etc/environment

sudo defaults write '/Library/LaunchAgents/environment.user' 'Label' -string 'environment.user'
sudo defaults write '/Library/LaunchAgents/environment.user' 'ProgramArguments' -array-add '/etc/environment'
sudo defaults write '/Library/LaunchAgents/environment.user' 'RunAtLoad' -bool true
sudo defaults write '/Library/LaunchAgents/environment.user' 'WatchPaths' -array-add '/etc/environment'
sudo defaults write '/Library/LaunchAgents/environment.user' 'WatchPaths' -array-add '/etc/paths'
sudo defaults write '/Library/LaunchAgents/environment.user' 'WatchPaths' -array-add '/etc/paths.d'
sudo plutil -convert xml1 '/Library/LaunchAgents/environment.user.plist'
sudo chmod 644 /Library/LaunchAgents/environment.user.plist
sudo launchctl load -w /Library/LaunchAgents/environment.user.plist

sudo defaults write '/Library/LaunchDaemons/environment' 'Label' -string 'environment'
sudo defaults write '/Library/LaunchDaemons/environment' 'ProgramArguments' -array-add '/etc/environment'
sudo defaults write '/Library/LaunchDaemons/environment' 'RunAtLoad' -bool true
sudo defaults write '/Library/LaunchDaemons/environment' 'WatchPaths' -array-add '/etc/environment'
sudo defaults write '/Library/LaunchDaemons/environment' 'WatchPaths' -array-add '/etc/paths'
sudo defaults write '/Library/LaunchDaemons/environment' 'WatchPaths' -array-add '/etc/paths.d'
sudo plutil -convert xml1 '/Library/LaunchDaemons/environment.plist'
sudo chmod 644 /Library/LaunchDaemons/environment.plist
sudo launchctl load -w /Library/LaunchDaemons/environment.plist

echo -n "Enter full name: "
read FULLNAME

echo -n "Enter account name: "
read USERNAME

echo -n "Enter password: "
read -s PASSWORD

LASTID=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)
USERID=$((LASTID+1))

sudo dscl . -create "/Users/${USERNAME}"
sudo dscl . -create "/Users/${USERNAME}" UserShell /bin/zsh
sudo dscl . -create "/Users/${USERNAME}" RealName "${FULLNAME}"
sudo dscl . -create "/Users/${USERNAME}" UniqueID "${USERID}"
sudo dscl . -create "/Users/${USERNAME}" PrimaryGroupID 20
sudo dscl . -create "/Users/${USERNAME}" NFSHomeDirectory "/Users/${USERNAME}"
sudo dscl . -passwd "/Users/${USERNAME}" "${PASSWORD}"

ADMIN_GROUPS="admin appserveradm appserverusr com.apple.sharepoint.group.1 lpadmin"
for GROUP in $ADMIN_GROUPS ; do
  sudo dseditgroup -o edit -t user -a $USERNAME $GROUP
done

sudo createhomedir -c -u $USERNAME 2> /dev/null

sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

osascript -e 'tell app "loginwindow" to «event aevtrrst»'
