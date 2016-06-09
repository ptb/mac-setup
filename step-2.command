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

  cd "/usr/local/Library/Taps/caskroom/homebrew-cask" \
    && curl https://gist.githubusercontent.com/ptb/2685546c5fa068f0506e7040726aec41/raw/701f76b37c1039c7ab39653cd428c7b1ebd9305c/13966.patch | git apply -
}

function create_brewfile () {
  cat > /usr/local/Brewfile <<-EOF
tap "caskroom/cask"
tap "caskroom/fonts"
tap "caskroom/versions"
tap "homebrew/bundle"
tap "homebrew/dupes"
tap "homebrew/nginx"
tap "infinit/releases"
tap "ptb/custom"
tap "railwaycat/emacsmacport"
tap "vitorgalvao/tiny-scripts"

cask "java"

cask "ptb/custom/mas-xcode"

cask "adobe-illustrator-cc"
cask "adobe-indesign-cc"
cask "adobe-photoshop-cc"

cask "ptb/custom/enhanced-dictation"
cask "ptb/custom/text-to-speech-allison"

cask "ptb/custom/mas-keynote"
cask "ptb/custom/mas-numbers"
cask "ptb/custom/mas-pages"

cask "ptb/custom/mas-affinity-photo"

cask "sonarr"
cask "sonarr-menu"
cask "vmware-fusion"

cask "ptb/custom/bbedit-10"
cask "ptb/custom/blankscreen"
cask "ptb/custom/composer"
cask "ptb/custom/ipmenulet"
cask "ptb/custom/mas-1password"
cask "ptb/custom/mas-autoping"
cask "ptb/custom/mas-coffitivity"
cask "ptb/custom/mas-growl"
cask "ptb/custom/mas-hardwaregrowler"
cask "ptb/custom/mas-i-love-stars"
cask "ptb/custom/mas-icon-slate"
cask "ptb/custom/mas-justnotes"
cask "ptb/custom/mas-wifi-explorer"
cask "ptb/custom/pcalc-3"
cask "ptb/custom/sketchup-pro"
cask "ptb/custom/sublime-text3"
cask "ptb/custom/synergy"
cask "ptb/custom/tune4mac"

brew "aspell", args: ["lang=en"]
brew "vitorgalvao/tiny-scripts/cask-repair"
brew "chromedriver"
brew "duti"
brew "railwaycat/emacsmacport/emacs-mac", args: ["with-spacemacs-icon"]
brew "ffmpeg",
  args: [
  "with-dcadec",
  "with-faac",
  "with-fdk-aac",
  "with-ffplay",
  "with-fontconfig",
  "with-freetype",
  "with-frei0r",
  "with-lame",
  "with-libass",
  "with-libbluray",
  "with-libbs2b",
  "with-libcaca",
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
  "with-qtkit",
  "with-rtmpdump",
  "with-rubberband",
  "with-schroedinger",
  "with-sdl",
  "with-snappy",
  "with-speex",
  "with-texi2html",
  "with-theora",
  "with-tools",
  "with-webp",
  "with-x264",
  "with-x265",
  "with-xvid",
  "with-yasm",
  "with-zeromq",
  "with-zimg" ]
brew "git"
brew "git-annex"
brew "gnu-sed", args: ["with-default-names"]
brew "gnupg"
brew "gpac"
brew "hub"
brew "ievms"
brew "imagemagick"
brew "mercurial"
brew "mp4v2"
brew "mtr"
brew "nmap"
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
brew "node"
brew "openssl"
brew "homebrew/dupes/rsync"
brew "python"
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
cask "bettertouchtool"
cask "caffeine"
cask "carbon-copy-cloner"
cask "charles"
cask "couchpotato"
cask "dash"
# cask "datetree"
cask "deluge"
# cask "disk-inventory-x"
cask "dockertoolbox"
cask "dropbox"
cask "duet"
cask "exifrenamer"
cask "expandrive"
cask "firefox"
cask "flux"
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
cask "musicbrainz-picard"
cask "namechanger"
cask "nvalt"
cask "nzbget"
cask "nzbvortex"
cask "openemu"
cask "opera"
cask "caskroom/versions/osxfuse-beta"
cask "pacifist"
cask "platypus"
cask "plex-media-server"
cask "quitter"
cask "raindrop"
cask "rescuetime"
# cask "caskroom/versions/safari-technology-preview"
cask "https://raw.githubusercontent.com/ptb/homebrew-versions/patch-1/Casks/safari-technology-preview.rb"
cask "scrivener"
cask "sitesucker"
cask "sizeup"
cask "sketch"
cask "sketchup"
cask "skitch"
cask "skype"
cask "slack"
cask "sourcetree"
cask "steermouse"
cask "subler"
cask "time-sink"
# cask "timing"
cask "the-unarchiver"
# cask "tidy-up"
cask "torbrowser"
cask "tower"
cask "transmit"
cask "vimr"
cask "vlc"
# cask "webkit-nightly"
cask "xld"

cask "xquartz"
cask "inkscape"
brew "wine"
cask "wireshark"

cask "caskroom/fonts/font-inconsolata-lgc"

brew "infinit/releases/infinit"
EOF
}

function install_osx_software () {
  init_install_path

  INSTALL_PATH_HOMEBREW="${INSTALL_PATH}/github.com/Homebrew"

  if [ -d "${INSTALL_PATH_HOMEBREW}" ]; then
    cd "$(cd "${INSTALL_PATH_HOMEBREW}" && pwd)" \
      && cp -av * "${HOME}/Library/Caches/Homebrew/"
  fi

  cd /usr/local/ && brew bundle

  brew upgrade --all
  brew linkapps

  cd $(cd /usr/local/Caskroom/little-snitch/* && pwd) && open "Little Snitch Installer.app"
}

function install_node_software () {
  npm i -g babel-cli bower browser-sync browserify chimp coffee-script eslint gulp-cli jasmine polyserve riot selenium-webdriver superstatic svgo uglify-js watchify webpack
}

function install_python_software () {
  curl -Ls https://bootstrap.pypa.io/get-pip.py | sudo -H python
  pip install --upgrade pip setuptools
  pip install --upgrade babelfish bottle 'guessit<2' influxdb netifaces pika psutil py2app pyobjc-core pysnmp pystache qtfaststart requests scour selenium statsd subliminal watchdog yapf zeroconf
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
  gem install bootstrap-sass git-cipher org-ruby selenium-webdriver thin
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
