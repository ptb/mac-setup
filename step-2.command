#!/bin/sh
if [ -z "$1" ]; then
  osascript > /dev/null <<-END
    tell app "Terminal" to do script "source ${0} 0"
END
  clear

else

function init_install_path () {
  if [ ! -d "/Volumes/Storage" ] \
    && [ -d "/Volumes/VMware Shared Folders/Storage" ]; then
    cd "/Volumes" \
      && sudo ln -s "VMware Shared Folders/Storage" "Storage"
  fi

  if [ -d "/Volumes/Storage/Software" ]; then
    INSTALL_PATH="/Volumes/Storage/Software"
  else
    INSTALL_PATH="${HOME}/Downloads"
  fi
}

function install_command_line_tools () {
  init_install_path

  INSTALL_PATH_XCODE="${INSTALL_PATH}/apple.com"

  if [ ! -d "${INSTALL_PATH_XCODE}" ]; then
    mkdir -p "${INSTALL_PATH_XCODE}"
  fi

  if [ ! -f "${INSTALL_PATH_XCODE}/CLTools_Executables.pkg" ] \
    || [ ! -f "${INSTALL_PATH_XCODE}/DevSDK_OSX1011.pkg" ]; then
    cd "${INSTALL_PATH_XCODE}" \
      && curl --compressed --location --silent \
      "https://swscan.apple.com/content/catalogs/others/index-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog.gz" \
      | sed -n \
        -e "s/^.*<string>\(.*CLTools_Executables.pkg\).*/\1/p" \
        -e "s/^.*<string>\(.*DevSDK_OSX1011.pkg\).*/\1/p" \
      | tail -n 2 \
      | xargs -L 1 curl --compressed --location --remote-name
  fi

  if [ -f "${INSTALL_PATH_XCODE}/CLTools_Executables.pkg" ] \
    && [ -f "${INSTALL_PATH_XCODE}/DevSDK_OSX1011.pkg" ]; then
    sudo installer -pkg "${INSTALL_PATH_XCODE}/CLTools_Executables.pkg" -target /
    sudo installer -pkg "${INSTALL_PATH_XCODE}/DevSDK_OSX1011.pkg" -target /
  fi
}

function install_homebrew () {
  sudo chown $(whoami) '/usr/local' '/usr/local/Caskroom' '/Library/Caches/Homebrew/'

  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  brew update
  brew doctor

  brew tap "caskroom/cask"
  brew tap "homebrew/bundle"
}

function create_brew_update_script () {
  cat > /usr/local/bin/brew-update.sh <<-EOF
#!/bin/sh

brew update
brew doctor

brew cask install "caskroom/fonts/font-inconsolata-lgc" 2> /dev/null
brew cask install "ptb/custom/blankscreen" 2> /dev/null

# Details: https://github.com/caskroom/homebrew-cask/issues/13201
# Source: https://github.com/caskroom/homebrew-cask/pull/13966/files?diff=split

curl --compressed --location --show-error --silent \\
  --url https://github.com/mwean/homebrew-cask/raw/master/lib/hbc/artifact.rb \\
  --output /usr/local/Library/Taps/caskroom/homebrew-cask/lib/hbc/artifact.rb

curl --compressed --location --show-error --silent \\
  --url https://github.com/mwean/homebrew-cask/raw/master/lib/hbc/artifact/app.rb \\
  --output /usr/local/Library/Taps/caskroom/homebrew-cask/lib/hbc/artifact/app.rb

curl --compressed --location --show-error --silent \\
  --url https://github.com/mwean/homebrew-cask/raw/master/lib/hbc/artifact/moved.rb \\
  --output /usr/local/Library/Taps/caskroom/homebrew-cask/lib/hbc/artifact/moved.rb

curl --compressed --location --show-error --silent \\
  --url https://github.com/mwean/homebrew-cask/raw/master/lib/hbc/artifact/suite.rb \\
  --output /usr/local/Library/Taps/caskroom/homebrew-cask/lib/hbc/artifact/suite.rb

curl --compressed --location --show-error --silent \\
  --url https://github.com/mwean/homebrew-cask/raw/master/lib/hbc/dsl/postflight.rb \\
  --output /usr/local/Library/Taps/caskroom/homebrew-cask/lib/hbc/dsl/postflight.rb

curl --compressed --location --show-error --silent \\
  --url https://github.com/mwean/homebrew-cask/raw/master/lib/hbc/staged.rb \\
  --output /usr/local/Library/Taps/caskroom/homebrew-cask/lib/hbc/staged.rb

sed -i -e "s/@cask.staged_path/Hbc.appdir/" \\
  /usr/local/Library/Taps/caskroom/homebrew-cask/lib/hbc/artifact/symlinked.rb

cd /usr/local/ && brew bundle

brew upgrade --all
brew linkapps
EOF

  chmod +x /usr/local/bin/brew-update.sh
}

function create_brewfile () {
  cat > /usr/local/Brewfile <<-EOF
tap "caskroom/cask"
tap "homebrew/bundle"

cask "java"

brew "aspell", args: ["lang=en"]
brew "duti"
brew "railwaycat/emacsmacport/emacs-mac", args: ["with-spacemacs-icon"]
brew "ptb/custom/ffmpeg",
  args: [
  'with-faac',
  'with-fdk-aac',
  'with-ffplay',
  'with-fontconfig',
  'with-freetype',
  'with-frei0r',
  'with-lame',
  'with-libass',
  'with-libbluray',
  'with-libcaca',
  'with-libsoxr',
  'with-libssh',
  'with-libvidstab',
  'with-libvorbis',
  'with-libvpx',
  'with-opencore-amr',
  'with-openjpeg',
  'with-openssl',
  'with-opus',
  'with-rtmpdump',
  'with-schroedinger',
  'with-speex',
  'with-theora',
  'with-tools',
  'with-webp',
  'with-x264',
  'with-x265',
  'with-xvid',
  'with-zeromq' ]
brew "git"
brew "git-annex"
brew "gnu-sed", args: ["with-default-names"]
brew "gnupg"
brew "gpac", args: ["HEAD"]
brew "imagemagick"
brew "mercurial"
brew "mp4v2"
brew "mtr"
brew "nmap"
brew "node"
brew "openssl"
brew "homebrew/dupes/rsync"
brew "python"
brew "ruby"
brew "sqlite"
brew "stow"
brew "terminal-notifier"
brew "trash"
brew "vim"
brew "wget"
brew "youtube-dl"
brew "zsh"

cask "adium"
cask "adobe-illustrator-cc"
cask "adobe-indesign-cc"
cask "adobe-photoshop-cc"
cask "airfoil"
cask "alfred"
cask "arduino"
cask "atom"
cask "autodmg"
cask "bettertouchtool"
cask "caffeine"
cask "charles"
cask "couchpotato"
cask "dash"
cask "deluge"
cask "dockertoolbox"
cask "dropbox"
cask "expandrive"
cask "firefox"
cask "github-desktop"
cask "gitup"
cask "google-chrome"
cask "handbrake"
cask "handbrakecli"
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
cask "microsoft-office"
cask "moom"
cask "mp4tools"
cask "munki"
cask "namechanger"
cask "nvalt"
cask "nzbget"
cask "nzbvortex"
cask "openemu"
cask "opera"
cask "pacifist"
cask "platypus"
cask "plex-media-server"
cask "raindrop"
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
cask "caskroom/versions/sublime-text3"
cask "the-unarchiver"
cask "torbrowser"
cask "tower"
cask "transmit"
cask "vimr"
cask "vlc"
cask "vmware-fusion"
cask "xld"

cask "xquartz"
cask "inkscape"
cask "wireshark"

cask "ptb/custom/bbedit-10"
cask "ptb/custom/carbon-copy-cloner"
cask "ptb/custom/composer"
cask "ptb/custom/enhanced-dictation"
cask "ptb/custom/ipmenulet"
cask "ptb/custom/mas-1password"
cask "ptb/custom/mas-affinity-photo"
cask "ptb/custom/mas-autoping"
cask "ptb/custom/mas-coffitivity"
cask "ptb/custom/mas-growl"
cask "ptb/custom/mas-hardwaregrowler"
cask "ptb/custom/mas-i-love-stars"
cask "ptb/custom/mas-icon-slate"
cask "ptb/custom/mas-justnotes"
cask "ptb/custom/mas-keynote"
cask "ptb/custom/mas-numbers"
cask "ptb/custom/mas-pages"
cask "ptb/custom/mas-wifi-explorer"
cask "ptb/custom/mas-xcode"
cask "ptb/custom/pcalc-3"
cask "ptb/custom/sketchup-pro"
cask "ptb/custom/synergy"
cask "ptb/custom/text-to-speech-allison"
cask "ptb/custom/tune4mac"
EOF
}

function install_osx_software () {
  init_install_path

  INSTALL_PATH_HOMEBREW="${INSTALL_PATH}/github.com/Homebrew"

  if [ -d "${INSTALL_PATH_HOMEBREW}" ]; then
    cd "$(cd "${INSTALL_PATH_HOMEBREW}" && pwd)" \
      && cp -av * /Library/Caches/Homebrew/
  fi

  /usr/local/bin/brew-update.sh

  cd $(cd /usr/local/Caskroom/little-snitch/* && pwd) && open "Little Snitch Installer.app"
}

function install_node_software () {
  npm install -g bower polyserve svgo
}

function install_python_software () {
  curl -Ls https://bootstrap.pypa.io/get-pip.py | sudo -H python
  pip install --upgrade pip setuptools
  pip install --upgrade babelfish bottle 'guessit<2' influxdb netifaces pika psutil py2app pyobjc-core pysnmp pystache qtfaststart requests statsd subliminal watchdog yapf zeroconf
  pip install --upgrade glances pyobjc 'requests[security]'
}

function install_ruby_software () {
  printf "%s\n" \
    "gem: --no-document" \
    >> "${HOME}/.gemrc"

  gem update --system
  gem update
  gem install nokogiri -- --use-system-libraries
  gem install web-console --version "~> 2"
  gem install rails sqlite3 sass-rails uglifier coffee-rails jquery-rails turbolinks jbuilder sdoc byebug spring tzinfo-data
  gem install em-websocket middleman middleman-autoprefixer middleman-blog middleman-compass middleman-livereload middleman-minify-html middleman-robots mime-types slim
  gem install bootstrap-sass git-cipher org-ruby thin
}

function create_vi_script () {
  cat > /usr/local/bin/vi <<-EOF
#!/bin/sh

if [ -e '/Applications/Emacs.app' ]; then
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
}

function link_utilities () {
  cd /Applications/Utilities \
    && for a in /System/Library/CoreServices/Applications/*; do
      sudo ln -s "../..$a" .
    done \
    && for b in /Applications/Xcode.app/Contents/Applications/*; do
      sudo ln -s "../..$b" .
    done \
    && for c in /Applications/Xcode.app/Contents/Developer/Applications/*; do
      sudo ln -s "../..$c" .
    done
}

function reenable_sudo_timeout () {
  sudo sed -i -e "/Defaults  timestamp_timeout=-1/d" /etc/sudoers
  sudo sed -i -e "/%admin ALL=(ALL) NOPASSWD:SETENV: \/usr\/sbin\/installer/d" /etc/sudoers
}

function install_all () {
  install_command_line_tools
  install_homebrew
  create_brew_update_script
  create_brewfile
  install_osx_software
  install_node_software
  install_python_software
  install_ruby_software
  create_vi_script
  link_utilities
  reenable_sudo_timeout
}

clear
cat <<-END

Enter any of these commands:
  install_command_line_tools
  install_homebrew
  create_brew_update_script
  create_brewfile
  install_osx_software
  install_node_software
  install_python_software
  install_ruby_software
  create_vi_script
  link_utilities
  reenable_sudo_timeout

Or:
  install_all

END
fi
