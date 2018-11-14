* Mac Setup
:properties:
:header-args: :cache yes :comments org :padline yes :results silent
:header-args:sh: :noweb tangle :shebang "#!/bin/sh" :tangle mac-setup.command
:end:
#+startup: showall nohideblocks hidestars indent

#+begin_quote
From zero to fully installed and configured, in an hour.
#+end_quote

** Overview

*** Quick Start
#+begin_src sh
case "${SHELL}" in
  (*zsh) ;;
  (*) chsh -s "$(which zsh)"; exit 1 ;;
esac
#+end_src

#+begin_example sh
curl --location --silent \
  "https://github.com/ptb/mac-setup/raw/develop/mac-setup.command" | \
  source /dev/stdin 0
#+end_example

#+begin_example sh
init && install && config
#+end_example

#+begin_example sh
custom && personalize_all
#+end_example

**** =init=

- Enter administrator account password only once
- Select the cache folder for repeat installations
- Turn off sleep and set computer name/hostname
- Set write permission on destination folders
- Cache software updates and App Store software
- Install developer tools and macOS updates

**** =install=

- [[https://brew.sh/][Homebrew]]: The missing package mananger for macOS
- [[https://caskroom.github.io/][Homebrew-Cask]]: “To install, drag this icon…” no more!
- [[https://github.com/mas-cli/mas][mas-cli/mas]]: Mac App Store command line interface
- [[https://github.com/Homebrew/homebrew-bundle][homebrew-bundle]]: List all Homebrew packages in =Brewfile=
- [[https://nodejs.org/][Node.js]]: Cross-platform JavaScript run-time environment
- [[https://www.perl.org/][Perl 5]]: Highly capable, feature-rich programming language
- [[https://www.python.org/][Python]]: Programming language that lets you work quickly
- [[https://www.ruby-lang.org/][Ruby]]: Language with a focus on simplicity and productivity

**** =config=

- Configure software requiring an administrator account
- Optionally configure local Dovecot secure IMAP server
- Create your primary /non-administrator/ account
- Remove password-less administrator account permission
- Recommended that you log out of administrator account

**** =custom=

- Log in with your new non-administrator account
- Create or clone a git repository into your home folder
- Install [[https://atom.io/][Atom]] [[https://atom.io/packages][packages]] and customize preferences
- Set the desktop picture to a solid black color
- Customize the dock with new default applications
- Customize Emacs with [[http://spacemacs.org/][Spacemacs]]: Emacs /plus/ Vim!
- Set all preferences automatically and consistently

*** Features

- *macOS High Sierra:* Tested with macOS High Sierra 10.13 (17A365).
- *Completely Automated:* Homebrew, Cask, and =mas-cli= install everything.
- *Latest Versions:* Includes Node, Perl, Python, and Ruby separate from macOS.
- *Customized Terminal:* Colors and fonts decyphered into editable preferences.
- *Idempotent:* This script is intended to be safe to run more than once.

*** Walkthrough

**** Clone Internal Hard Disk to External Disk

**** Select the External Disk as Startup Disk

**** Download macOS Install from the App Store

=macappstores://itunes.apple.com/app/id1209167288=

**** Open /Applications/Utilities/Terminal.app
#+begin_example sh
diskx="$(diskutil list internal physical | sed '/^\//!d;s/^\(.*\)\ (.*):/\1/')"
#+end_example

#+begin_example sh
diskutil zeroDisk $diskx
diskutil partitionDisk $diskx 2 GPT \
  jhfs+ "Install" 6G \
  apfs $(ruby -e "print '$(hostname -s)'.capitalize") R
#+end_example

#+begin_example sh
sudo "/Applications/Install macOS High Sierra.app/Contents/Resources/createinstallmedia" \
  --applicationpath "/Applications/Install macOS High Sierra.app" --nointeraction \
  --volume "/Volumes/Install"
#+end_example

**** Select the Install Disk as Startup Disk

*** License

#+begin_quote
Copyright 2017 [[https://github.com/ptb][Peter T Bosse II]]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#+end_quote

** Initialize

*** Initialize New Terminal
#+begin_src sh
if test -z "${1}"; then
  osascript - "${0}" << EOF > /dev/null 2>&1
<<new_term.applescript>>
EOF
fi
#+end_src

**** =new_term.applescript=
#+begin_src applescript :noweb-ref new_term.applescript
    on run { _this }
      tell app "Terminal" to do script "source " & quoted form of _this & " 0"
    end run
#+end_src

*** Define Function =ask=
#+begin_src sh
ask () {
  osascript - "${1}" "${2}" "${3}" << EOF 2> /dev/null
<<ask.applescript>>
EOF
}
#+end_src

**** =ask.applescript=
#+begin_src applescript :noweb-ref ask.applescript
    on run { _title, _action, _default }
      tell app "System Events" to return text returned of (display dialog _title with title _title buttons { "Cancel", _action } default answer _default)
    end run
#+end_src

*** Define Function =ask2=
#+begin_src sh
ask2 () {
  osascript - "$1" "$2" "$3" "$4" "$5" "$6" << EOF 2> /dev/null
<<ask2.applescript>>
EOF
}
#+end_src

**** =ask2.applescript=
#+begin_src applescript :noweb-ref ask2.applescript
on run { _text, _title, _cancel, _action, _default, _hidden }
  tell app "Terminal" to return text returned of (display dialog _text with title _title buttons { _cancel, _action } cancel button _cancel default button _action default answer _default hidden answer _hidden)
end run
#+end_src

*** Define Function =p=
#+begin_src sh
p () {
  printf "\n\033[1m\033[34m%s\033[0m\n\n" "${1}"
}
#+end_src

*** Define Function =run=
#+begin_src sh
run () {
  osascript - "${1}" "${2}" "${3}" << EOF 2> /dev/null
<<run.applescript>>
EOF
}
#+end_src

**** =run.applescript=
#+begin_src applescript :noweb-ref run.applescript
    on run { _title, _cancel, _action }
      tell app "Terminal" to return button returned of (display dialog _title with title _title buttons { _cancel, _action } cancel button 1 default button 2 giving up after 5)
    end run
#+end_src

*** Define Function =init=
#+begin_src sh
init () {
  init_sudo
  init_cache
  init_no_sleep
  init_hostname
  init_perms
  init_maskeep
  init_updates

  config_new_account
  config_rm_sudoers
}

if test "${1}" = 0; then
  printf "\n$(which init)\n"
fi
#+end_src

*** Define Function =init_paths=
#+begin_src sh
init_paths () {
  test -x "/usr/libexec/path_helper" && \
    eval $(/usr/libexec/path_helper -s)
}
#+end_src

*** Eliminate Prompts for Password
#+begin_src sh
init_sudo () {
  printf "%s\n" "%wheel ALL=(ALL) NOPASSWD: ALL" | \
  sudo tee "/etc/sudoers.d/wheel" > /dev/null && \
  sudo dscl /Local/Default append /Groups/wheel GroupMembership "$(whoami)"
}
#+end_src

*** Select Installation Cache Location
#+begin_src sh
init_cache () {
  grep -q "CACHES" "/etc/zshenv" 2> /dev/null || \
  a=$(osascript << EOF 2> /dev/null
<<init_cache.applescript>>
EOF
) && \
  test -d "${a}" || \
    a="${HOME}/Library/Caches/"

  grep -q "CACHES" "/etc/zshenv" 2> /dev/null || \
  printf "%s\n" \
    "export CACHES=\"${a}\"" \
    "export HOMEBREW_CACHE=\"${a}/brew\"" \
    "export BREWFILE=\"${a}/brew/Brewfile\"" | \
  sudo tee -a "/etc/zshenv" > /dev/null
  . "/etc/zshenv"

  if test -d "${CACHES}/upd"; then
    sudo chown -R "$(whoami)" "/Library/Updates"
    rsync -a --delay-updates \
      "${CACHES}/upd/" "/Library/Updates/"
  fi
}
#+end_src

**** =init_cache.applescript=
#+begin_src applescript :noweb-ref init_cache.applescript
    on run
      return text 1 through -2 of POSIX path of (choose folder with prompt "Select Installation Cache Location")
    end run
#+end_src

*** Set Defaults for Sleep
#+begin_src sh
init_no_sleep () {
  sudo pmset -a sleep 0
  sudo pmset -a disksleep 0
}
#+end_src

*** Set Hostname from DNS
#+begin_src sh
init_hostname () {
  a=$(ask2 "Set Computer Name and Hostname" "Set Hostname" "Cancel" "Set Hostname" $(ruby -e "print '$(hostname -s)'.capitalize") "false")
  if test -n $a; then
    sudo scutil --set ComputerName $(ruby -e "print '$a'.capitalize")
    sudo scutil --set HostName $(ruby -e "print '$a'.downcase")
  fi
}
#+end_src

*** Set Permissions on Install Destinations
#+begin_src sh :var _dest=_dest[3:11,1]

init_perms () {
  printf "%s\n" "${_dest}" | \
  while IFS="$(printf '\t')" read d; do
    test -d "${d}" || sudo mkdir -p "${d}"
    sudo chgrp -R admin "${d}"
    sudo chmod -R g+w "${d}"
  done
}
#+end_src

**** _dest
#+name: _dest
|-----------------+---------------------------|
| Location        | Install Path              |
|-----------------+---------------------------|
|                 | /usr/local/bin            |
|                 | /Library/Desktop Pictures |
| colorpickerdir  | /Library/ColorPickers     |
| fontdir         | /Library/Fonts            |
| input_methoddir | /Library/Input Methods    |
| prefpanedir     | /Library/PreferencePanes  |
| qlplugindir     | /Library/QuickLook        |
| screen_saverdir | /Library/Screen Savers    |
|                 | /Library/User Pictures    |
|-----------------+---------------------------|

*** Install Developer Tools
#+begin_src sh
init_devtools () {
  p="${HOMEBREW_CACHE}/Cask/Command Line Tools (macOS High Sierra version 10.13).pkg"
  i="com.apple.pkg.CLTools_SDK_macOS1013"

  if test -f "${p}"; then
    if ! pkgutil --pkg-info "${i}" > /dev/null 2>&1; then
      sudo installer -pkg "${p}" -target /
    fi
  else
    xcode-select --install
  fi
}
#+end_src

*** Install Xcode
#+begin_src sh
init_xcode () {
  if test -f ${HOMEBREW_CACHE}/Cask/xcode*.xip; then
    p "Installing Xcode"
    dest="${HOMEBREW_CACHE}/Cask/xcode"
    if ! test -d "$dest"; then
      pkgutil --expand ${HOMEBREW_CACHE}/Cask/xcode*.xip "$dest"
      curl --location --silent \
        "https://gist.githubusercontent.com/pudquick/ff412bcb29c9c1fa4b8d/raw/24b25538ea8df8d0634a2a6189aa581ccc6a5b4b/parse_pbzx2.py" | \
        python - "${dest}/Content"
      find "${dest}" -empty -name "*.xz" -type f -print0 | \
        xargs -0 -l 1 rm
      find "${dest}" -name "*.xz" -print0 | \
        xargs -0 -L 1 gunzip
      cat ${dest}/Content.part* > \
        ${dest}/Content.cpio
    fi
    cd /Applications && \
      sudo cpio -dimu --file=${dest}/Content.cpio
    for pkg in /Applications/Xcode*.app/Contents/Resources/Packages/*.pkg; do
      sudo installer -pkg "$pkg" -target /
    done
    x="$(find '/Applications' -maxdepth 1 -regex '.*/Xcode[^ ]*.app' -print -quit)"
    if test -n "${x}"; then
      sudo xcode-select -s "${x}"
      sudo xcodebuild -license accept
    fi
  fi
}
#+end_src

*** Install macOS Updates
#+begin_src sh
init_updates () {
  sudo softwareupdate --install --all
}
#+end_src

*** Save Mac App Store Packages
#+begin_example sh
sudo lsof -c softwareupdated -F -r 2 | sed '/^n\//!d;/com.apple.SoftwareUpdate/!d;s/^n//'
sudo lsof -c storedownloadd -F -r 2 | sed '/^n\//!d;/com.apple.appstore/!d;s/^n//'
#+end_example
#+begin_src sh :var _maskeep_launchd=_maskeep_launchd[3:-2,0:3]

init_maskeep () {
  sudo softwareupdate --reset-ignored > /dev/null

  cat << EOF > "/usr/local/bin/maskeep"
<<maskeep.sh>>
EOF

  chmod a+x "/usr/local/bin/maskeep"
  rehash

  config_launchd "/Library/LaunchDaemons/com.github.ptb.maskeep.plist" "$_maskeep_launchd" "sudo" ""
}
#+end_src

**** _maskeep_launchd
#+name: _maskeep_launchd
|---------+--------------------+--------+-----------------------------------------------------------------------------------------------------------------|
| Command | Entry              | Type   | Value                                                                                                           |
|---------+--------------------+--------+-----------------------------------------------------------------------------------------------------------------|
| add     | :KeepAlive         | bool   | false                                                                                                           |
| add     | :Label             | string | com.github.ptb.maskeep                                                                                         |
| add     | :ProcessType       | string | Background                                                                                                      |
| add     | :Program           | string | /usr/local/bin/maskeep                                                                                          |
| add     | :RunAtLoad         | bool   | true                                                                                                            |
| add     | :StandardErrorPath | string | /dev/stderr                                                                                                     |
| add     | :StandardOutPath   | string | /dev/stdout                                                                                                     |
| add     | :UserName          | string | root                                                                                                            |
| add     | :WatchPaths        | array  |                                                                                                                 |
| add     | :WatchPaths:0      | string | $(sudo find '/private/var/folders' -name 'com.apple.SoftwareUpdate' -type d -user _softwareupdate -print -quit 2> /dev/null) |
| add     | :WatchPaths:1      | string | $(sudo -u \\#501 -- sh -c 'getconf DARWIN_USER_CACHE_DIR' 2> /dev/null)com.apple.appstore                       |
| add     | :WatchPaths:2      | string | $(sudo -u \\#502 -- sh -c 'getconf DARWIN_USER_CACHE_DIR' 2> /dev/null)com.apple.appstore                      |
| add     | :WatchPaths:3      | string | $(sudo -u \\#503 -- sh -c 'getconf DARWIN_USER_CACHE_DIR' 2> /dev/null)com.apple.appstore                       |
| add     | :WatchPaths:4      | string | /Library/Updates                                                                                                |
|---------+--------------------+--------+-----------------------------------------------------------------------------------------------------------------|

**** =/usr/local/bin/maskeep=
#+begin_src sh :noweb-ref maskeep.sh :tangle no
#!/bin/sh

asdir="/Library/Caches/storedownloadd"
as1="\$(sudo -u \\#501 -- sh -c 'getconf DARWIN_USER_CACHE_DIR' 2> /dev/null)com.apple.appstore"
as2="\$(sudo -u \\#502 -- sh -c 'getconf DARWIN_USER_CACHE_DIR' 2> /dev/null)com.apple.appstore"
as3="\$(sudo -u \\#503 -- sh -c 'getconf DARWIN_USER_CACHE_DIR' 2> /dev/null)com.apple.appstore"
upd="/Library/Updates"
sudir="/Library/Caches/softwareupdated"
su="\$(sudo find '/private/var/folders' -name 'com.apple.SoftwareUpdate' -type d -user _softwareupdate 2> /dev/null)"

for i in 1 2 3 4 5; do
  mkdir -m a=rwxt -p "\$asdir"
  for as in "\$as1" "\$as2" "\$as3" "\$upd"; do
    test -d "\$as" && \
    find "\${as}" -type d -print | \\
    while read a; do
      b="\${asdir}/\$(basename \$a)"
      mkdir -p "\${b}"
      find "\${a}" -type f -print | \\
      while read c; do
        d="\$(basename \$c)"
        test -e "\${b}/\${d}" || \\
          ln "\${c}" "\${b}/\${d}" && \\
          chmod 666 "\${b}/\${d}"
      done
    done
  done

  mkdir -m a=rwxt -p "\${sudir}"
  find "\${su}" -name "*.tmp" -type f -print | \\
  while read a; do
    d="\$(basename \$a)"
    test -e "\${sudir}/\${d}.xar" ||
      ln "\${a}" "\${sudir}/\${d}.xar" && \\
      chmod 666 "\${sudir}/\${d}.xar"
  done

  sleep 1
done

exit 0
#+end_src

** Install

*** Define Function =install=
#+begin_src sh
install () {
  install_macos_sw
  install_node_sw
  install_perl_sw
  install_python_sw
  install_ruby_sw

  which config
}
#+end_src

*** Install macOS Software with =brew=
#+begin_src sh
install_macos_sw () {
  p "Installing macOS Software"
  install_paths
  install_brew
  install_brewfile_taps
  install_brewfile_brew_pkgs
  install_brewfile_cask_args
  install_brewfile_cask_pkgs
  install_brewfile_mas_apps

  x=$(find '/Applications' -maxdepth 1 -regex '.*/Xcode[^ ]*.app' -print -quit)
  if test -n "$x"; then
    sudo xcode-select -s "$x"
    sudo xcodebuild -license accept
  fi

  brew bundle --file="${BREWFILE}"

  x=$(find '/Applications' -maxdepth 1 -regex '.*/Xcode[^ ]*.app' -print -quit)
  if test -n "$x"; then
    sudo xcode-select -s "$x"
    sudo xcodebuild -license accept
  fi

  install_links
  sudo xattr -rd "com.apple.quarantine" "/Applications" > /dev/null 2>&1
  sudo chmod -R go=u-w "/Applications" > /dev/null 2>&1
}
#+end_src

*** Add =/usr/local/bin/sbin= to Default Path
#+begin_src sh
install_paths () {
  if ! grep -Fq "/usr/local/sbin" /etc/paths; then
    sudo sed -i "" -e "/\/usr\/sbin/{x;s/$/\/usr\/local\/sbin/;G;}" /etc/paths
  fi
}
#+end_src

*** Install Homebrew Package Manager
#+begin_src sh
install_brew () {
  if ! which brew > /dev/null; then
    ruby -e \
      "$(curl -Ls 'https://github.com/Homebrew/install/raw/master/install')" \
      < /dev/null > /dev/null 2>&1
  fi
  printf "" > "${BREWFILE}"
  brew analytics off
  brew update
  brew doctor
  brew tap "homebrew/bundle"
}
#+end_src

*** Add Homebrew Taps to Brewfile
#+begin_src sh :var _taps=_taps[3:-2,0]

install_brewfile_taps () {
  printf "%s\n" "${_taps}" | \
  while IFS="$(printf '\t')" read tap; do
    printf 'tap "%s"\n' "${tap}" >> "${BREWFILE}"
  done
  printf "\n" >> "${BREWFILE}"
}
#+end_src

**** _taps
#+name: _taps
|----------------------------+--------------------------------------------------------|
| Homebrew Tap Name          | Reference URL                                          |
|----------------------------+--------------------------------------------------------|
| caskroom/cask              | https://github.com/caskroom/homebrew-cask              |
| caskroom/fonts             | https://github.com/caskroom/homebrew-fonts             |
| caskroom/versions          | https://github.com/caskroom/homebrew-versions          |
| homebrew/bundle            | https://github.com/Homebrew/homebrew-bundle            |
| homebrew/command-not-found | https://github.com/Homebrew/homebrew-command-not-found |
| homebrew/nginx             | https://github.com/Homebrew/homebrew-nginx             |
| homebrew/php               | https://github.com/Homebrew/homebrew-php               |
| homebrew/services          | https://github.com/Homebrew/homebrew-services          |
| ptb/custom                 | https://github.com/ptb/homebrew-custom                 |
| railwaycat/emacsmacport    | https://github.com/railwaycat/homebrew-emacsmacport    |
|----------------------------+--------------------------------------------------------|

*** Add Homebrew Packages to Brewfile
#+begin_src sh :var _pkgs=_pkgs[3:-2,0]

install_brewfile_brew_pkgs () {
  printf "%s\n" "${_pkgs}" | \
  while IFS="$(printf '\t')" read pkg; do
    # printf 'brew "%s", args: [ "force-bottle" ]\n' "${pkg}" >> "${BREWFILE}"
    printf 'brew "%s"\n' "${pkg}" >> "${BREWFILE}"
  done
  printf "\n" >> "${BREWFILE}"
}
#+end_src

**** _pkgs
#+name: _pkgs
|------------------------------+-----------------------------------------------------------|
| Homebrew Package Name        | Reference URL                                             |
|------------------------------+-----------------------------------------------------------|
| aspell                       | http://aspell.net/                                        |
| bash                         | https://www.gnu.org/software/bash/                        |
| certbot                      | https://certbot.eff.org/                                  |
| chromedriver                 | https://sites.google.com/a/chromium.org/chromedriver/     |
| coreutils                    | https://www.gnu.org/software/coreutils/                   |
| dash                         | http://gondor.apana.org.au/~herbert/dash/                 |
| duti                         | https://github.com/moretension/duti                       |
| e2fsprogs                    | https://e2fsprogs.sourceforge.io/                         |
| fasd                         | https://github.com/clvv/fasd                              |
| fdupes                       | https://github.com/adrianlopezroche/fdupes                |
| gawk                         | https://www.gnu.org/software/gawk/                        |
| getmail                      | http://pyropus.ca/software/getmail/                       |
| git                          | https://git-scm.com/                                      |
| git-flow                     | http://nvie.com/posts/a-successful-git-branching-model/   |
| git-lfs                      | https://git-lfs.github.com/                               |
| gnu-sed                      | https://www.gnu.org/software/sed/                         |
| gnupg                        | https://www.gnupg.org/                                    |
| gpac                         | https://gpac.wp.imt.fr/                                   |
| httpie                       | https://httpie.org/                                       |
| hub                          | https://hub.github.com/                                   |
| ievms                        | https://xdissent.github.io/ievms/                         |
| imagemagick                  | https://www.imagemagick.org/                              |
| mas                          | https://github.com/argon/mas                              |
| mercurial                    | https://www.mercurial-scm.org/                            |
| mp4v2                        | https://code.google.com/archive/p/mp4v2/                  |
| mtr                          | https://www.bitwizard.nl/mtr/                             |
| nmap                         | https://nmap.org/                                         |
| node                         | https://nodejs.org/                                       |
| nodenv                       | https://github.com/nodenv/nodenv                          |
| openssl                      | https://www.openssl.org/                                  |
| p7zip                        | http://p7zip.sourceforge.net/                             |
| perl-build                   | https://github.com/tokuhirom/Perl-Build                   |
| pinentry-mac                 | https://github.com/GPGTools/pinentry-mac                  |
| plenv                        | https://github.com/tokuhirom/plenv                        |
| pyenv                        | https://github.com/pyenv/pyenv                            |
| rbenv                        | https://github.com/rbenv/rbenv                            |
| rsync                        | https://rsync.samba.org/                                  |
| selenium-server-standalone   | http://www.seleniumhq.org/                                |
| shellcheck                   | https://github.com/koalaman/shellcheck                    |
| sleepwatcher                 | http://www.bernhard-baehr.de/                             |
| sqlite                       | https://sqlite.org                                        |
| stow                         | https://www.gnu.org/software/stow/                        |
| syncthing                    | https://syncthing.net/                                    |
| syncthing-inotify            | https://github.com/syncthing/syncthing-inotify            |
| tag                          | https://github.com/jdberry/tag                            |
| terminal-notifier            | https://github.com/julienXX/terminal-notifier             |
| the_silver_searcher          | https://geoff.greer.fm/ag/                                |
| trash                        | http://hasseg.org/trash/                                  |
| unrar                        | http://www.rarlab.com/                                    |
| vcsh                         | https://github.com/RichiH/vcsh                            |
| vim                          | https://vim.sourceforge.io/                               |
| yarn                         | https://yarnpkg.com/                                      |
| youtube-dl                   | https://rg3.github.io/youtube-dl/                         |
| zsh                          | https://www.zsh.org/                                      |
| zsh-syntax-highlighting      | https://github.com/zsh-users/zsh-syntax-highlighting      |
| zsh-history-substring-search | https://github.com/zsh-users/zsh-history-substring-search |
| homebrew/php/php71           | https://github.com/Homebrew/homebrew-php                  |
| ptb/custom/dovecot           |                                                           |
| ptb/custom/ffmpeg            |                                                           |
| sdl2                         |                                                           |
| zimg                         |                                                           |
| x265                         |                                                           |
| webp                         |                                                           |
| wavpack                      |                                                           |
| libvorbis                    |                                                           |
| libvidstab                   |                                                           |
| two-lame                     |                                                           |
| theora                       |                                                           |
| tesseract                    |                                                           |
| speex                        |                                                           |
| libssh                       |                                                           |
| libsoxr                      |                                                           |
| snappy                       |                                                           |
| schroedinger                 |                                                           |
| rubberband                   |                                                           |
| rtmpdump                     |                                                           |
| opus                         |                                                           |
| openh264                     |                                                           |
| opencore-amr                 |                                                           |
| libmodplug                   |                                                           |
| libgsm                       |                                                           |
| game-music-emu               |                                                           |
| fontconfig                   |                                                           |
| fdk-aac                      |                                                           |
| libcaca                      |                                                           |
| libbs2b                      |                                                           |
| libbluray                    |                                                           |
| libass                       |                                                           |
| chromaprint                  |                                                           |
| ptb/custom/nginx-full        |                                                           |
|------------------------------+-----------------------------------------------------------|

*** Add Caskroom Options to Brewfile
#+begin_src sh :var _args=_dest[5:10,0:1]

install_brewfile_cask_args () {
  printf 'cask_args \' >> "${BREWFILE}"
  printf "%s\n" "${_args}" | \
  while IFS="$(printf '\t')" read arg dir; do
    printf '\n  %s: "%s",' "${arg}" "${dir}" >> "${BREWFILE}"
  done
  sed -i "" -e '$ s/,/\
/' "${BREWFILE}"
}
#+end_src

*** Add Homebrew Casks to Brewfile
#+begin_src sh :var _casks=_casks[3:-2,0]

install_brewfile_cask_pkgs () {
  printf "%s\n" "${_casks}" | \
  while IFS="$(printf '\t')" read cask; do
    printf 'cask "%s"\n' "${cask}" >> "${BREWFILE}"
  done
  printf "\n" >> "${BREWFILE}"
}
#+end_src

**** _casks
#+name: _casks
|--------------------------------------------------+---------------------------------------------------------------|
| Caskroom Package Name                            | Reference URL                                                 |
|--------------------------------------------------+---------------------------------------------------------------|
| java                                             | https://www.oracle.com/technetwork/java/javase/               |
| xquartz                                          | https://www.xquartz.org/                                      |
| adium                                            | https://www.adium.im/                                         |
| alfred                                           | https://www.alfredapp.com/                                    |
| arduino                                          | https://www.arduino.cc/                                       |
| atom                                             | https://atom.io/                                              |
| bbedit                                           | https://www.barebones.com/products/bbedit/                    |
| betterzip                                        | https://macitbetter.com/                                      |
| bitbar                                           | https://getbitbar.com/                                        |
| caffeine                                         | http://lightheadsw.com/caffeine/                              |
| carbon-copy-cloner                               | https://bombich.com/                                          |
| charles                                          | https://www.charlesproxy.com/                                 |
| dash                                             | https://kapeli.com/dash                                       |
| dropbox                                          | https://www.dropbox.com/                                      |
| exifrenamer                                      | http://www.qdev.de/?location=mac/exifrenamer                  |
| find-empty-folders                               | http://www.tempel.org/FindEmptyFolders                        |
| firefox                                          | https://www.mozilla.org/firefox/                              |
| github-desktop                                   | https://desktop.github.com/                                   |
| gitup                                            | http://gitup.co/                                              |
| google-chrome                                    | https://www.google.com/chrome/                                |
| hammerspoon                                      | http://www.hammerspoon.org/                                   |
| handbrake                                        | https://handbrake.fr/                                         |
| hermes                                           | http://hermesapp.org/                                         |
| imageoptim                                       | https://imageoptim.com/mac                                    |
| inkscape                                         | https://inkscape.org/                                         |
| integrity                                        | http://peacockmedia.software/mac/integrity/                   |
| istat-menus                                      | https://bjango.com/mac/istatmenus/                            |
| iterm2                                           | https://www.iterm2.com/                                       |
| jubler                                           | http://www.jubler.org/                                        |
| little-snitch                                    | https://www.obdev.at/products/littlesnitch/                   |
| machg                                            | http://jasonfharris.com/machg/                                |
| menubar-countdown                                | http://capablehands.net/menubarcountdown                      |
| meteorologist                                    | http://heat-meteo.sourceforge.net/                            |
| moom                                             | https://manytricks.com/moom/                                  |
| mp4tools                                         | http://www.emmgunn.com/mp4tools-home/                         |
| musicbrainz-picard                               | https://picard.musicbrainz.org/                               |
| namechanger                                      | https://mrrsoftware.com/namechanger/                          |
| nvalt                                            | http://brettterpstra.com/projects/nvalt/                      |
| nzbget                                           | https://nzbget.net/                                           |
| nzbvortex                                        | https://www.nzbvortex.com/                                    |
| openemu                                          | http://openemu.org/                                           |
| opera                                            | https://www.opera.com/                                        |
| pacifist                                         | https://www.charlessoft.com/                                  |
| platypus                                         | https://sveinbjorn.org/platypus                               |
| plex-media-server                                | https://www.plex.tv/                                          |
| qlstephen                                        | https://whomwah.github.io/qlstephen/                          |
| quitter                                          | https://marco.org/apps#quitter                                |
| radarr                                           | https://radarr.video/                                         |
| rescuetime                                       | https://www.rescuetime.com/                                   |
| resilio-sync                                     | https://www.resilio.com/individuals/                          |
| scrivener                                        | https://literatureandlatte.com/scrivener.php                  |
| sizeup                                           | https://www.irradiatedsoftware.com/sizeup/                    |
| sketch                                           | https://www.sketchapp.com/                                    |
| sketchup                                         | https://www.sketchup.com/                                     |
| skitch                                           | https://evernote.com/products/skitch                          |
| skype                                            | https://www.skype.com/                                        |
| slack                                            | https://slack.com/                                            |
| sonarr                                           | https://sonarr.tv/                                            |
| sonarr-menu                                      | https://github.com/jefbarn/Sonarr-Menu                        |
| sourcetree                                       | https://www.sourcetreeapp.com/                                |
| steermouse                                       | http://plentycom.jp/en/steermouse/                            |
| subler                                           | https://subler.org/                                           |
| sublime-text                                     | https://www.sublimetext.com/3                                 |
| the-unarchiver                                   | https://theunarchiver.com/                                    |
| time-sink                                        | https://manytricks.com/timesink/                              |
| torbrowser                                       | https://www.torproject.org/projects/torbrowser.html           |
| tower                                            | https://www.git-tower.com/                                    |
| unrarx                                           | http://www.unrarx.com/                                        |
| vimr                                             | http://vimr.org/                                              |
| vlc                                              | https://www.videolan.org/vlc/                                 |
| vmware-fusion                                    | https://www.vmware.com/products/fusion.html                   |
| wireshark                                        | https://www.wireshark.org/                                    |
| xld                                              | http://tmkk.undo.jp/xld/index_e.html                          |
| caskroom/fonts/font-inconsolata-lgc              | https://github.com/DeLaGuardo/Inconsolata-LGC                 |
| caskroom/versions/transmit4                      | https://panic.com/transmit/                                   |
| ptb/custom/adobe-creative-cloud-2014             | https://www.adobe.com/creativecloud.html                      |
| ptb/custom/blankscreen                           | http://www.wurst-wasser.net/wiki/index.php/Blank_Screen_Saver |
| ptb/custom/composer                              | https://www.jamf.com/products/jamf-composer/                  |
| ptb/custom/enhanced-dictation                    |                                                               |
| ptb/custom/ipmenulet                             | https://github.com/mcandre/IPMenulet                          |
| ptb/custom/pcalc-3                               | http://www.pcalc.com/english/about.html                       |
| ptb/custom/sketchup-pro                          | https://www.sketchup.com/products/sketchup-pro                |
| ptb/custom/text-to-speech-alex                   |                                                               |
| ptb/custom/text-to-speech-allison                |                                                               |
| ptb/custom/text-to-speech-samantha               |                                                               |
| ptb/custom/text-to-speech-tom                    |                                                               |
| railwaycat/emacsmacport/emacs-mac-spacemacs-icon | https://github.com/railwaycat/homebrew-emacsmacport           |
|--------------------------------------------------+---------------------------------------------------------------|

*** Add App Store Packages to Brewfile
#+begin_src sh :var _mas=_mas[3:-3,0:1]

install_brewfile_mas_apps () {
  open "/Applications/App Store.app"
  run "Sign in to the App Store with your Apple ID" "Cancel" "OK"

  MASDIR="$(getconf DARWIN_USER_CACHE_DIR)com.apple.appstore"
  sudo chown -R "$(whoami)" "${MASDIR}"
  rsync -a --delay-updates \
    "${CACHES}/mas/" "${MASDIR}/"

  printf "%s\n" "${_mas}" | \
  while IFS="$(printf '\t')" read app id; do
    printf 'mas "%s", id: %s\n' "${app}" "${id}" >> "${BREWFILE}"
  done
}
#+end_src

**** _mas
#+name: _mas
|----------------------------+------------+-------------------------------------------|
| App Name                   |     App ID | App Store URL                             |
|----------------------------+------------+-------------------------------------------|
| 1Password                  |  443987910 | https://itunes.apple.com/app/id443987910  |
| Affinity Photo             |  824183456 | https://itunes.apple.com/app/id824183456  |
| Coffitivity                |  659901392 | https://itunes.apple.com/app/id659901392  |
| Duplicate Photos Fixer Pro |  963642514 | https://itunes.apple.com/app/id963642514  |
| Growl                      |  467939042 | https://itunes.apple.com/app/id467939042  |
| HardwareGrowler            |  475260933 | https://itunes.apple.com/app/id475260933  |
| I Love Stars               |  402642760 | https://itunes.apple.com/app/id402642760  |
| Icon Slate                 |  439697913 | https://itunes.apple.com/app/id439697913  |
| Justnotes                  |  511230166 | https://itunes.apple.com/app/id511230166  |
| Keynote                    |  409183694 | https://itunes.apple.com/app/id409183694  |
| Metanota Pro               |  515250764 | https://itunes.apple.com/app/id515250764  |
| Numbers                    |  409203825 | https://itunes.apple.com/app/id409203825  |
| Pages                      |  409201541 | https://itunes.apple.com/app/id409201541  |
| WiFi Explorer              |  494803304 | https://itunes.apple.com/app/id494803304  |
| Xcode                      |  497799835 | https://itunes.apple.com/app/id497799835  |
| macOS High Sierra          | 1209167288 | https://itunes.apple.com/app/id1209167288 |
|----------------------------+------------+-------------------------------------------|

*** Link System Utilities to Applications
#+begin_src sh :var _links=_links[3:-2,0]

install_links () {
  printf "%s\n" "${_links}" | \
  while IFS="$(printf '\t')" read link; do
    find "${link}" -maxdepth 1 -name "*.app" -type d -print0 2> /dev/null | \
    xargs -0 -I {} -L 1 ln -s "{}" "/Applications" 2> /dev/null
  done
}
#+end_src

**** _links
#+name: _links
|--------------------------------------------------------------|
| Application Locations                                        |
|--------------------------------------------------------------|
| /System/Library/CoreServices/Applications                    |
| /Applications/Xcode.app/Contents/Applications                |
| /Applications/Xcode.app/Contents/Developer/Applications      |
| /Applications/Xcode-beta.app/Contents/Applications           |
| /Applications/Xcode-beta.app/Contents/Developer/Applications |
|--------------------------------------------------------------|

*** Install Node.js with =nodenv=
#+begin_src sh :var _npm=_npm[3:-2,0]

install_node_sw () {
  if which nodenv > /dev/null; then
    NODENV_ROOT="/usr/local/node" && export NODENV_ROOT

    sudo mkdir -p "$NODENV_ROOT"
    sudo chown -R "$(whoami):admin" "$NODENV_ROOT"

    p "Installing Node.js with nodenv"
    git clone https://github.com/nodenv/node-build-update-defs.git \
      "$(nodenv root)"/plugins/node-build-update-defs
    nodenv update-version-defs > /dev/null

    nodenv install --skip-existing 8.7.0
    nodenv global 8.7.0

    grep -q "${NODENV_ROOT}" "/etc/paths" || \
    sudo sed -i "" -e "1i\\
${NODENV_ROOT}/shims
" "/etc/paths"

    init_paths
    rehash
  fi

  T=$(printf '\t')

  printf "%s\n" "$_npm" | \
  while IFS="$T" read pkg; do
    npm install --global "$pkg"
  done

  rehash
}
#+end_src

#+name: _npm
|------------------------+----------------------------------------------------|
| NPM Package Name       | Reference URL                                      |
|------------------------+----------------------------------------------------|
| eslint                 | https://eslint.org/                                |
| eslint-config-cleanjs  | https://github.com/bodil/eslint-config-cleanjs     |
| eslint-plugin-better   | https://github.com/idmitriev/eslint-plugin-better  |
| eslint-plugin-fp       | https://github.com/jfmengels/eslint-plugin-fp      |
| eslint-plugin-import   | https://github.com/benmosher/eslint-plugin-import  |
| eslint-plugin-json     | https://github.com/azeemba/eslint-plugin-json      |
| eslint-plugin-promise  | https://github.com/xjamundx/eslint-plugin-promise  |
| eslint-plugin-standard | https://github.com/xjamundx/eslint-plugin-standard |
| gatsby                 |                                                    |
| json                   | http://trentm.com/json/                            |
| sort-json              | https://github.com/kesla/sort-json                 |
|------------------------+----------------------------------------------------|

*** Install Perl 5 with =plenv=
#+begin_src sh
install_perl_sw () {
  if which plenv > /dev/null; then
    PLENV_ROOT="/usr/local/perl" && export PLENV_ROOT

    sudo mkdir -p "$PLENV_ROOT"
    sudo chown -R "$(whoami):admin" "$PLENV_ROOT"

    p "Installing Perl 5 with plenv"
    plenv install 5.26.0 > /dev/null 2>&1
    plenv global 5.26.0

    grep -q "${PLENV_ROOT}" "/etc/paths" || \
    sudo sed -i "" -e "1i\\
${PLENV_ROOT}/shims
" "/etc/paths"

    init_paths
    rehash
  fi
}
#+end_src

*** Install Python with =pyenv=
#+begin_src sh
install_python_sw () {
  if which pyenv > /dev/null; then
    CFLAGS="-I$(brew --prefix openssl)/include" && export CFLAGS
    LDFLAGS="-L$(brew --prefix openssl)/lib" && export LDFLAGS
    PYENV_ROOT="/usr/local/python" && export PYENV_ROOT

    sudo mkdir -p "$PYENV_ROOT"
    sudo chown -R "$(whoami):admin" "$PYENV_ROOT"

    p "Installing Python 2 with pyenv"
    pyenv install --skip-existing 2.7.13
    p "Installing Python 3 with pyenv"
    pyenv install --skip-existing 3.6.2
    pyenv global 2.7.13

    grep -q "${PYENV_ROOT}" "/etc/paths" || \
    sudo sed -i "" -e "1i\\
${PYENV_ROOT}/shims
" "/etc/paths"

    init_paths
    rehash

    pip install --upgrade "pip" "setuptools"

    # Reference: https://github.com/mdhiggins/sickbeard_mp4_automator
    pip install --upgrade "babelfish" "guessit<2" "qtfaststart" "requests" "stevedore==1.19.1" "subliminal<2"
    pip install --upgrade "requests-cache" "requests[security]"

    # Reference: https://github.com/pixelb/crudini
    pip install --upgrade "crudini"
  fi
}
#+end_src

*** Install Ruby with =rbenv=
#+begin_src sh
install_ruby_sw () {
  if which rbenv > /dev/null; then
    RBENV_ROOT="/usr/local/ruby" && export RBENV_ROOT

    sudo mkdir -p "$RBENV_ROOT"
    sudo chown -R "$(whoami):admin" "$RBENV_ROOT"

    p "Installing Ruby with rbenv"
    rbenv install --skip-existing 2.4.2
    rbenv global 2.4.2

    grep -q "${RBENV_ROOT}" "/etc/paths" || \
    sudo sed -i "" -e "1i\\
${RBENV_ROOT}/shims
" "/etc/paths"

    init_paths
    rehash

    printf "%s\n" \
      "gem: --no-document" | \
    tee "${HOME}/.gemrc" > /dev/null

    gem update --system > /dev/null

    trash "$(which rdoc)"
    trash "$(which ri)"
    gem update

    gem install bundler
  fi
}
#+end_src

** Configure

*** Define Function =config=
#+begin_src sh
config () {
  config_admin_req
  config_bbedit
  config_certbot
  config_desktop
  config_dovecot
  config_emacs
  config_environment
  config_ipmenulet
  config_istatmenus
  config_nginx
  config_openssl
  config_sysprefs
  config_zsh
  config_guest

  which custom
}
#+end_src

*** Define Function =config_defaults=
#+begin_src sh
config_defaults () {
  printf "%s\n" "${1}" | \
  while IFS="$(printf '\t')" read domain key type value host; do
    ${2} defaults ${host} write ${domain} "${key}" ${type} "${value}"
  done
}
#+end_src

*** Define Function =config_plist=
#+begin_src sh
T="$(printf '\t')"

config_plist () {
  printf "%s\n" "$1" | \
  while IFS="$T" read command entry type value; do
    case "$value" in
      (\$*)
        $4 /usr/libexec/PlistBuddy "$2" \
          -c "$command '${3}${entry}' $type '$(eval echo \"$value\")'" 2> /dev/null ;;
      (*)
        $4 /usr/libexec/PlistBuddy "$2" \
          -c "$command '${3}${entry}' $type '$value'" 2> /dev/null ;;
    esac
  done
}
#+end_src

*** Define Function =config_launchd=
#+begin_src sh
config_launchd () {
  test -d "$(dirname $1)" || \
    $3 mkdir -p "$(dirname $1)"

  test -f "$1" && \
    $3 launchctl unload "$1" && \
    $3 rm -f "$1"

  config_plist "$2" "$1" "$4" "$3" && \
    $3 plutil -convert xml1 "$1" && \
    $3 launchctl load "$1"
}
#+end_src

*** Mark Applications Requiring Administrator Account
#+begin_src sh :var _admin_req=_admin_req[3:-2,0]

config_admin_req () {
  printf "%s\n" "${_admin_req}" | \
  while IFS="$(printf '\t')" read app; do
    sudo tag -a "Red, admin" "/Applications/${app}"
  done
}
#+end_src

**** _admin_req
#+name: _admin_req
|------------------------|
| Admin Apps             |
|------------------------|
| Carbon Copy Cloner.app |
| Charles.app            |
| Composer.app           |
| Dropbox.app            |
| iStat Menus.app        |
| Moom.app               |
| VMware Fusion.app      |
| Wireshark.app          |
|------------------------|

*** Configure BBEdit
#+begin_src sh
config_bbedit () {
  if test -d "/Applications/BBEdit.app"; then
    test -f "/usr/local/bin/bbdiff" || \
    ln /Applications/BBEdit.app/Contents/Helpers/bbdiff /usr/local/bin/bbdiff && \
    ln /Applications/BBEdit.app/Contents/Helpers/bbedit_tool /usr/local/bin/bbedit && \
    ln /Applications/BBEdit.app/Contents/Helpers/bbfind /usr/local/bin/bbfind && \
    ln /Applications/BBEdit.app/Contents/Helpers/bbresults /usr/local/bin/bbresults
  fi
}
#+end_src

*** Configure Let’s Encrypt
#+begin_src sh
config_certbot () {
  test -d "/etc/letsencrypt" || \
    sudo mkdir -p /etc/letsencrypt

  sudo tee "/etc/letsencrypt/cli.ini" << EOF > /dev/null
agree-tos = True
authenticator = standalone
eff-email = True
manual-public-ip-logging-ok = True
nginx-ctl = $(which nginx)
nginx-server-root = /usr/local/etc/nginx
preferred-challenges = tls-sni-01
keep-until-expiring = True
rsa-key-size = 4096
text = True
EOF

  if ! test -e "/etc/letsencrypt/.git"; then
    a=$(ask "Existing Let’s Encrypt Git Repository Path or URL?" "Clone Repository" "")
    test -n "$a" && \
    case "$a" in
      (/*)
        sudo tee "/etc/letsencrypt/.git" << EOF > /dev/null ;;
gitdir: $a
EOF
      (*)
        sudo git -C "/etc/letsencrypt" remote add origin "$a"
        sudo git -C "/etc/letsencrypt" fetch origin master ;;
    esac
    sudo git -C "/etc/letsencrypt" reset --hard
    sudo git checkout -f -b master HEAD
  fi

  sudo launchctl unload /Library/LaunchDaemons/org.nginx.nginx.plist 2> /dev/null
  sudo certbot renew

  while true; do
    test -n "$1" && server_name="$1" || \
      server_name="$(ask 'New SSL Server: Server Name?' 'Create Server' 'example.com')"
    test -n "$server_name" || break

    test -n "$2" && proxy_address="$2" || \
      proxy_address="$(ask "Proxy Address for $server_name?" 'Set Address' 'http://127.0.0.1:80')"

    sudo certbot certonly --domain $server_name

    key1="$(openssl x509 -pubkey < /etc/letsencrypt/live/$server_name/fullchain.pem | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64)"
    key2="$(curl -s https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem | openssl x509 -pubkey | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64)"
    key3="$(curl -s https://letsencrypt.org/certs/isrgrootx1.pem | openssl x509 -pubkey | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64)"

    pkp="$(printf "add_header Public-Key-Pins 'pin-sha256=\"%s\"; pin-sha256=\"%s\"; pin-sha256=\"%s\"; max-age=2592000;';\n" $key1 $key2 $key3)"

    cat << EOF > "/usr/local/etc/nginx/servers/$server_name.conf"
<<server_name.conf>>
EOF
    unset argv
  done

  sudo launchctl load /Library/LaunchDaemons/org.nginx.nginx.plist
}
#+end_src

**** =/usr/local/etc/nginx/servers/server_name/server_name.conf=
#+begin_src conf :noweb-ref server_name.conf
server {
  server_name $server_name;

  location / {
    proxy_pass $proxy_address;
  }

  ssl_certificate /etc/letsencrypt/live/$server_name/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$server_name/privkey.pem;
  ssl_trusted_certificate /etc/letsencrypt/live/$server_name/chain.pem;

  $pkp

  add_header Content-Security-Policy "upgrade-insecure-requests;";
  add_header Referrer-Policy "strict-origin";
  add_header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload" always;
  add_header X-Content-Type-Options nosniff;
  add_header X-Frame-Options DENY;
  add_header X-Robots-Tag none;
  add_header X-XSS-Protection "1; mode=block";

  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  ssl_stapling on;
  ssl_stapling_verify on;

  # https://securityheaders.io/?q=https%3A%2F%2F$server_name&hide=on&followRedirects=on
  # https://www.ssllabs.com/ssltest/analyze.html?d=$server_name&hideResults=on&latest
}
#+end_src

*** Configure Default Apps
#+begin_src sh
config_default_apps () {
  true
}
#+end_src

*** Configure Desktop Picture
#+begin_src sh
config_desktop () {
  sudo rm -f "/Library/Caches/com.apple.desktop.admin.png"

  base64 -D << EOF > "/Library/Desktop Pictures/Solid Colors/Solid Black.png"
<<black.png.b64>>
EOF
}
#+end_src

**** =black.png.b64=
#+begin_src base64 :noweb-ref black.png.b64
iVBORw0KGgoAAAANSUhEUgAAAIAAAACAAQAAAADrRVxmAAAAGElEQVR4AWOgMxgFo2AUjIJRMApGwSgAAAiAAAH3bJXBAAAAAElFTkSuQmCC
#+end_src

*** Configure Dovecot
#+begin_src sh
config_dovecot () {
  if which /usr/local/sbin/dovecot > /dev/null; then
    if ! run "Configure Dovecot Email Server?" "Configure Server" "Cancel"; then
      sudo tee "/usr/local/etc/dovecot/dovecot.conf" << EOF > /dev/null
<<dovecot.conf>>
EOF

      MAILADM="$(ask 'Email: Postmaster Email?' 'Set Email' "$(whoami)@$(hostname -f | cut -d. -f2-)")"
      MAILSVR="$(ask 'Email: Server Hostname for DNS?' 'Set Hostname' "$(hostname -f)")"
      sudo certbot certonly --domain $MAILSVR
      printf "%s\n" \
        "postmaster_address = '${MAILADM}'" \
        "ssl_cert = </etc/letsencrypt/live/$MAILSVR/fullchain.pem" \
        "ssl_key = </etc/letsencrypt/live/$MAILSVR/privkey.pem" | \
      sudo tee -a "/usr/local/etc/dovecot/dovecot.conf" > /dev/null

      if test ! -f "/usr/local/etc/dovecot/cram-md5.pwd"; then
        while true; do
          MAILUSR="$(ask 'New Email Account: User Name?' 'Create Account' "$(whoami)")"
          test -n "${MAILUSR}" || break
          doveadm pw | \
          sed -e "s/^/${MAILUSR}:/" | \
          sudo tee -a "/usr/local/etc/dovecot/cram-md5.pwd"
        done
        sudo chown _dovecot "/usr/local/etc/dovecot/cram-md5.pwd"
        sudo chmod go= "/usr/local/etc/dovecot/cram-md5.pwd"
      fi

      sudo tee "/etc/pam.d/dovecot" << EOF > /dev/null
<<dovecot.pam>>
EOF

      sudo brew services start dovecot

      cat << EOF > "/usr/local/bin/imaptimefix.py"
<<imaptimefix.py>>
EOF
      chmod +x /usr/local/bin/imaptimefix.py
    fi
  fi
}
#+end_src

**** =/usr/local/etc/dovecot/dovecot.conf=
#+begin_src conf :noweb-ref dovecot.conf
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
  sieve_plugins = sieve_extprograms
  zlib_save = bz2
  zlib_save_level = 9
}
protocols = imap
service imap-login {
  inet_listener imap {
    port = 0
  }
}
ssl = required
ssl_cipher_list = ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS:!AES128
ssl_dh_parameters_length = 4096
ssl_prefer_server_ciphers = yes
ssl_protocols = !SSLv2 !SSLv3
userdb {
  driver = passwd
}
protocol lda {
  mail_plugins = sieve zlib
}

# auth_debug = yes
# auth_debug_passwords = yes
# auth_verbose = yes
# auth_verbose_passwords = plain
# mail_debug = yes
# verbose_ssl = yes
#+end_src

**** =/etc/pam.d/dovecot=
#+begin_src conf :noweb-ref dovecot.pam
auth	required	pam_opendirectory.so	try_first_pass
account	required	pam_nologin.so
account	required	pam_opendirectory.so
password	required	pam_opendirectory.so
#+end_src

**** =/usr/local/bin/imaptimefix.py=
#+begin_src python :noweb-ref imaptimefix.py
#!/usr/bin/env python

# Author: Zachary Cutlip <@zcutlip>
# http://shadow-file.blogspot.com/2012/06/parsing-email-and-fixing-timestamps-in.html
# Updated: Peter T Bosse II <@ptb>
# Purpose: A program to fix sorting of mail messages that have been POPed or
#          IMAPed in the wrong order. Compares time stamp sent and timestamp
#          received on an RFC822-formatted email message, and renames the
#          message file using the most recent timestamp that is no more than
#          24 hours after the date sent. Updates the file's atime/mtime with
#          the timestamp, as well. Does not modify the headers or contents of
#          the message.

from bz2 import BZ2File
from email import message_from_string
from email.utils import mktime_tz, parsedate_tz
from os import rename, utime, walk
from os.path import abspath, isdir, isfile, join
from re import compile, match
from sys import argv

if isdir(argv[1]):
  e = compile("([0-9]+)(\..*$)")

  for a, b, c in walk(argv[1]):
    for d in c:
      if e.match(d):
        f = message_from_string(BZ2File(join(a, d)).read())
        g = mktime_tz(parsedate_tz(f.get("Date")))

        h = 0
        for i in f.get_all("Received", []):
          j = i.split(";")[-1]
          if parsedate_tz(j):
            k = mktime_tz(parsedate_tz(j))
            if (k - g) > (60*60*24):
              continue

            h = k
          break

        if (h < 1):
          h = g

        l = e.match(d)

        if len(l.groups()) == 2:
          m = str(int(h)) + l.groups()[1]
          if not isfile(join(a, m)):
            rename(join(a, d), join(a, m))
          utime(join(a, m), (h, h))
#+end_src

*** Configure Emacs
#+begin_src sh
config_emacs () {
  test -f "/usr/local/bin/vi" || \
  cat << EOF > "/usr/local/bin/vi"
<<vi.sh>>
EOF

  chmod a+x /usr/local/bin/vi
  rehash
}
#+end_src

**** =/usr/local/bin/vi=
#+begin_src sh :noweb-ref vi.sh :tangle no
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
#+end_src

*** Configure Environment Variables
#+begin_src sh :var _environment_defaults=_environment_defaults[3:-2,0:4]
config_environment () {
  sudo tee "/etc/environment.sh" << 'EOF' > /dev/null
<<environment.sh>>
EOF
  sudo chmod a+x "/etc/environment.sh"
  rehash

  la="/Library/LaunchAgents/environment.user"
  ld="/Library/LaunchDaemons/environment"

  sudo mkdir -p "$(dirname $la)" "$(dirname $ld)"
  sudo launchctl unload "${la}.plist" "${ld}.plist" 2> /dev/null
  sudo rm -f "${la}.plist" "${ld}.plist"

  config_defaults "$_environment_defaults" "sudo"
  sudo plutil -convert xml1 "${la}.plist" "${ld}.plist"
  sudo launchctl load "${la}.plist" "${ld}.plist" 2> /dev/null
}
#+end_src

**** =/etc/environment.sh=
#+begin_src sh :noweb-ref environment.sh :tangle no
#!/bin/sh

set -e

if test -x /usr/libexec/path_helper; then
  export PATH=""
  eval `/usr/libexec/path_helper -s`
  launchctl setenv PATH $PATH
fi

osascript -e 'tell app "Dock" to quit'
#+end_src

**** _environment_defaults
#+name: _environment_defaults
|----------------------------------------+-------------+------------+---------------------+------|
| Domain                                 | Key         | Type       | Value               | Host |
|----------------------------------------+-------------+------------+---------------------+------|
| /Library/LaunchAgents/environment.user | KeepAlive   | -bool      | false               |      |
| /Library/LaunchAgents/environment.user | Label       | -string    | environment.user    |      |
| /Library/LaunchAgents/environment.user | ProcessType | -string    | Background          |      |
| /Library/LaunchAgents/environment.user | Program     | -string    | /etc/environment.sh |      |
| /Library/LaunchAgents/environment.user | RunAtLoad   | -bool      | true                |      |
| /Library/LaunchAgents/environment.user | WatchPaths  | -array-add | /etc/environment.sh |      |
| /Library/LaunchAgents/environment.user | WatchPaths  | -array-add | /etc/paths          |      |
| /Library/LaunchAgents/environment.user | WatchPaths  | -array-add | /etc/paths.d        |      |
| /Library/LaunchDaemons/environment     | KeepAlive   | -bool      | false               |      |
| /Library/LaunchDaemons/environment     | Label       | -string    | environment         |      |
| /Library/LaunchDaemons/environment     | ProcessType | -string    | Background          |      |
| /Library/LaunchDaemons/environment     | Program     | -string    | /etc/environment.sh |      |
| /Library/LaunchDaemons/environment     | RunAtLoad   | -bool      | true                |      |
| /Library/LaunchDaemons/environment     | WatchPaths  | -array-add | /etc/environment.sh |      |
| /Library/LaunchDaemons/environment     | WatchPaths  | -array-add | /etc/paths          |      |
| /Library/LaunchDaemons/environment     | WatchPaths  | -array-add | /etc/paths.d        |      |
|----------------------------------------+-------------+------------+---------------------+------|

*** Configure IPMenulet
#+begin_src sh
config_ipmenulet () {
  _ipm="/Applications/IPMenulet.app/Contents/Resources"
  if test -d "$_ipm"; then
    rm "${_ipm}/icon-19x19-black.png"
    ln "${_ipm}/icon-19x19-white.png" "${_ipm}/icon-19x19-black.png"
  fi
}
#+end_src

*** Configure iStat Menus
#+begin_src sh
config_istatmenus () {
  test -d "/Applications/iStat Menus.app" && \
  open "/Applications/iStat Menus.app"
}
#+end_src

**** Notes
#+begin_example conf
  client_max_body_size 0;

  location / {
    if ($http_x_plex_device_name = "") {
      rewrite ^/$ https://$host/web/index.html permanent;
    }
  }
#+end_example

*** Configure nginx
#+begin_src sh :var _nginx_defaults=_nginx_defaults[3:-2,0:4]
config_nginx () {
  cat << 'EOF' > /usr/local/etc/nginx/nginx.conf
<<nginx.conf>>
EOF

  ld="/Library/LaunchDaemons/org.nginx.nginx"

  sudo mkdir -p "$(dirname $ld)"
  sudo launchctl unload "${ld}.plist" 2> /dev/null
  sudo rm -f "${ld}.plist"

  config_defaults "$_nginx_defaults" "sudo"
  sudo plutil -convert xml1 "${ld}.plist"
  sudo launchctl load "${ld}.plist" 2> /dev/null
}
#+end_src

**** =/usr/local/etc/nginx/nginx.conf=
#+begin_src conf :noweb-ref nginx.conf
daemon off;

events {
  accept_mutex off;
  worker_connections 8000;
}

http {
  charset utf-8;
  charset_types
    application/javascript
    application/json
    application/rss+xml
    application/xhtml+xml
    application/xml
    text/css
    text/plain
    text/vnd.wap.wml;

  default_type application/octet-stream;

  error_log /dev/stderr;

  gzip on;
  gzip_comp_level 9;
  gzip_min_length 256;
  gzip_proxied any;
  gzip_static on;
  gzip_vary on;

  gzip_types
    application/atom+xml
    application/javascript
    application/json
    application/ld+json
    application/manifest+json
    application/rss+xml
    application/vnd.geo+json
    application/vnd.ms-fontobject
    application/x-font-ttf
    application/x-web-app-manifest+json
    application/xhtml+xml
    application/xml
    font/opentype
    image/bmp
    image/svg+xml
    image/x-icon
    text/cache-manifest
    text/css
    text/plain
    text/vcard
    text/vnd.rim.location.xloc
    text/vtt
    text/x-component
    text/x-cross-domain-policy;

  index index.html index.xhtml;

  log_format default '$host $status $body_bytes_sent "$request" "$http_referer"\n'
    '  $remote_addr "$http_user_agent"';

  map $http_upgrade $connection_upgrade {
    default upgrade;
    "" close;
  }

  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection $connection_upgrade;

  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header X-Real-IP $remote_addr;

  proxy_buffering off;
  proxy_redirect off;

  sendfile on;
  sendfile_max_chunk 512k;

  server_tokens off;

  resolver 8.8.8.8 8.8.4.4 [2001:4860:4860::8888] [2001:4860:4860::8844] valid=300s;
  resolver_timeout 5s;

  # https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
  ssl_ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS:!AES128;

  # openssl dhparam -out /etc/letsencrypt/ssl-dhparam.pem 4096
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

  ssl_ecdh_curve secp384r1;
  ssl_prefer_server_ciphers on;
  ssl_protocols TLSv1.2;
  ssl_session_cache shared:TLS:10m;

  types {
    application/atom+xml atom;
    application/font-woff woff;
    application/font-woff2 woff2;
    application/java-archive ear jar war;
    application/javascript js;
    application/json json map topojson;
    application/ld+json jsonld;
    application/mac-binhex40 hqx;
    application/manifest+json webmanifest;
    application/msword doc;
    application/octet-stream bin deb dll dmg exe img iso msi msm msp safariextz;
    application/pdf pdf;
    application/postscript ai eps ps;
    application/rss+xml rss;
    application/rtf rtf;
    application/vnd.geo+json geojson;
    application/vnd.google-earth.kml+xml kml;
    application/vnd.google-earth.kmz kmz;
    application/vnd.ms-excel xls;
    application/vnd.ms-fontobject eot;
    application/vnd.ms-powerpoint ppt;
    application/vnd.openxmlformats-officedocument.presentationml.presentation pptx;
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet xlsx;
    application/vnd.openxmlformats-officedocument.wordprocessingml.document docx;
    application/vnd.wap.wmlc wmlc;
    application/x-7z-compressed 7z;
    application/x-bb-appworld bbaw;
    application/x-bittorrent torrent;
    application/x-chrome-extension crx;
    application/x-cocoa cco;
    application/x-font-ttf ttc ttf;
    application/x-java-archive-diff jardiff;
    application/x-java-jnlp-file jnlp;
    application/x-makeself run;
    application/x-opera-extension oex;
    application/x-perl pl pm;
    application/x-pilot pdb prc;
    application/x-rar-compressed rar;
    application/x-redhat-package-manager rpm;
    application/x-sea sea;
    application/x-shockwave-flash swf;
    application/x-stuffit sit;
    application/x-tcl tcl tk;
    application/x-web-app-manifest+json webapp;
    application/x-x509-ca-cert crt der pem;
    application/x-xpinstall xpi;
    application/xhtml+xml xhtml;
    application/xml rdf xml;
    application/xslt+xml xsl;
    application/zip zip;
    audio/midi mid midi kar;
    audio/mp4 aac f4a f4b m4a;
    audio/mpeg mp3;
    audio/ogg oga ogg opus;
    audio/x-realaudio ra;
    audio/x-wav wav;
    font/opentype otf;
    image/bmp bmp;
    image/gif gif;
    image/jpeg jpeg jpg;
    image/png png;
    image/svg+xml svg svgz;
    image/tiff tif tiff;
    image/vnd.wap.wbmp wbmp;
    image/webp webp;
    image/x-icon cur ico;
    image/x-jng jng;
    text/cache-manifest appcache;
    text/css css;
    text/html htm html shtml;
    text/mathml mml;
    text/plain txt;
    text/vcard vcard vcf;
    text/vnd.rim.location.xloc xloc;
    text/vnd.sun.j2me.app-descriptor jad;
    text/vnd.wap.wml wml;
    text/vtt vtt;
    text/x-component htc;
    video/3gpp 3gp 3gpp;
    video/mp4 f4p f4v m4v mp4;
    video/mpeg mpeg mpg;
    video/ogg ogv;
    video/quicktime mov;
    video/webm webm;
    video/x-flv flv;
    video/x-mng mng;
    video/x-ms-asf asf asx;
    video/x-ms-wmv wmv;
    video/x-msvideo avi;
  }

  include servers/*.conf;
}

worker_processes auto;
#+end_src

**** _nginx_defaults
#+name: _nginx_defaults
|----------------------------------------+-------------------+------------+-------------------------------------+------|
| Domain                                 | Key               | Type       | Value                               | Host |
|----------------------------------------+-------------------+------------+-------------------------------------+------|
| /Library/LaunchDaemons/org.nginx.nginx | KeepAlive         | -bool      | true                                |      |
| /Library/LaunchDaemons/org.nginx.nginx | Label             | -string    | org.nginx.nginx                     |      |
| /Library/LaunchDaemons/org.nginx.nginx | ProcessType       | -string    | Background                          |      |
| /Library/LaunchDaemons/org.nginx.nginx | Program           | -string    | /usr/local/bin/nginx                |      |
| /Library/LaunchDaemons/org.nginx.nginx | RunAtLoad         | -bool      | true                                |      |
| /Library/LaunchDaemons/org.nginx.nginx | StandardErrorPath | -string    | /usr/local/var/log/nginx/error.log  |      |
| /Library/LaunchDaemons/org.nginx.nginx | StandardOutPath   | -string    | /usr/local/var/log/nginx/access.log |      |
| /Library/LaunchDaemons/org.nginx.nginx | UserName          | -string    | root                                |      |
| /Library/LaunchDaemons/org.nginx.nginx | WatchPaths        | -array-add | /usr/local/etc/nginx                |      |
|----------------------------------------+-------------------+------------+-------------------------------------+------|

*** Configure OpenSSL
Create an intentionally invalid certificate for use with a DNS-based ad blocker, e.g. https://pi-hole.net
#+begin_src sh
config_openssl () {
  _default="/etc/letsencrypt/live/default"
  test -d "$_default" || mkdir -p "$_default"

  cat << EOF > "${_default}/default.cnf"
<<openssl.cnf>>
EOF

  openssl req -days 1 -new -newkey rsa -x509 \
    -config "${_default}/default.cnf" \
    -out "${_default}/default.crt"

  cat << EOF > "/usr/local/etc/nginx/servers/default.conf"
<<default.conf>>
EOF
}
#+end_src

**** =/etc/letsencrypt/live/default/default.cnf=
#+begin_src conf :noweb-ref openssl.cnf
[ req ]
default_bits = 4096
default_keyfile = ${_default}/default.key
default_md = sha256
distinguished_name = dn
encrypt_key = no
prompt = no
utf8 = yes
x509_extensions = v3_ca

[ dn ]
CN = *

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = CA:true
#+end_src

**** =/usr/local/etc/nginx/servers/default.conf=
#+begin_src conf :noweb-ref default.conf
server {
  server_name .$(hostname -f | cut -d. -f2-);

  listen 80;
  listen [::]:80;

  return 301 https://\$host\$request_uri;
}

server {
  listen 80 default_server;
  listen [::]:80 default_server;

  listen 443 default_server ssl http2;
  listen [::]:443 default_server ssl http2;

  ssl_certificate ${_default}/default.crt;
  ssl_certificate_key ${_default}/default.key;

  ssl_ciphers NULL;

  return 204;
}
#+end_src

*** Configure System Preferences
#+begin_src sh
config_sysprefs () {
  config_energy
  config_loginwindow
  config_mas
}
#+end_src

**** Configure Energy Saver
#+begin_src sh :var _energy=_energy[3:-2,1:3]

config_energy () {
  printf "%s\n" "${_energy}" | \
  while IFS="$(printf '\t')" read flag setting value; do
    sudo pmset $flag ${setting} ${value}
  done
}
#+end_src

***** _energy
#+name: _energy
|--------------------------------------------------------------------------------------+------+--------------+-------|
| Preference                                                                           | Flag | Setting      | Value |
|--------------------------------------------------------------------------------------+------+--------------+-------|
| *Power: Turn display off after:* ~20 min~                                            | -c   | displaysleep |    20 |
| *Power:* ~on~ *Prevent computer from sleeping automatically when the display is off* | -c   | sleep        |     0 |
| *Power:* ~60 min~ *Put hard disks to sleep when possible*                            | -c   | disksleep    |    60 |
| *Power:* ~on~ *Wake for network access*                                              | -c   | womp         |     1 |
| *Power:* ~on~ *Start up automatically after a power failure*                         | -c   | autorestart  |     1 |
| *Power:* ~on~ *Enable Power Nap*                                                     | -c   | powernap     |     1 |
| *UPS: Turn display off after:* ~2 min~                                               | -u   | displaysleep |     2 |
| *UPS:* ~on~ *Slightly dim the display when using this power source*                  | -u   | lessbright   |     1 |
| *UPS:* ~on~ *Shut down the computer after using the UPS battery for:* ~5 min~        | -u   | haltafter    |     5 |
| *UPS:* ~off~ *Shut down the computer when the time remaining on the UPS battery is:* | -u   | haltremain   |    -1 |
| *UPS:* ~off~ *Shut down the computer when the UPS battery level is below:*           | -u   | haltlevel    |    -1 |
|--------------------------------------------------------------------------------------+------+--------------+-------|

**** Configure Login Window
#+begin_src sh :var _loginwindow=_loginwindow[3:-2,1:5]

config_loginwindow () {
  config_defaults "${_loginwindow}" "sudo"
}
#+end_src

**** _loginwindow
#+name: _loginwindow
|------------------------------------------------+--------------------------------------------+--------------+-------+-------+------|
| Preference                                     | Domain                                     | Key          | Type  | Value | Host |
|------------------------------------------------+--------------------------------------------+--------------+-------+-------+------|
| *Display login window as:* ~Name and password~ | /Library/Preferences/com.apple.loginwindow | SHOWFULLNAME | -bool | true  |      |
|------------------------------------------------+--------------------------------------------+--------------+-------+-------+------|

**** Configure App Store
#+begin_src sh :var _swupdate=_swupdate[3:-2,1:5]

config_mas () {
  config_defaults "${_swupdate}" "sudo"
}
#+end_src

**** _swupdate
#+name: _swupdate
|------------------------------+-----------------------------------------+---------------------------+-------+-------+------|
| Preference                   | Domain                                  | Key                       | Type  | Value | Host |
|------------------------------+-----------------------------------------+---------------------------+-------+-------+------|
| ~on~ *Install app updates*   | /Library/Preferences/com.apple.commerce | AutoUpdate                | -bool | true  |      |
| ~on~ *Install macOS updates* | /Library/Preferences/com.apple.commerce | AutoUpdateRestartRequired | -bool | true  |      |
|------------------------------+-----------------------------------------+---------------------------+-------+-------+------|

*** Configure Z-Shell
#+begin_src sh
config_zsh () {
  grep -q "$(which zsh)" /etc/shells ||
  print "$(which zsh)\n" | \
  sudo tee -a /etc/shells > /dev/null

  case "$SHELL" in
    ($(which zsh)) ;;
    (*)
      chsh -s "$(which zsh)"
      sudo chsh -s $(which zsh) ;;
  esac

  sudo tee -a /etc/zshenv << 'EOF' > /dev/null
<<etc-zshenv>>
EOF
  sudo chmod +x "/etc/zshenv"
  . "/etc/zshenv"

  sudo tee /etc/zshrc << 'EOF' > /dev/null
<<etc-zshrc>>
EOF
  sudo chmod +x "/etc/zshrc"
  . "/etc/zshrc"
}
#+end_src

**** =/etc/zshenv=
#+begin_src sh :noweb-ref etc-zshenv :tangle no
#-- Exports ----------------------------------------------------

export \
  ZDOTDIR="${HOME}/.zsh" \
  MASDIR="$(getconf DARWIN_USER_CACHE_DIR)com.apple.appstore" \
  NODENV_ROOT="/usr/local/node" \
  PLENV_ROOT="/usr/local/perl" \
  PYENV_ROOT="/usr/local/python" \
  RBENV_ROOT="/usr/local/ruby" \
  EDITOR="vi" \
  VISUAL="vi" \
  PAGER="less" \
  LANG="en_US.UTF-8" \
  LESS="-egiMQRS -x2 -z-2" \
  LESSHISTFILE="/dev/null" \
  HISTSIZE=50000 \
  SAVEHIST=50000 \
  KEYTIMEOUT=1

test -d "$ZDOTDIR" || \
  mkdir -p "$ZDOTDIR"

test -f "${ZDOTDIR}/.zshrc" || \
  touch "${ZDOTDIR}/.zshrc"

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path
#+end_src

**** =/etc/zshrc=
#+begin_src sh :noweb-ref etc-zshrc :tangle no
#-- Exports ----------------------------------------------------

export \
  HISTFILE="${ZDOTDIR:-$HOME}/.zhistory"

#-- Changing Directories ---------------------------------------

setopt \
  autocd \
  autopushd \
  cdablevars \
  chasedots \
  chaselinks \
  NO_posixcd \
  pushdignoredups \
  no_pushdminus \
  pushdsilent \
  pushdtohome

#-- Completion -------------------------------------------------

setopt \
  ALWAYSLASTPROMPT \
  no_alwaystoend \
  AUTOLIST \
  AUTOMENU \
  autonamedirs \
  AUTOPARAMKEYS \
  AUTOPARAMSLASH \
  AUTOREMOVESLASH \
  no_bashautolist \
  no_completealiases \
  completeinword \
  no_globcomplete \
  HASHLISTALL \
  LISTAMBIGUOUS \
  no_LISTBEEP \
  no_listpacked \
  no_listrowsfirst \
  LISTTYPES \
  no_menucomplete \
  no_recexact

#-- Expansion and Globbing -------------------------------------

setopt \
  BADPATTERN \
  BAREGLOBQUAL \
  braceccl \
  CASEGLOB \
  CASEMATCH \
  NO_cshnullglob \
  EQUALS \
  extendedglob \
  no_forcefloat \
  GLOB \
  NO_globassign \
  no_globdots \
  no_globstarshort \
  NO_globsubst \
  no_histsubstpattern \
  NO_ignorebraces \
  no_ignoreclosebraces \
  NO_kshglob \
  no_magicequalsubst \
  no_markdirs \
  MULTIBYTE \
  NOMATCH \
  no_nullglob \
  no_numericglobsort \
  no_rcexpandparam \
  no_rematchpcre \
  NO_shglob \
  UNSET \
  no_warncreateglobal \
  no_warnnestedvar

#-- History ----------------------------------------------------

setopt \
  APPENDHISTORY \
  BANGHIST \
  extendedhistory \
  no_histallowclobber \
  no_HISTBEEP \
  histexpiredupsfirst \
  no_histfcntllock \
  histfindnodups \
  histignorealldups \
  histignoredups \
  histignorespace \
  histlexwords \
  no_histnofunctions \
  no_histnostore \
  histreduceblanks \
  HISTSAVEBYCOPY \
  histsavenodups \
  histverify \
  incappendhistory \
  incappendhistorytime \
  sharehistory

#-- Initialisation ---------------------------------------------

setopt \
  no_allexport \
  GLOBALEXPORT \
  GLOBALRCS \
  RCS

#-- Input/Output -----------------------------------------------

setopt \
  ALIASES \
  no_CLOBBER \
  no_correct \
  no_correctall \
  dvorak \
  no_FLOWCONTROL \
  no_ignoreeof \
  NO_interactivecomments \
  HASHCMDS \
  HASHDIRS \
  no_hashexecutablesonly \
  no_mailwarning \
  pathdirs \
  NO_pathscript \
  no_printeightbit \
  no_printexitvalue \
  rcquotes \
  NO_rmstarsilent \
  no_rmstarwait \
  SHORTLOOPS \
  no_sunkeyboardhack

#-- Job Control ------------------------------------------------

setopt \
  no_autocontinue \
  autoresume \
  no_BGNICE \
  CHECKJOBS \
  no_HUP \
  longlistjobs \
  MONITOR \
  NOTIFY \
  NO_posixjobs

#-- Prompting --------------------------------------------------

setopt \
  NO_promptbang \
  PROMPTCR \
  PROMPTSP \
  PROMPTPERCENT \
  promptsubst \
  transientrprompt

#-- Scripts and Functions --------------------------------------

setopt \
  NO_aliasfuncdef \
  no_cbases \
  no_cprecedences \
  DEBUGBEFORECMD \
  no_errexit \
  no_errreturn \
  EVALLINENO \
  EXEC \
  FUNCTIONARGZERO \
  no_localloops \
  NO_localoptions \
  no_localpatterns \
  NO_localtraps \
  MULTIFUNCDEF \
  MULTIOS \
  NO_octalzeroes \
  no_pipefail \
  no_sourcetrace \
  no_typesetsilent \
  no_verbose \
  no_xtrace

#-- Shell Emulation --------------------------------------------

setopt \
  NO_appendcreate \
  no_bashrematch \
  NO_bsdecho \
  no_continueonerror \
  NO_cshjunkiehistory \
  NO_cshjunkieloops \
  NO_cshjunkiequotes \
  NO_cshnullcmd \
  NO_ksharrays \
  NO_kshautoload \
  NO_kshoptionprint \
  no_kshtypeset \
  no_kshzerosubscript \
  NO_posixaliases \
  no_posixargzero \
  NO_posixbuiltins \
  NO_posixidentifiers \
  NO_posixstrings \
  NO_posixtraps \
  NO_shfileexpansion \
  NO_shnullcmd \
  NO_shoptionletters \
  NO_shwordsplit \
  no_trapsasync

#-- Zle --------------------------------------------------------

setopt \
  no_BEEP \
  combiningchars \
  no_overstrike \
  NO_singlelinezle

#-- Aliases ----------------------------------------------------

alias \
  ll="/bin/ls -aFGHhlOw"

#-- Functions --------------------------------------------------

autoload -Uz \
  add-zsh-hook \
  compaudit \
  compinit

compaudit 2> /dev/null | \
  xargs -L 1 chmod go-w 2> /dev/null

compinit -u

which nodenv > /dev/null && \
  eval "$(nodenv init - zsh)"

which plenv > /dev/null && \
  eval "$(plenv init - zsh)"

which pyenv > /dev/null && \
  eval "$(pyenv init - zsh)"

which rbenv > /dev/null && \
  eval "$(rbenv init - zsh)"

sf () {
  SetFile -P -d "$1 12:00:00" -m "$1 12:00:00" $argv[2,$]
}

ssh-add -A 2> /dev/null

#-- zsh-syntax-highlighting ------------------------------------

. "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

#-- zsh-history-substring-search -------------------------------

. "$(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="fg=default,underline" && \
  export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="fg=red,underline" && \
  export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND

#-- Zle --------------------------------------------------------

zmodload zsh/zle

bindkey -d
bindkey -v

for k in "vicmd" "viins"; do
  bindkey -M $k '\C-A' beginning-of-line
  bindkey -M $k '\C-E' end-of-line
  bindkey -M $k '\C-U' kill-whole-line
  bindkey -M $k '\e[3~' delete-char
  bindkey -M $k '\e[A' history-substring-search-up
  bindkey -M $k '\e[B' history-substring-search-down
  bindkey -M $k '\x7f' backward-delete-char
done

for f in \
  "zle-keymap-select" \
  "zle-line-finish" \
  "zle-line-init"
do
  eval "$f () {
    case \$TERM_PROGRAM in
      ('Apple_Terminal')
        test \$KEYMAP = 'vicmd' && \
          printf '%b' '\e[4 q' || \
          printf '%b' '\e[6 q' ;;
      ('iTerm.app')
        test \$KEYMAP = 'vicmd' && \
          printf '%b' '\e]Plf27f7f\e\x5c\e[4 q' || \
          printf '%b' '\e]Pl99cc99\e\x5c\e[6 q' ;;
    esac
  }"
  zle -N $f
done

#-- prompt_ptb_setup -------------------------------------------

prompt_ptb_setup () {
  I="$(printf '%b' '%{\e[3m%}')"
  i="$(printf '%b' '%{\e[0m%}')"
  PROMPT="%F{004}$I%d$i %(!.%F{001}.%F{002})%n %B❯%b%f " && \
  export PROMPT
}

prompt_ptb_setup

prompt_ptb_precmd () {
  if test "$(uname -s)" = "Darwin"; then
    print -Pn "\e]7;file://%M\${PWD// /%%20}\a"
    print -Pn "\e]2;%n@%m\a"
    print -Pn "\e]1;%~\a"
  fi

  test -n "$(git rev-parse --git-dir 2> /dev/null)" && \
  RPROMPT="%F{000}$(git rev-parse --abbrev-ref HEAD 2> /dev/null)%f" && \
  export RPROMPT
}

add-zsh-hook precmd \
  prompt_ptb_precmd
#+end_src

*** Configure New Account
#+begin_src sh
config_new_account () {
  e="$(ask 'New macOS Account: Email Address?' 'OK' '')"
  curl --output "/Library/User Pictures/${e}.jpg" --silent \
    "https://www.gravatar.com/avatar/$(md5 -qs ${e}).jpg?s=512"

  g="$(curl --location --silent \
    "https://api.github.com/search/users?q=${e}" | \
    sed -n 's/^.*"url": "\(.*\)".*/\1/p')"
  g="$(curl --location --silent ${g})"

  n="$(printf ${g} | sed -n 's/^.*"name": "\(.*\)".*/\1/p')"
  n="$(ask 'New macOS Account: Real Name?' 'OK' ${n})"

  u="$(printf ${g} | sed -n 's/^.*"login": "\(.*\)".*/\1/p')"
  u="$(ask 'New macOS Account: User Name?' 'OK' ${u})"

  sudo defaults write \
    "/System/Library/User Template/Non_localized/Library/Preferences/.GlobalPreferences.plist" \
    "com.apple.swipescrolldirection" -bool false

  sudo sysadminctl -admin -addUser "${u}" -fullName "${n}" -password - \
    -shell "$(which zsh)" -picture "/Library/User Pictures/${e}.jpg"
}
#+end_src

*** Configure Guest Users
#+begin_src sh
config_guest () {
  sudo sysadminctl -guestAccount off
}
#+end_src

*** Reinstate =sudo= Password
#+begin_src sh
config_rm_sudoers () {
  sudo -- sh -c \
    "rm -f /etc/sudoers.d/wheel; dscl /Local/Default -delete /Groups/wheel GroupMembership $(whoami)"

  /usr/bin/read -n 1 -p "Press any key to continue.
" -s
  if run "Log Out Then Log Back In?" "Cancel" "Log Out"; then
    osascript -e 'tell app "loginwindow" to «event aevtrlgo»'
  fi
}
#+end_src

** Customize

*** Define Function =custom=
#+begin_src sh
custom () {
  custom_githome
  custom_atom
  custom_autoping
  custom_dropbox
  custom_duti
  custom_emacs
  custom_finder
  custom_getmail
  custom_git
  custom_gnupg
  custom_istatmenus
  custom_meteorologist
  custom_moom
  custom_mp4_automator
  custom_nvalt
  custom_nzbget
  custom_safari
  custom_sieve
  custom_sonarr
  custom_ssh
  custom_sysprefs
  custom_terminal
  custom_vim
  custom_vlc

  which personalize_all
}
#+end_src

*** Customize Home
#+begin_src sh
custom_githome () {
  git -C "${HOME}" init

  test -f "${CACHES}/dbx/.zshenv" && \
    mkdir -p "${ZDOTDIR:-$HOME}" && \
    cp "${CACHES}/dbx/.zshenv" "${ZDOTDIR:-$HOME}" && \
    . "${ZDOTDIR:-$HOME}/.zshenv"

  a=$(ask "Existing Git Home Repository Path or URL" "Add Remote" "")
  if test -n "${a}"; then
    git -C "${HOME}" remote add origin "${a}"
    git -C "${HOME}" fetch origin master
  fi

  if run "Encrypt and commit changes to Git and push to GitHub, automatically?" "No" "Add AutoKeep"; then
    curl --location --silent \
      "https://github.com/ptb/autokeep/raw/master/autokeep.command" | \
      . /dev/stdin 0

    autokeep_remote
    autokeep_push
    autokeep_gitignore
    autokeep_post_commit
    autokeep_launchagent
    autokeep_crypt

    git reset --hard
    git checkout -f -b master FETCH_HEAD
  fi

  chmod -R go= "${HOME}" > /dev/null 2>&1
}
#+end_src

*** Customize Atom
#+begin_src sh :var _atom=_atom[3:-2,0]

custom_atom () {
  if which apm > /dev/null; then
    mkdir -p "${HOME}/.atom/.apm"

    cat << EOF > "${HOME}/.atom/.apmrc"
cache = ${CACHES}/apm
EOF

    cat << EOF > "${HOME}/.atom/.apm/.apmrc"
cache = ${CACHES}/apm
EOF

    printf "%s\n" "${_atom}" | \
    while IFS="$(printf '\t')" read pkg; do
      test -d "${HOME}/.atom/packages/${pkg}" ||
      apm install "${pkg}"
    done

    cat << EOF > "${HOME}/.atom/config.cson"
<<config.cson>>
EOF

    cat << EOF > "${HOME}/.atom/packages/tomorrow-night-eighties-syntax/styles/colors.less"
<<colors.less>>
EOF
  fi
}
#+end_src

**** _atom
#+name: _atom
|--------------------------------+---------------------------------------------------------|
| Atom Package Name              | Reference URL                                           |
|--------------------------------+---------------------------------------------------------|
| atom-beautify                  | https://atom.io/packages/atom-beautify                  |
| atom-css-comb                  | https://atom.io/packages/atom-css-comb                  |
| atom-fuzzy-grep                | https://atom.io/packages/atom-fuzzy-grep                                                        |
| atom-jade                      | https://atom.io/packages/atom-jade                      |
| atom-wallaby                   | https://atom.io/packages/atom-wallaby                   |
| autoclose-html                 | https://atom.io/packages/autoclose-html                 |
| autocomplete-python            | https://atom.io/packages/autocomplete-python            |
| busy-signal                    | https://atom.io/packages/busy-signal                    |
| double-tag                     | https://atom.io/packages/double-tag                     |
| editorconfig                   | https://atom.io/packages/editorconfig                   |
| ex-mode                        | https://atom.io/packages/ex-mode                        |
| file-icons                     | https://atom.io/packages/file-icons                     |
| git-plus                       | https://atom.io/packages/git-plus                       |
| git-time-machine               | https://atom.io/packages/git-time-machine               |
| highlight-selected             | https://atom.io/packages/highlight-selected             |
| intentions                     | https://atom.io/packages/intentions                     |
| language-docker                | https://atom.io/packages/language-docker                |
| language-jade                  | https://atom.io/packages/language-jade                  |
| language-javascript-jsx        | https://atom.io/packages/language-javascript-jsx        |
| language-lisp                  | https://atom.io/packages/language-lisp                  |
| language-slim                  | https://atom.io/packages/language-slim                  |
| linter                         | https://atom.io/packages/linter                         |
| linter-eslint                  | https://atom.io/packages/linter-eslint                  |
| linter-rubocop                 | https://atom.io/packages/linter-rubocop                 |
| linter-shellcheck              | https://atom.io/packages/linter-shellcheck              |
| linter-ui-default              | https://atom.io/packages/linter-ui-default              |
| MagicPython                    | https://atom.io/packages/MagicPython                    |
| python-yapf                    | https://atom.io/packages/python-yapf                    |
| react                          | https://atom.io/packages/react                          |
| riot                           | https://atom.io/packages/riot                           |
| sort-lines                     | https://atom.io/packages/sort-lines                     |
| term3                          | https://atom.io/packages/term3                          |
| tomorrow-night-eighties-syntax | https://atom.io/packages/tomorrow-night-eighties-syntax |
| tree-view-open-files           | https://atom.io/packages/tree-view-open-files           |
| vim-mode-plus                  | https://atom.io/packages/vim-mode-plus                  |
| vim-mode-zz                    | https://atom.io/packages/vim-mode-zz                    |
|--------------------------------+---------------------------------------------------------|

**** =${HOME}/.atom/config.cson=
#+begin_src cson :noweb-ref config.cson
"*":
  "autocomplete-python":
    useKite: false
  core:
    telemetryConsent: "limited"
    themes: [
      "one-dark-ui"
      "tomorrow-night-eighties-syntax"
    ]
  editor:
    fontFamily: "Inconsolata LGC"
    fontSize: 13
  welcome:
    showOnStartup: false
#+end_src

**** =${HOME}/.atom/packages/tomorrow-night-eighties-syntax/styles/colors.less=
#+begin_src less :noweb-ref colors.less
@background: #222222;
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
#+end_src

*** Customize autoping
#+begin_src sh :var _autoping=_autoping[3:-2,1:5]

custom_autoping () {
  config_defaults "${_autoping}"
}
#+end_src

**** _autoping
#+name: _autoping
|----------------------------------+---------------------+----------------------+---------+------------+------|
| Preference                       | Domain              | Key                  | Type    | Value      | Host |
|----------------------------------+---------------------+----------------------+---------+------------+------|
| *Host to Ping*                   | com.memset.autoping | Hostname             | -string | google.com |      |
| *Slow Ping Threshold (ms)* ~100~ | com.memset.autoping | SlowPingLowThreshold | -int    | 100        |      |
| *Launch at Login* ~on~           | com.memset.autoping | LaunchAtLogin        | -bool   | true       |      |
| *Display* ~Icon and Text~        | com.memset.autoping | ShowIcon             | -bool   | true       |      |
|                                  | com.memset.autoping | ShowText             | -bool   | true       |      |
| *Packet Loss Text* ~on~          | com.memset.autoping | ShowPacketLossText   | -bool   | true       |      |
| *Connection Up/Down Alerts* ~on~ | com.memset.autoping | ShowNotifications    | -bool   | true       |      |
|----------------------------------+---------------------+----------------------+---------+------------+------|

*** Customize Dropbox
#+begin_src sh
custom_dropbox () {
  test -d "/Applications/Dropbox.app" && \
    open "/Applications/Dropbox.app"
}
#+end_src

*** Customize Default UTIs
#+begin_src sh :var _duti=_duti[3:-2,0:2]
custom_duti () {
  if test -x "/usr/local/bin/duti"; then
    test -f "${HOME}/Library/Preferences/org.duti.plist" && \
      rm "${HOME}/Library/Preferences/org.duti.plist"

    printf "%s\n" "${_duti}" | \
    while IFS="$(printf '\t')" read id uti role; do
      defaults write org.duti DUTISettings -array-add \
        "{
          DUTIBundleIdentifier = '$a';
          DUTIUniformTypeIdentifier = '$b';
          DUTIRole = '$c';
        }"
    done

    duti "${HOME}/Library/Preferences/org.duti.plist" 2> /dev/null
  fi
}
#+end_src

**** _duti
#+name: _duti
|----------------------------+--------------------------------------------------------+--------|
| Bundle ID                  | UTI                                                    | Role   |
|----------------------------+--------------------------------------------------------+--------|
| com.apple.DiskImageMounter | com.apple.disk-image                                   | all    |
| com.apple.DiskImageMounter | public.disk-image                                      | all    |
| com.apple.DiskImageMounter | public.iso-image                                       | all    |
| com.apple.QuickTimePlayerX | com.apple.coreaudio-format                             | all    |
| com.apple.QuickTimePlayerX | com.apple.quicktime-movie                              | all    |
| com.apple.QuickTimePlayerX | com.microsoft.waveform-audio                           | all    |
| com.apple.QuickTimePlayerX | public.aifc-audio                                      | all    |
| com.apple.QuickTimePlayerX | public.aiff-audio                                      | all    |
| com.apple.QuickTimePlayerX | public.audio                                           | all    |
| com.apple.QuickTimePlayerX | public.mp3                                             | all    |
| com.apple.Safari           | com.compuserve.gif                                     | all    |
| com.apple.Terminal         | com.apple.terminal.shell-script                        | all    |
| com.apple.iTunes           | com.apple.iTunes.audible                               | all    |
| com.apple.iTunes           | com.apple.iTunes.ipg                                   | all    |
| com.apple.iTunes           | com.apple.iTunes.ipsw                                  | all    |
| com.apple.iTunes           | com.apple.iTunes.ite                                   | all    |
| com.apple.iTunes           | com.apple.iTunes.itlp                                  | all    |
| com.apple.iTunes           | com.apple.iTunes.itms                                  | all    |
| com.apple.iTunes           | com.apple.iTunes.podcast                               | all    |
| com.apple.iTunes           | com.apple.m4a-audio                                    | all    |
| com.apple.iTunes           | com.apple.mpeg-4-ringtone                              | all    |
| com.apple.iTunes           | com.apple.protected-mpeg-4-audio                       | all    |
| com.apple.iTunes           | com.apple.protected-mpeg-4-video                       | all    |
| com.apple.iTunes           | com.audible.aa-audio                                   | all    |
| com.apple.iTunes           | public.mpeg-4-audio                                    | all    |
| com.apple.installer        | com.apple.installer-package-archive                    | all    |
| com.github.atom            | com.apple.binary-property-list                         | editor |
| com.github.atom            | com.apple.crashreport                                  | editor |
| com.github.atom            | com.apple.dt.document.ascii-property-list              | editor |
| com.github.atom            | com.apple.dt.document.script-suite-property-list       | editor |
| com.github.atom            | com.apple.dt.document.script-terminology-property-list | editor |
| com.github.atom            | com.apple.log                                          | editor |
| com.github.atom            | com.apple.property-list                                | editor |
| com.github.atom            | com.apple.rez-source                                   | editor |
| com.github.atom            | com.apple.symbol-export                                | editor |
| com.github.atom            | com.apple.xcode.ada-source                             | editor |
| com.github.atom            | com.apple.xcode.bash-script                            | editor |
| com.github.atom            | com.apple.xcode.configsettings                         | editor |
| com.github.atom            | com.apple.xcode.csh-script                             | editor |
| com.github.atom            | com.apple.xcode.fortran-source                         | editor |
| com.github.atom            | com.apple.xcode.ksh-script                             | editor |
| com.github.atom            | com.apple.xcode.lex-source                             | editor |
| com.github.atom            | com.apple.xcode.make-script                            | editor |
| com.github.atom            | com.apple.xcode.mig-source                             | editor |
| com.github.atom            | com.apple.xcode.pascal-source                          | editor |
| com.github.atom            | com.apple.xcode.strings-text                           | editor |
| com.github.atom            | com.apple.xcode.tcsh-script                            | editor |
| com.github.atom            | com.apple.xcode.yacc-source                            | editor |
| com.github.atom            | com.apple.xcode.zsh-script                             | editor |
| com.github.atom            | com.apple.xml-property-list                            | editor |
| com.github.atom            | com.barebones.bbedit.actionscript-source               | editor |
| com.github.atom            | com.barebones.bbedit.erb-source                        | editor |
| com.github.atom            | com.barebones.bbedit.ini-configuration                 | editor |
| com.github.atom            | com.barebones.bbedit.javascript-source                 | editor |
| com.github.atom            | com.barebones.bbedit.json-source                       | editor |
| com.github.atom            | com.barebones.bbedit.jsp-source                        | editor |
| com.github.atom            | com.barebones.bbedit.lasso-source                      | editor |
| com.github.atom            | com.barebones.bbedit.lua-source                        | editor |
| com.github.atom            | com.barebones.bbedit.setext-source                     | editor |
| com.github.atom            | com.barebones.bbedit.sql-source                        | editor |
| com.github.atom            | com.barebones.bbedit.tcl-source                        | editor |
| com.github.atom            | com.barebones.bbedit.tex-source                        | editor |
| com.github.atom            | com.barebones.bbedit.textile-source                    | editor |
| com.github.atom            | com.barebones.bbedit.vbscript-source                   | editor |
| com.github.atom            | com.barebones.bbedit.vectorscript-source               | editor |
| com.github.atom            | com.barebones.bbedit.verilog-hdl-source                | editor |
| com.github.atom            | com.barebones.bbedit.vhdl-source                       | editor |
| com.github.atom            | com.barebones.bbedit.yaml-source                       | editor |
| com.github.atom            | com.netscape.javascript-source                         | editor |
| com.github.atom            | com.sun.java-source                                    | editor |
| com.github.atom            | dyn.ah62d4rv4ge80255drq                                | all    |
| com.github.atom            | dyn.ah62d4rv4ge80g55gq3w0n                             | all    |
| com.github.atom            | dyn.ah62d4rv4ge80g55sq2                                | all    |
| com.github.atom            | dyn.ah62d4rv4ge80y2xzrf0gk3pw                          | all    |
| com.github.atom            | dyn.ah62d4rv4ge81e3dtqq                                | all    |
| com.github.atom            | dyn.ah62d4rv4ge81e7k                                   | all    |
| com.github.atom            | dyn.ah62d4rv4ge81g25xsq                                | all    |
| com.github.atom            | dyn.ah62d4rv4ge81g2pxsq                                | all    |
| com.github.atom            | net.daringfireball.markdown                            | editor |
| com.github.atom            | public.assembly-source                                 | editor |
| com.github.atom            | public.c-header                                        | editor |
| com.github.atom            | public.c-plus-plus-source                              | editor |
| com.github.atom            | public.c-source                                        | editor |
| com.github.atom            | public.csh-script                                      | editor |
| com.github.atom            | public.json                                            | editor |
| com.github.atom            | public.lex-source                                      | editor |
| com.github.atom            | public.log                                             | editor |
| com.github.atom            | public.mig-source                                      | editor |
| com.github.atom            | public.nasm-assembly-source                            | editor |
| com.github.atom            | public.objective-c-plus-plus-source                    | editor |
| com.github.atom            | public.objective-c-source                              | editor |
| com.github.atom            | public.patch-file                                      | editor |
| com.github.atom            | public.perl-script                                     | editor |
| com.github.atom            | public.php-script                                      | editor |
| com.github.atom            | public.plain-text                                      | editor |
| com.github.atom            | public.precompiled-c-header                            | editor |
| com.github.atom            | public.precompiled-c-plus-plus-header                  | editor |
| com.github.atom            | public.python-script                                   | editor |
| com.github.atom            | public.ruby-script                                     | editor |
| com.github.atom            | public.script                                          | editor |
| com.github.atom            | public.shell-script                                    | editor |
| com.github.atom            | public.source-code                                     | editor |
| com.github.atom            | public.text                                            | editor |
| com.github.atom            | public.utf16-external-plain-text                       | editor |
| com.github.atom            | public.utf16-plain-text                                | editor |
| com.github.atom            | public.utf8-plain-text                                 | editor |
| com.github.atom            | public.xml                                             | editor |
| com.kodlian.Icon-Slate     | com.apple.icns                                         | all    |
| com.kodlian.Icon-Slate     | com.microsoft.ico                                      | all    |
| com.microsoft.Word         | public.rtf                                             | all    |
| com.panayotis.jubler       | dyn.ah62d4rv4ge81g6xy                                  | all    |
| com.sketchup.SketchUp.2017 | com.sketchup.skp                                       | all    |
| com.VortexApps.NZBVortex3  | dyn.ah62d4rv4ge8068xc                                  | all    |
| com.vmware.fusion          | com.microsoft.windows-executable                       | all    |
| cx.c3.theunarchiver        | com.alcohol-soft.mdf-image                             | all    |
| cx.c3.theunarchiver        | com.allume.stuffit-archive                             | all    |
| cx.c3.theunarchiver        | com.altools.alz-archive                                | all    |
| cx.c3.theunarchiver        | com.amiga.adf-archive                                  | all    |
| cx.c3.theunarchiver        | com.amiga.adz-archive                                  | all    |
| cx.c3.theunarchiver        | com.apple.applesingle-archive                          | all    |
| cx.c3.theunarchiver        | com.apple.binhex-archive                               | all    |
| cx.c3.theunarchiver        | com.apple.bom-compressed-cpio                          | all    |
| cx.c3.theunarchiver        | com.apple.itunes.ipa                                   | all    |
| cx.c3.theunarchiver        | com.apple.macbinary-archive                            | all    |
| cx.c3.theunarchiver        | com.apple.self-extracting-archive                      | all    |
| cx.c3.theunarchiver        | com.apple.xar-archive                                  | all    |
| cx.c3.theunarchiver        | com.apple.xip-archive                                  | all    |
| cx.c3.theunarchiver        | com.cyclos.cpt-archive                                 | all    |
| cx.c3.theunarchiver        | com.microsoft.cab-archive                              | all    |
| cx.c3.theunarchiver        | com.microsoft.msi-installer                            | all    |
| cx.c3.theunarchiver        | com.nero.nrg-image                                     | all    |
| cx.c3.theunarchiver        | com.network172.pit-archive                             | all    |
| cx.c3.theunarchiver        | com.nowsoftware.now-archive                            | all    |
| cx.c3.theunarchiver        | com.nscripter.nsa-archive                              | all    |
| cx.c3.theunarchiver        | com.padus.cdi-image                                    | all    |
| cx.c3.theunarchiver        | com.pkware.zip-archive                                 | all    |
| cx.c3.theunarchiver        | com.rarlab.rar-archive                                 | all    |
| cx.c3.theunarchiver        | com.redhat.rpm-archive                                 | all    |
| cx.c3.theunarchiver        | com.stuffit.archive.sit                                | all    |
| cx.c3.theunarchiver        | com.stuffit.archive.sitx                               | all    |
| cx.c3.theunarchiver        | com.sun.java-archive                                   | all    |
| cx.c3.theunarchiver        | com.symantec.dd-archive                                | all    |
| cx.c3.theunarchiver        | com.winace.ace-archive                                 | all    |
| cx.c3.theunarchiver        | com.winzip.zipx-archive                                | all    |
| cx.c3.theunarchiver        | cx.c3.arc-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.arj-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.dcs-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.dms-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.ha-archive                                       | all    |
| cx.c3.theunarchiver        | cx.c3.lbr-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.lha-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.lhf-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.lzx-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.packdev-archive                                  | all    |
| cx.c3.theunarchiver        | cx.c3.pax-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.pma-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.pp-archive                                       | all    |
| cx.c3.theunarchiver        | cx.c3.xmash-archive                                    | all    |
| cx.c3.theunarchiver        | cx.c3.zoo-archive                                      | all    |
| cx.c3.theunarchiver        | cx.c3.zoom-archive                                     | all    |
| cx.c3.theunarchiver        | org.7-zip.7-zip-archive                                | all    |
| cx.c3.theunarchiver        | org.archive.warc-archive                               | all    |
| cx.c3.theunarchiver        | org.debian.deb-archive                                 | all    |
| cx.c3.theunarchiver        | org.gnu.gnu-tar-archive                                | all    |
| cx.c3.theunarchiver        | org.gnu.gnu-zip-archive                                | all    |
| cx.c3.theunarchiver        | org.gnu.gnu-zip-tar-archive                            | all    |
| cx.c3.theunarchiver        | org.tukaani.lzma-archive                               | all    |
| cx.c3.theunarchiver        | org.tukaani.xz-archive                                 | all    |
| cx.c3.theunarchiver        | public.bzip2-archive                                   | all    |
| cx.c3.theunarchiver        | public.cpio-archive                                    | all    |
| cx.c3.theunarchiver        | public.tar-archive                                     | all    |
| cx.c3.theunarchiver        | public.tar-bzip2-archive                               | all    |
| cx.c3.theunarchiver        | public.z-archive                                       | all    |
| cx.c3.theunarchiver        | public.zip-archive                                     | all    |
| cx.c3.theunarchiver        | public.zip-archive.first-part                          | all    |
| org.gnu.Emacs              | dyn.ah62d4rv4ge8086xh                                  | all    |
| org.inkscape.Inkscape      | public.svg-image                                       | editor |
| org.videolan.vlc           | com.apple.m4v-video                                    | all    |
| org.videolan.vlc           | com.microsoft.windows-media-wmv                        | all    |
| org.videolan.vlc           | org.videolan.3gp                                       | all    |
| org.videolan.vlc           | org.videolan.aac                                       | all    |
| org.videolan.vlc           | org.videolan.ac3                                       | all    |
| org.videolan.vlc           | org.videolan.aiff                                      | all    |
| org.videolan.vlc           | org.videolan.amr                                       | all    |
| org.videolan.vlc           | org.videolan.aob                                       | all    |
| org.videolan.vlc           | org.videolan.ape                                       | all    |
| org.videolan.vlc           | org.videolan.asf                                       | all    |
| org.videolan.vlc           | org.videolan.avi                                       | all    |
| org.videolan.vlc           | org.videolan.axa                                       | all    |
| org.videolan.vlc           | org.videolan.axv                                       | all    |
| org.videolan.vlc           | org.videolan.divx                                      | all    |
| org.videolan.vlc           | org.videolan.dts                                       | all    |
| org.videolan.vlc           | org.videolan.dv                                        | all    |
| org.videolan.vlc           | org.videolan.flac                                      | all    |
| org.videolan.vlc           | org.videolan.flash                                     | all    |
| org.videolan.vlc           | org.videolan.gxf                                       | all    |
| org.videolan.vlc           | org.videolan.it                                        | all    |
| org.videolan.vlc           | org.videolan.mid                                       | all    |
| org.videolan.vlc           | org.videolan.mka                                       | all    |
| org.videolan.vlc           | org.videolan.mkv                                       | all    |
| org.videolan.vlc           | org.videolan.mlp                                       | all    |
| org.videolan.vlc           | org.videolan.mod                                       | all    |
| org.videolan.vlc           | org.videolan.mpc                                       | all    |
| org.videolan.vlc           | org.videolan.mpeg-audio                                | all    |
| org.videolan.vlc           | org.videolan.mpeg-stream                               | all    |
| org.videolan.vlc           | org.videolan.mpeg-video                                | all    |
| org.videolan.vlc           | org.videolan.mxf                                       | all    |
| org.videolan.vlc           | org.videolan.nsv                                       | all    |
| org.videolan.vlc           | org.videolan.nuv                                       | all    |
| org.videolan.vlc           | org.videolan.ogg-audio                                 | all    |
| org.videolan.vlc           | org.videolan.ogg-video                                 | all    |
| org.videolan.vlc           | org.videolan.oma                                       | all    |
| org.videolan.vlc           | org.videolan.opus                                      | all    |
| org.videolan.vlc           | org.videolan.quicktime                                 | all    |
| org.videolan.vlc           | org.videolan.realmedia                                 | all    |
| org.videolan.vlc           | org.videolan.rec                                       | all    |
| org.videolan.vlc           | org.videolan.rmi                                       | all    |
| org.videolan.vlc           | org.videolan.s3m                                       | all    |
| org.videolan.vlc           | org.videolan.spx                                       | all    |
| org.videolan.vlc           | org.videolan.tod                                       | all    |
| org.videolan.vlc           | org.videolan.tta                                       | all    |
| org.videolan.vlc           | org.videolan.vob                                       | all    |
| org.videolan.vlc           | org.videolan.voc                                       | all    |
| org.videolan.vlc           | org.videolan.vqf                                       | all    |
| org.videolan.vlc           | org.videolan.vro                                       | all    |
| org.videolan.vlc           | org.videolan.wav                                       | all    |
| org.videolan.vlc           | org.videolan.webm                                      | all    |
| org.videolan.vlc           | org.videolan.wma                                       | all    |
| org.videolan.vlc           | org.videolan.wmv                                       | all    |
| org.videolan.vlc           | org.videolan.wtv                                       | all    |
| org.videolan.vlc           | org.videolan.wv                                        | all    |
| org.videolan.vlc           | org.videolan.xa                                        | all    |
| org.videolan.vlc           | org.videolan.xesc                                      | all    |
| org.videolan.vlc           | org.videolan.xm                                        | all    |
| org.videolan.vlc           | public.ac3-audio                                       | all    |
| org.videolan.vlc           | public.audiovisual-content                             | all    |
| org.videolan.vlc           | public.avi                                             | all    |
| org.videolan.vlc           | public.movie                                           | all    |
| org.videolan.vlc           | public.mpeg                                            | all    |
| org.videolan.vlc           | public.mpeg-2-video                                    | all    |
| org.videolan.vlc           | public.mpeg-4                                          | all    |
|----------------------------+--------------------------------------------------------+--------|

*** Customize Emacs
#+begin_src sh
custom_emacs () {
  mkdir -p "${HOME}/.emacs.d" && \
  curl --compressed --location --silent \
    "https://github.com/syl20bnr/spacemacs/archive/master.tar.gz" | \
  tar -C "${HOME}/.emacs.d" --strip-components 1 -xf -
  mkdir -p "${HOME}/.emacs.d/private/ptb"
  chmod -R go= "${HOME}/.emacs.d"

  cat << EOF > "${HOME}/.spacemacs"
<<.spacemacs>>
EOF

  cat << EOF > "${HOME}/.emacs.d/private/ptb/config.el"
<<config.el>>
EOF

  cat << EOF > "${HOME}/.emacs.d/private/ptb/funcs.el"
<<funcs.el>>
EOF

  cat << EOF > "${HOME}/.emacs.d/private/ptb/keybindings.el"
<<keybindings.el>>
EOF

  cat << EOF > "${HOME}/.emacs.d/private/ptb/packages.el"
<<packages.el>>
EOF
}
#+end_src

**** =~/.spacemacs=
#+begin_src emacs-lisp :noweb-ref .spacemacs
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
#+end_src

**** =~/.emacs.d/private/ptb/config.el=
#+begin_src emacs-lisp :noweb-ref config.el
(setq
  default-frame-alist '(
    (top . 22)
    (left . 1201)
    (height . 50)
    (width . 120)
    (vertical-scroll-bars . right))
  initial-frame-alist (copy-alist default-frame-alist)

  deft-directory "~/Dropbox/Notes"
  focus-follows-mouse t
  mouse-wheel-follow-mouse t
  mouse-wheel-scroll-amount '(1 ((shift) . 1))
  org-src-preserve-indentation t
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
#+end_src

**** =~/.emacs.d/private/ptb/funcs.el=
#+begin_src emacs-lisp :noweb-ref funcs.el
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
#+end_src

**** =~/.emacs.d/private/ptb/keybindings.el=
#+begin_src emacs-lisp :noweb-ref keybindings.el
(define-key evil-insert-state-map (kbd "<return>") 'newline)

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
(global-set-key (kbd "s-w") 'ptb/kill-current-buffer)
(global-set-key (kbd "s-{") 'ptb/previous-buffer)
(global-set-key (kbd "s-}") 'ptb/next-buffer)
#+end_src

**** =~/.emacs.d/private/ptb/packages.el=
#+begin_src emacs-lisp :noweb-ref packages.el
(setq ptb-packages '(adaptive-wrap auto-indent-mode))

(defun ptb/init-adaptive-wrap ()
  "Load the adaptive wrap package"
  (use-package adaptive-wrap
    :init
    (setq adaptive-wrap-extra-indent 2)
    :config
    (progn
      ;; http://stackoverflow.com/questions/13559061
      (when (fboundp 'adaptive-wrap-prefix-mode)
        (defun ptb/activate-adaptive-wrap-prefix-mode ()
          "Toggle 'visual-line-mode' and 'adaptive-wrap-prefix-mode' simultaneously."
          (adaptive-wrap-prefix-mode (if visual-line-mode 1 -1)))
        (add-hook 'visual-line-mode-hook 'ptb/activate-adaptive-wrap-prefix-mode)))))

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
#+end_src

*** Customize Finder
#+begin_src sh :var _finder=_finder[3:-2,1:5]

custom_finder () {
  config_defaults "${_finder}"
  defaults write "com.apple.finder" "NSToolbar Configuration Browser" \
    '{
      "TB Display Mode" = 2;
      "TB Item Identifiers" = (
        "com.apple.finder.BACK",
        "com.apple.finder.PATH",
        "com.apple.finder.SWCH",
        "com.apple.finder.ARNG",
        "NSToolbarFlexibleSpaceItem",
        "com.apple.finder.SRCH",
        "com.apple.finder.ACTN"
      );
    }'
}
#+end_src

**** _finder
#+name: _finder
|----------------------------------------------------------------+------------------+--------------------------------------+---------+-------------------------+------|
| Preference                                                     | Domain           | Key                                  | Type    | Value                   | Host |
|----------------------------------------------------------------+------------------+--------------------------------------+---------+-------------------------+------|
| *Show these items on the desktop:* ~off~ *Hard disks*          | com.apple.finder | ShowHardDrivesOnDesktop              | -bool   | false                   |      |
| *Show these items on the desktop:* ~off~ *External disks*      | com.apple.finder | ShowExternalHardDrivesOnDesktop      | -bool   | false                   |      |
| *Show these items on the desktop:* ~on~ *CDs, DVDs, and iPods* | com.apple.finder | ShowRemovableMediaOnDesktop          | -bool   | true                    |      |
| *Show these items on the desktop:* ~on~ *Connected servers:*   | com.apple.finder | ShowMountedServersOnDesktop          | -bool   | true                    |      |
| *New Finder windows show:* ~${HOME}~                           | com.apple.finder | NewWindowTarget                      | -string | PfLo                    |      |
|                                                                | com.apple.finder | NewWindowTargetPath                  | -string | file://${HOME}/Dropbox/ |      |
| ~on~ *Show all filename extensions*                            | -globalDomain    | AppleShowAllExtensions               | -bool   | true                    |      |
| ~off~ *Show warning before changing an extension*              | com.apple.finder | FXEnableExtensionChangeWarning       | -bool   | false                   |      |
| ~on~ *Show warning before removing from iCloud Drive*          | com.apple.finder | FXEnableRemoveFromICloudDriveWarning | -bool   | true                    |      |
| ~off~ *Show warning before emptying the Trash*                 | com.apple.finder | WarnOnEmptyTrash                     | -bool   | false                   |      |
| *View* ▶ *Show Path Bar*                                       | com.apple.finder | ShowPathbar                          | -bool   | true                    |      |
| *View* ▶ *Show Status Bar*                                     | com.apple.finder | ShowStatusBar                        | -bool   | true                    |      |
|----------------------------------------------------------------+------------------+--------------------------------------+---------+-------------------------+------|

*** Customize getmail
#+begin_src sh :var _getmail_ini=_getmail_ini[3:-2,0:2] _getmail_plist=_getmail_plist[3:-2,0:3]
custom_getmail () {
  test -d "${HOME}/.getmail" || \
    mkdir -m go= "${HOME}/.getmail"

  while true; do
    e=$(ask2 "To configure getmail, enter your email address." "Configure Getmail" "No More Addresses" "Create Configuration" "$(whoami)@$(hostname -f | cut -d. -f2-)" "false")
    test -n "$e" || break

    security find-internet-password -a "$e" -D "getmail password" > /dev/null || \
    p=$(ask2 "Enter your password for $e." "Configure Getmail" "Cancel" "Set Password" "" "true") && \
    security add-internet-password -a "$e" -s "imap.gmail.com" -r "imap" \
      -l "$e" -D "getmail password" -P 993 -w "$p"

    if which crudini > /dev/null; then
      gm="${HOME}/.getmail/${e}"
      printf "%s\n" "${_getmail_ini}" | \
      while IFS="$(printf '\t')" read section key value; do
        crudini --set "$gm" "$section" "$key" "$value"
      done
      crudini --set "$gm" "destination" "arguments" "('-c','/usr/local/etc/dovecot/dovecot.conf','-d','$(whoami)')"
      crudini --set "$gm" "destination" "path" "$(find '/usr/local/Cellar/dovecot' -name 'dovecot-lda' -print -quit)"
      crudini --set "$gm" "retriever" "username" "$e"
    fi

    la="${HOME}/Library/LaunchAgents/ca.pyropus.getmail.${e}"

    test -d "$(dirname $la)" || \
      mkdir -p "$(dirname $la)"
    launchctl unload "${la}.plist" 2> /dev/null
    rm -f "${la}.plist"

    config_plist "$_getmail_plist" "${la}.plist"
    config_defaults "$(printf "${la}\tLabel\t-string\tca.pyropus.getmail.${e}\t")"
    config_defaults "$(printf "${la}\tProgramArguments\t-array-add\t${e}\t")"
    config_defaults "$(printf "${la}\tWorkingDirectory\t-string\t${HOME}/.getmail\t")"

    plutil -convert xml1 "${la}.plist"
    launchctl load "${la}.plist" 2> /dev/null
  done
}
#+end_src

**** _getmail_ini
#+name: _getmail_ini
|-------------+----------------+------------------------|
| Section     | Key            | Value                  |
|-------------+----------------+------------------------|
| destination | ignore_stderr  | true                   |
| destination | type           | MDA_external           |
| options     | delete         | true                   |
| options     | delivered_to   | false                  |
| options     | read_all       | false                  |
| options     | received       | false                  |
| options     | verbose        | 0                      |
| retriever   | mailboxes      | ("[Gmail]/All Mail",)  |
| retriever   | move_on_delete | "[Gmail]/Trash"        |
| retriever   | port           | 993                    |
| retriever   | server         | imap.gmail.com         |
| retriever   | type           | SimpleIMAPSSLRetriever |
|-------------+----------------+------------------------|

**** _getmail_plist
#+name: _getmail_plist
|---------+---------------------+---------+------------------------|
| Command | Entry               | Type    | Value                  |
|---------+---------------------+---------+------------------------|
| add     | :KeepAlive          | bool    | true                   |
| add     | :ProcessType        | string  | Background             |
| add     | :ProgramArguments   | array   |                        |
| add     | :ProgramArguments:0 | string  | /usr/local/bin/getmail |
| add     | :ProgramArguments:1 | string  | --idle                 |
| add     | :ProgramArguments:2 | string  | [Gmail]/All Mail       |
| add     | :ProgramArguments:3 | string  | --rcfile               |
| add     | :RunAtLoad          | bool    | true                   |
| add     | :StandardOutPath    | string  | getmail.log            |
| add     | :StandardErrorPath  | string  | getmail.err            |
|---------+---------------------+---------+------------------------|

*** Customize Git
#+begin_src sh
custom_git () {
  if ! test -e "${HOME}/.gitconfig"; then
    true
  fi
}
#+end_src

*** Customize GnuPG
#+begin_src sh
custom_gnupg () {
  if ! test -d "${HOME}/.gnupg"; then
    true
  fi
}
#+end_src

*** Customize iStat Menus
#+begin_src sh :var _istatmenus=_istatmenus[3:-2,1:5]

custom_istatmenus () {
  defaults delete com.bjango.istatmenus5.extras Time_MenubarFormat > /dev/null 2>&1
  defaults delete com.bjango.istatmenus5.extras Time_DropdownFormat > /dev/null 2>&1
  defaults delete com.bjango.istatmenus5.extras Time_Cities > /dev/null 2>&1
  config_defaults "${_istatmenus}"
}
#+end_src

**** _istatmenus
#+name: _istatmenus
|------------+-------------------------------+------------------------------------------+------------+---------------------+------|
| Preference | Domain                        | Key                                      | Type       | Value               | Host |
|------------+-------------------------------+------------------------------------------+------------+---------------------+------|
|            | com.bjango.istatmenus5.extras | MenubarSkinColor                         | -int       | 8                   |      |
|            | com.bjango.istatmenus5.extras | MenubarTheme                             | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | DropdownTheme                            | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarMode                          | -string    | 100,2,0             |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarTextSize                      | -int       | 14                  |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarGraphShowBackground           | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarGraphWidth                    | -int       | 32                  |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarGraphBreakdowns               | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarGraphCustomColors             | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarGraphOverall                  | -string    | 0.40 0.60 0.40 1.00 |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarCombineCores                  | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarGroupItems                    | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | CPU_MenubarSingleHistoryGraph            | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | CPU_CombineLogicalCores                  | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | CPU_AppFormat                            | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Memory_MenubarMode                       | -string    | 100,2,6             |      |
|            | com.bjango.istatmenus5.extras | Memory_MenubarPercentageSize             | -int       | 14                  |      |
|            | com.bjango.istatmenus5.extras | Memory_MenubarGraphBreakdowns            | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | Memory_MenubarGraphCustomColors          | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Memory_MenubarGraphOverall               | -string    | 0.40 0.60 0.40 1.00 |      |
|            | com.bjango.istatmenus5.extras | Memory_MenubarGraphWired                 | -string    | 0.40 0.60 0.40 1.00 |      |
|            | com.bjango.istatmenus5.extras | Memory_MenubarGraphActive                | -string    | 0.47 0.67 0.47 1.00 |      |
|            | com.bjango.istatmenus5.extras | Memory_MenubarGraphCompressed            | -string    | 0.53 0.73 0.53 1.00 |      |
|            | com.bjango.istatmenus5.extras | Memory_MenubarGraphInactive              | -string    | 0.60 0.80 0.60 1.00 |      |
|            | com.bjango.istatmenus5.extras | Memory_IgnoreInactive                    | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Memory_AppFormat                         | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Memory_DisplayFormat                     | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | Disks_MenubarMode                        | -string    | 100,9,8             |      |
|            | com.bjango.istatmenus5.extras | Disks_MenubarGroupItems                  | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | Disks_MenubarRWShowLabel                 | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | Disks_MenubarRWBold                      | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Disks_MenubarGraphActivityWidth          | -int       | 32                  |      |
|            | com.bjango.istatmenus5.extras | Disks_MenubarGraphActivityShowBackground | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Disks_MenubarGraphActivityCustomColors   | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Disks_MenubarGraphActivityRead           | -string    | 0.60 0.80 0.60 1.00 |      |
|            | com.bjango.istatmenus5.extras | Disks_MenubarGraphActivityWrite          | -string    | 0.40 0.60 0.40 1.00 |      |
|            | com.bjango.istatmenus5.extras | Disks_SeperateFusion                     | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | Network_MenubarMode                      | -string    | 4,0,1               |      |
|            | com.bjango.istatmenus5.extras | Network_TextUploadColor-Dark             | -string    | 1.00 1.00 1.00 1.00 |      |
|            | com.bjango.istatmenus5.extras | Network_TextDownloadColor-Dark           | -string    | 1.00 1.00 1.00 1.00 |      |
|            | com.bjango.istatmenus5.extras | Network_GraphWidth                       | -int       | 32                  |      |
|            | com.bjango.istatmenus5.extras | Network_GraphShowBackground              | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Network_GraphCustomColors                | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Network_GraphUpload                      | -string    | 0.60 0.80 0.60 1.00 |      |
|            | com.bjango.istatmenus5.extras | Network_GraphDownload                    | -string    | 0.40 0.60 0.40 1.00 |      |
|            | com.bjango.istatmenus5.extras | Network_GraphMode                        | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | Battery_MenubarMode                      | -string    | 5,0                 |      |
|            | com.bjango.istatmenus5.extras | Battery_ColorGraphCustomColors           | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | Battery_ColorGraphCharged                | -string    | 0.40 0.60 0.40 1.00 |      |
|            | com.bjango.istatmenus5.extras | Battery_ColorGraphCharging               | -string    | 0.60 0.80 0.60 1.00 |      |
|            | com.bjango.istatmenus5.extras | Battery_ColorGraphDraining               | -string    | 1.00 0.60 0.60 1.00 |      |
|            | com.bjango.istatmenus5.extras | Battery_ColorGraphLow                    | -string    | 1.00 0.20 0.20 1.00 |      |
|            | com.bjango.istatmenus5.extras | Battery_PercentageSize                   | -int       | 14                  |      |
|            | com.bjango.istatmenus5.extras | Battery_MenubarCustomizeStates           | -int       | 0                   |      |
|            | com.bjango.istatmenus5.extras | Battery_MenubarHideBluetooth             | -int       | 1                   |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | EE                  |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | \\040               |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | MMM                 |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | \\040               |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | d                   |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | \\040               |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | h                   |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | :                   |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | mm                  |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | :                   |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | ss                  |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | \\040               |      |
|            | com.bjango.istatmenus5.extras | Time_MenubarFormat                       | -array-add | a                   |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | EE                  |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | \\040               |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | h                   |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | :                   |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | mm                  |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | \\040               |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | a                   |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | \\040\\050          |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | zzz                 |      |
|            | com.bjango.istatmenus5.extras | Time_DropdownFormat                      | -array-add | \\051               |      |
|            | com.bjango.istatmenus5.extras | Time_Cities                              | -array-add | 4930956             |      |
|            | com.bjango.istatmenus5.extras | Time_Cities                              | -array-add | 4887398             |      |
|            | com.bjango.istatmenus5.extras | Time_Cities                              | -array-add | 5419384             |      |
|            | com.bjango.istatmenus5.extras | Time_Cities                              | -array-add | 5392171             |      |
|            | com.bjango.istatmenus5.extras | Time_Cities                              | -array-add | 5879400             |      |
|            | com.bjango.istatmenus5.extras | Time_Cities                              | -array-add | 5856195             |      |
|            | com.bjango.istatmenus5.extras | Time_TextSize                            | -int       | 14                  |      |
|------------+-------------------------------+------------------------------------------+------------+---------------------+------|

*** Customize Meteorologist
#+begin_src sh :var _meteorologist=_meteorologist[3:-2,1:5]

custom_meteorologist () {
  config_defaults "${_meteorologist}"
}
#+end_src

**** _meteorologist
#+name: _meteorologist
|------------+------------------------+----------------------------+---------+-------+------|
| Preference | Domain                 | Key                        | Type    | Value | Host |
|------------+------------------------+----------------------------+---------+-------+------|
|            | com.heat.meteorologist | controlsInSubmenu          | -string |     0 |      |
|            | com.heat.meteorologist | currentWeatherInSubmenu    | -string |     0 |      |
|            | com.heat.meteorologist | displayCityName            | -string |     0 |      |
|            | com.heat.meteorologist | displayHumidity            | -string |     0 |      |
|            | com.heat.meteorologist | displayWeatherIcon         | -string |     1 |      |
|            | com.heat.meteorologist | extendedForecastIcons      | -string |     1 |      |
|            | com.heat.meteorologist | extendedForecastInSubmenu  | -string |     0 |      |
|            | com.heat.meteorologist | extendedForecastSingleLine | -string |     1 |      |
|            | com.heat.meteorologist | forecastDays               | -int    |     8 |      |
|            | com.heat.meteorologist | viewExtendedForecast       | -string |     1 |      |
|            | com.heat.meteorologist | weatherSource_1            | -int    |     3 |      |
|------------+------------------------+----------------------------+---------+-------+------|

*** Customize Moom
#+begin_src sh :var _moom=_moom[3:-2,1:5]

custom_moom () {
  killall Moom > /dev/null 2>&1
  defaults delete com.manytricks.Moom "Custom Controls" > /dev/null 2>&1
  config_defaults "${_moom}"
  test -d "/Applications/Moom.app" && \
    open "/Applications/Moom.app"
}
#+end_src

**** _moom
#+name: _moom
|------------------------------------------------------------------------+---------------------+-------------------------------------------------------+------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------|
| Preference                                                             | Domain              | Key                                                   | Type       | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Host |
|------------------------------------------------------------------------+---------------------+-------------------------------------------------------+------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------|
| ~on~ *Treat drawers as part of their parent windows*                   | com.manytricks.Moom | Allow For Drawers                                     | -bool      | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
| ~on~ *Separate windows by* ~2~ *pt*                                    | com.manytricks.Moom | Grid Spacing                                          | -bool      | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
|                                                                        | com.manytricks.Moom | Grid Spacing: Gap                                     | -int       | 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |      |
| ~off~ *Apply to screen edges*                                          | com.manytricks.Moom | Grid Spacing: Apply To Edges                          | -bool      | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |      |
| *Grid/keyboard control highlight:* ~25%~                               | com.manytricks.Moom | Target Window Highlight                               | -float     | 0.25                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
| ~off~ *Show preferences on launch*                                     | com.manytricks.Moom | Stealth Mode                                          | -bool      | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
| *Run as* ~faceless~ *application*                                      | com.manytricks.Moom | Application Mode                                      | -int       | 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |      |
| ~on~ *Pop up controls when hovering over a Zoom button*                | com.manytricks.Moom | Mouse Controls                                        | -bool      | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
| *Delay:* ~0.1~ *second*                                                | com.manytricks.Moom | Mouse Controls Delay                                  | -float     | 0.1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |      |
| ~on~ *Enable* ~hexagon~ *grid with* ~16~ *×* ~9~ *cells*               | com.manytricks.Moom | Mouse Controls Grid                                   | -bool      | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
|                                                                        | com.manytricks.Moom | Mouse Controls Grid: Mode                             | -int       | 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |      |
|                                                                        | com.manytricks.Moom | Mouse Controls Grid: Columns                          | -int       | 16                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |      |
|                                                                        | com.manytricks.Moom | Mouse Controls Grid: Rows                             | -int       | 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |      |
| ~on~ *Enable access to custom controls*                                | com.manytricks.Moom | Mouse Controls Include Custom Controls                | -bool      | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
| ~off~ *Show on hover*                                                  | com.manytricks.Moom | Mouse Controls Include Custom Controls: Show On Hover | -bool      | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |      |
| ~on~ *Bring moomed windows to the front automatically*                 | com.manytricks.Moom | Mouse Controls Auto-Activate Window                   | -bool      | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
| ~off~ *Move & Zoom when dragging a window to a display edge or corner* | com.manytricks.Moom | Snap                                                  | -bool      | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |      |
| ~Move & Zoom~                                                          | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 19; "Relative Frame" = "{{0, 0.5}, {0.375, 0.5}}"; }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |      |
|                                                                        | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 19; "Relative Frame" = "{{0, 0}, {0.375, 0.5}}"; }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |      |
|                                                                        | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 19; "Relative Frame" = "{{0, 0}, {0.375, 1}}"; }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |      |
|                                                                        | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 19; "Relative Frame" = "{{0.125, 0}, {0.25, 0.33333}}"; }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
|                                                                        | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 19; "Relative Frame" = "{{0.375, 0.33333}, {0.3125, 0.66666}}"; }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |      |
|                                                                        | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 19; "Relative Frame" = "{{0.375, 0}, {0.3125, 0.33333}}"; }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |      |
|                                                                        | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 19; "Relative Frame" = "{{0.6875, 0.66666}, {0.3125, 0.66666}}"; }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |      |
|                                                                        | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 19; "Relative Frame" = "{{0.6875, 0.33333}, {0.3125, 0.33333}}"; }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |      |
|                                                                        | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 19; "Relative Frame" = "{{0.6875, 0}, {0.3125, 0.33333}}"; }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |      |
|                                                                        | com.manytricks.Moom | Custom Controls                                       | -array-add | { Action = 1001; "Apply to Overlapping Windows" = 1; Snapshot = ({ "Application Name" = Safari; "Bundle Identifier" = "com.apple.safari"; "Window Frame" = "{{0, 890}, {1199, 888}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = Chrome; "Bundle Identifier" = "com.google.chrome"; "Window Frame" = "{{0, 0}, {1199, 888}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = Firefox; "Bundle Identifier" = "org.mozilla.firefox"; "Window Frame" = "{{0, 0}, {1199, 888}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = Emacs; "Bundle Identifier" = "org.gnu.emacs"; "Window Frame" = "{{1201, 597}, {991, 1181}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = Code; "Bundle Identifier" = "com.microsoft.vscode"; "Window Frame" = "{{1201, 594}, {1999, 1184}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = Mail; "Bundle Identifier" = "com.apple.mail"; "Window Frame" = "{{2201, 594}, {999, 1184}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = nvALT; "Bundle Identifier" = "net.elasticthreads.nv"; "Window Frame" = "{{2201, 989}, {999, 789}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = SimpleNote; "Bundle Identifier" = "bogdanf.osx.metanota.pro"; "Window Frame" = "{{2201, 989}, {999, 789}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = Finder; "Bundle Identifier" = "com.apple.finder"; "Window Frame" = "{{2401, 1186}, {799, 592}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = Messages; "Bundle Identifier" = "com.apple.ichat"; "Window Frame" = "{{401, 0}, {798, 591}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = Slack; "Bundle Identifier" = "com.tinyspeck.slackmacgap"; "Window Frame" = "{{0, 0}, {999, 591}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = Terminal; "Bundle Identifier" = "com.apple.terminal"; "Window Frame" = "{{1201, 20}, {993, 572}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = iTerm2; "Bundle Identifier" = "com.googlecode.iterm2"; "Window Frame" = "{{1201, 17}, {993, 572}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = QuickTime; "Bundle Identifier" = "com.apple.quicktimeplayerx"; "Window Frame" = "{{2201, 0}, {999, 592}}"; "Window Subrole" = AXStandardWindow; }, { "Application Name" = VLC; "Bundle Identifier" = "org.videolan.vlc"; "Window Frame" = "{{2201, 0}, {999, 592}}"; "Window Subrole" = AXStandardWindow; }); "Snapshot Screens" = ( "{{0, 0}, {3200, 1800}}" ); } |      |
| *Define window sizes using* ~16~ *×* ~9~ *cells*                       | com.manytricks.Moom | Configuration Grid: Columns                           | -int       | 16                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |      |
|                                                                        | com.manytricks.Moom | Configuration Grid: Rows                              | -int       | 9                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |      |
| ~on~ *Check for updates automatically*                                 | com.manytricks.Moom | SUEnableAutomaticChecks                               | -bool      | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |      |
|------------------------------------------------------------------------+---------------------+-------------------------------------------------------+------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------|


*** Customize MP4 Automator
#+begin_src sh :var _mp4_automator=_mp4_automator[3:-2,1:3]

custom_mp4_automator () {
  mkdir -p "${HOME}/.config/mp4_automator" && \
  curl --compressed --location --silent \
    "https://github.com/mdhiggins/sickbeard_mp4_automator/archive/master.tar.gz" | \
  tar -C "${HOME}/.config/mp4_automator" --strip-components 1 -xf -
  printf "%s\n" "2.7.13" > "${HOME}/.config/mp4_automator/.python-version"

  if which crudini > /dev/null; then
    printf "%s\n" "${_mp4_automator}" | \
    while IFS="$(printf '\t')" read section key value; do
      crudini --set "${HOME}/.config/mp4_automator/autoProcess.ini" "${section}" "${key}" "${value}"
    done

    open "http://localhost:7878/settings/general"
    RADARRAPI="$(ask 'Radarr API Key?' 'Set API Key' '')"
    crudini --set "${HOME}/.config/mp4_automator/autoProcess.ini" "Radarr" "apikey" "$RADARRAPI"

    open "http://localhost:8989/settings/general"
    SONARRAPI="$(ask 'Sonarr API Key?' 'Set API Key' '')"
    crudini --set "${HOME}/.config/mp4_automator/autoProcess.ini" "Sonarr" "apikey" "$SONARRAPI"
  fi

  find "${HOME}/.config/mp4_automator" -name "*.py" -print0 | \
    xargs -0 -L 1 sed -i "" -e "s:/usr/bin/env python:/usr/local/python/versions/2.7.13/bin/python:"
}
#+end_src

**** _mp4_automator
#+name: _mp4_automator
|------------+---------+------------------------------+-------------------------------------------|
| Preference | Section | Key                          | Value                                     |
|------------+---------+------------------------------+-------------------------------------------|
|            | MP4     | aac_adtstoasc                | True                                      |
|            | MP4     | audio-channel-bitrate        | 256                                       |
|            | MP4     | audio-codec                  | ac3,aac                                   |
|            | MP4     | audio-default-language       | eng                                       |
|            | MP4     | audio-filter                 |                                           |
|            | MP4     | audio-language               | eng                                       |
|            | MP4     | convert-mp4                  | True                                      |
|            | MP4     | copy_to                      |                                           |
|            | MP4     | delete_original              | False                                     |
|            | MP4     | download-artwork             | Poster                                    |
|            | MP4     | download-subs                | True                                      |
|            | MP4     | embed-subs                   | True                                      |
|            | MP4     | ffmpeg                       | /usr/local/bin/ffmpeg                     |
|            | MP4     | ffprobe                      | /usr/local/bin/ffprobe                    |
|            | MP4     | fullpathguess                | True                                      |
|            | MP4     | h264-max-level               | 4.1                                       |
|            | MP4     | ios-audio                    | True                                      |
|            | MP4     | ios-audio-filter             |                                           |
|            | MP4     | ios-first-track-only         | True                                      |
|            | MP4     | max-audio-channels           |                                           |
|            | MP4     | move_to                      |                                           |
|            | MP4     | output_directory             |                                           |
|            | MP4     | output_extension             | m4v                                       |
|            | MP4     | output_format                | mp4                                       |
|            | MP4     | permissions                  | 0644                                      |
|            | MP4     | pix-fmt                      |                                           |
|            | MP4     | post-process                 | False                                     |
|            | MP4     | postopts                     |                                           |
|            | MP4     | preopts                      |                                           |
|            | MP4     | relocate_moov                | True                                      |
|            | MP4     | sub-providers                | addic7ed,podnapisi,thesubdb,opensubtitles |
|            | MP4     | subtitle-codec               | mov_text                                  |
|            | MP4     | subtitle-default-language    | eng                                       |
|            | MP4     | subtitle-encoding            |                                           |
|            | MP4     | subtitle-language            | eng                                       |
|            | MP4     | tag-language                 | eng                                       |
|            | MP4     | tagfile                      | True                                      |
|            | MP4     | threads                      | auto                                      |
|            | MP4     | use-qsv-decoder-with-encoder | True                                      |
|            | MP4     | video-bitrate                |                                           |
|            | MP4     | video-codec                  | h264,x264                                 |
|            | MP4     | video-crf                    |                                           |
|            | MP4     | video-max-width              | 1920                                      |
|            | Plex    | host                         | localhost                                 |
|            | Plex    | port                         | 32400                                     |
|            | Plex    | refresh                      | False                                     |
|            | Plex    | token                        |                                           |
|            | Radarr  | host                         | localhost                                 |
|            | Radarr  | port                         | 7878                                      |
|            | Radarr  | ssl                          | False                                     |
|            | Radarr  | web_root                     |                                           |
|            | Sonarr  | host                         | localhost                                 |
|            | Sonarr  | port                         | 8989                                      |
|            | Sonarr  | ssl                          | False                                     |
|            | Sonarr  | web_root                     |                                           |
|------------+---------+------------------------------+-------------------------------------------|

*** Customize nvALT
#+begin_src sh :var _nvalt=_nvalt[3:-2,1:5] :var _nvalt_launchd=_nvalt_launchd[3:-2,0:3]

custom_nvalt () {
  config_defaults "$_nvalt"
  config_launchd "${HOME}/Library/LaunchAgents/net.elasticthreads.nv.plist" "$_nvalt_launchd"
}
#+end_src

**** _nvalt
#+name: _nvalt
|----------------------------------------------------------+-----------------------+-----------------------------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------|
| Preference                                               | Domain                | Key                         | Type       | Value                                                                                                                                                                                                                      | Host |
|----------------------------------------------------------+-----------------------+-----------------------------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------|
| *List Text Size:* ~Small~                                | net.elasticthreads.nv | TableFontPointSize          | -int       | 11                                                                                                                                                                                                                         |      |
| *Bring-to-Front Hotkey:* ~(None)~                        | net.elasticthreads.nv | AppActivationKeyCode        | -int       | -1                                                                                                                                                                                                                         |      |
|                                                          | net.elasticthreads.nv | AppActivationModifiers      | -int       | -1                                                                                                                                                                                                                         |      |
| ~on~ *Auto-select notes by title when searching*         | net.elasticthreads.nv | AutoCompleteSearches        | -bool      | true                                                                                                                                                                                                                       |      |
| ~on~ *Confirm note deletion*                             | net.elasticthreads.nv | ConfirmNoteDeletion         | -bool      | true                                                                                                                                                                                                                       |      |
| ~off~ *Quit when closing window*                         | net.elasticthreads.nv | QuitWhenClosingMainWindow   | -bool      | false                                                                                                                                                                                                                      |      |
| ~on~ *Show menu bar icon*                                | net.elasticthreads.nv | StatusBarItem               | -bool      | true                                                                                                                                                                                                                       |      |
| *Hide Dock Icon*                                         | net.elasticthreads.nv | ShowDockIcon                | -bool      | false                                                                                                                                                                                                                      |      |
| *Styled Text:* ~off~ *Copy basic styles from other apps* | net.elasticthreads.nv | PastePreservesStyle         | -bool      | false                                                                                                                                                                                                                      |      |
| *Spelling:* ~off~ *Check as you type*                    | net.elasticthreads.nv | CheckSpellingInNoteBody     | -bool      | false                                                                                                                                                                                                                      |      |
| *Tab Key:* ~Indent lines~                                | net.elasticthreads.nv | TabKeyIndents               | -bool      | true                                                                                                                                                                                                                       |      |
| ~on~ *Soft tabs (spaces)*                                | net.elasticthreads.nv | UseSoftTabs                 | -bool      | true                                                                                                                                                                                                                       |      |
| *Links:* ~on~ *Make URLs clickable links*                | net.elasticthreads.nv | MakeURLsClickable           | -bool      | true                                                                                                                                                                                                                       |      |
| *Links:* ~off~ *Suggest titles for note-links*           | net.elasticthreads.nv | AutoSuggestLinks            | -bool      | false                                                                                                                                                                                                                      |      |
| *URL Import:* ~off~ *Convert imported URLs to Markdown*  | net.elasticthreads.nv | UseMarkdownImport           | -bool      | false                                                                                                                                                                                                                      |      |
| *URL Import:* ~off~ *Process with Readability*           | net.elasticthreads.nv | UseReadability              | -bool      | false                                                                                                                                                                                                                      |      |
| *Direction:* ~off~ *Right-To-Left (RTL)*                 | net.elasticthreads.nv | rtl                         | -bool      | false                                                                                                                                                                                                                      |      |
| *Auto-pair:* ~on~                                        | net.elasticthreads.nv | UseAutoPairing              | -bool      | true                                                                                                                                                                                                                       |      |
| *External Text Editor:* ~Emacs.app~                      | net.elasticthreads.nv | DefaultEEIdentifier         | -string    | org.gnu.Emacs                                                                                                                                                                                                              |      |
|                                                          | net.elasticthreads.nv | UserEEIdentifiers           | -array-add | com.apple.TextEdit                                                                                                                                                                                                         |      |
|                                                          | net.elasticthreads.nv | UserEEIdentifiers           | -array-add | org.gnu.Emacs                                                                                                                                                                                                              |      |
| *Body Font:* ~InconsolataLGC 13~                         | net.elasticthreads.nv | NoteBodyFont                | -data      | 040b73747265616d747970656481e803840140848484064e53466f6e741e8484084e534f626a65637400858401692884055b3430635d060000001e000000fffe49006e0063006f006e0073006f006c006100740061004c004700430000008401660d8401630098019800980086 |      |
| ~on~ *Search Highlight:* ~#CCFFCC~                       | net.elasticthreads.nv | HighlightSearchTerms        | -bool      | true                                                                                                                                                                                                                       |      |
|                                                          | net.elasticthreads.nv | SearchTermHighlightColor    | -data      | 040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a65637400858401630184046666666683cdcc4c3f0183cdcc4c3f0186                                                                                     |      |
| *Foreground Text:* ~#CCCCCC~                             | net.elasticthreads.nv | ForegroundTextColor         | -data      | 040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a65637400858401630184046666666683cdcc4c3f83cdcc4c3f83cdcc4c3f0186                                                                             |      |
| *Background:* ~#1A1A1A~                                  | net.elasticthreads.nv | BackgroundTextColor         | -data      | 040b73747265616d747970656481e803840140848484074e53436f6c6f72008484084e534f626a65637400858401630184046666666683d1d0d03d83d1d0d03d83d1d0d03d0186                                                                             |      |
| *Always Show Grid Lines in Notes List:* ~on~             | net.elasticthreads.nv | ShowGrid                    | -bool      | true                                                                                                                                                                                                                       |      |
| *Alternating Row Colors:* ~on~                           | net.elasticthreads.nv | AlternatingRows             | -bool      | true                                                                                                                                                                                                                       |      |
| *Use nvALT Scrollbars:* ~off~                            | net.elasticthreads.nv | UseETScrollbarsOnLion       | -bool      | false                                                                                                                                                                                                                      |      |
| *Keep Note Body Width Readable:* ~on~                    | net.elasticthreads.nv | KeepsMaxTextWidth           | -bool      | true                                                                                                                                                                                                                       |      |
| *Max. Note Body Width:* ~650~ *pixels*                   | net.elasticthreads.nv | NoteBodyMaxWidth            | -int       | 650                                                                                                                                                                                                                        |      |
| *View* ▶ *Switch to Horizontal Layout*                   | net.elasticthreads.nv | HorizontalLayout            | -bool      | true                                                                                                                                                                                                                       |      |
| *View* ▶ *Columns* ▶ ~✓ Title~ ~✓ Tags~                  | net.elasticthreads.nv | NoteAttributesVisible       | -array-add | Title                                                                                                                                                                                                                      |      |
|                                                          | net.elasticthreads.nv | NoteAttributesVisible       | -array-add | Tags                                                                                                                                                                                                                       |      |
| *View* ▶ *Sort By* ▶︎ ~▼ Date Modified~                   | net.elasticthreads.nv | TableIsReverseSorted        | -bool      | true                                                                                                                                                                                                                       |      |
|                                                          | net.elasticthreads.nv | TableSortColumn             | -string    | Date Modified                                                                                                                                                                                                              |      |
| *View* ▶ *Show Note Previews in Title*                   | net.elasticthreads.nv | TableColumnsHaveBodyPreview | -bool      | true                                                                                                                                                                                                                       |      |
|----------------------------------------------------------+-----------------------+-----------------------------+------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------|

**** _nvalt_launchd
#+name: _nvalt_launchd
|---------+--------------------+--------+----------------------------------------------|
| Command | Entry              | Type   | Value                                        |
|---------+--------------------+--------+----------------------------------------------|
| add     | :KeepAlive         | bool   | true                                         |
| add     | :Label             | string | net.elasticthreads.nv                        |
| add     | :ProcessType       | string | Interactive                                  |
| add     | :Program           | string | /Applications/nvALT.app/Contents/MacOS/nvALT |
| add     | :RunAtLoad         | bool   | true                                         |
|---------+--------------------+--------+----------------------------------------------|

*** Customize NZBGet

- $7.50/mth: http://www.news.astraweb.com/specials/2mospecial.html
- €13/100GB: https://www.tweaknews.eu/en/usenet-plans
- $17/100GB: https://www.newsdemon.com/usenet-access.php
- $20/200GB: https://billing.blocknews.net/signup.php

#+begin_src sh :var _nzbget=_nzbget[3:-2,1:2]

custom_nzbget () {
  f="${HOME}/Library/Application Support/NZBGet/nzbget.conf"
  mkdir -p "$(dirname $f)"
  if which crudini > /dev/null; then
    printf "%s\n" "${_nzbget}" | \
    while IFS="$(printf '\t')" read key value; do
      crudini --set "$f" "" "${key}" "${value}"
    done
  fi
  sed -i "" -e "s/ = /=/g" "$f"
}
#+end_src

**** _nzbget
#+name: _nzbget
|----------------+----------------------+-----------------------|
| Preference     | Key                  |                 Value |
|----------------+----------------------+-----------------------|
| *Security*     | ControlIP            |             127.0.0.1 |
|                | ControlPort          |                  6789 |
|                | AuthorizedIP         |             127.0.0.1 |
| *News-Servers* | Server1.Level        |                     0 |
| *Server1*      | Server1.Host         |      ssl.astraweb.com |
|                | Server1.Port         |                   443 |
|                | Server1.Encryption   |                   yes |
|                | Server1.Connections  |                     6 |
|                | Server1.Retention    |                  3000 |
| *News-Servers* | Server2.Level        |                     0 |
| *Server2*      | Server2.Host         |   ssl-us.astraweb.com |
|                | Server2.Port         |                   443 |
|                | Server2.Encryption   |                   yes |
|                | Server2.Connections  |                     6 |
|                | Server2.Retention    |                  3000 |
| *News-Servers* | Server3.Level        |                     0 |
| *Server3*      | Server3.Host         |   ssl-eu.astraweb.com |
|                | Server3.Port         |                   443 |
|                | Server3.Encryption   |                   yes |
|                | Server3.Connections  |                     6 |
|                | Server3.Retention    |                  3000 |
| *News-Servers* | Server4.Level        |                     1 |
| *Server4*      | Server4.Host         |     news.tweaknews.eu |
|                | Server4.Port         |                   443 |
|                | Server4.Encryption   |                   yes |
|                | Server4.Connections  |                    40 |
|                | Server4.Retention    |                  2500 |
| *News-Servers* | Server5.Level        |                     2 |
| *Server5*      | Server5.Host         |    news.newsdemon.com |
|                | Server5.Port         |                   563 |
|                | Server5.Encryption   |                   yes |
|                | Server5.Connections  |                    12 |
|                | Server5.Retention    |                  3303 |
| *News-Servers* | Server6.Level        |                     2 |
| *Server6*      | Server6.Host         |      us.newsdemon.com |
|                | Server6.Port         |                   563 |
|                | Server6.Encryption   |                   yes |
|                | Server6.Connections  |                    12 |
|                | Server6.Retention    |                  3303 |
| *News-Servers* | Server7.Level        |                     2 |
| *Server7*      | Server7.Host         |      eu.newsdemon.com |
|                | Server7.Port         |                   563 |
|                | Server7.Encryption   |                   yes |
|                | Server7.Connections  |                    12 |
|                | Server7.Retention    |                  3303 |
| *News-Servers* | Server8.Level        |                     2 |
| *Server8*      | Server8.Host         |      nl.newsdemon.com |
|                | Server8.Port         |                   563 |
|                | Server8.Encryption   |                   yes |
|                | Server8.Connections  |                    12 |
|                | Server8.Retention    |                  3303 |
| *News-Servers* | Server9.Level        |                     2 |
| *Server9*      | Server9.Host         |  usnews.blocknews.net |
|                | Server9.Port         |                   443 |
|                | Server9.Encryption   |                   yes |
|                | Server9.Connections  |                    16 |
|                | Server9.Retention    |                  3240 |
| *News-Servers* | Server10.Level       |                     2 |
| *Server10*     | Server10.Host        |  eunews.blocknews.net |
|                | Server10.Port        |                   443 |
|                | Server10.Encryption  |                   yes |
|                | Server10.Connections |                    16 |
|                | Server10.Retention   |                  3240 |
| *News-Servers* | Server11.Level       |                     2 |
| *Server11*     | Server11.Host        | eunews2.blocknews.net |
|                | Server11.Port        |                   443 |
|                | Server11.Encryption  |                   yes |
|                | Server11.Connections |                    16 |
|                | Server11.Retention   |                  3240 |
|----------------+----------------------+-----------------------|

*** Customize Safari
#+begin_src sh :var _safari=_safari[3:-2,1:5]

custom_safari () {
  config_defaults "${_safari}"
}
#+end_src

**** _safari
#+name: _safari
|-------------------------------------------------------------------------+-------------------------+----------------------------------------------------------------------------------------+---------+--------+------|
| Preference                                                              | Domain                  | Key                                                                                    | Type    | Value  | Host |
|-------------------------------------------------------------------------+-------------------------+----------------------------------------------------------------------------------------+---------+--------+------|
| *Safari opens with:* ~A new window~                                     | com.apple.Safari        | AlwaysRestoreSessionAtLaunch                                                           | -bool   | false  |      |
|                                                                         | com.apple.Safari        | OpenPrivateWindowWhenNotRestoringSessionAtLaunch                                       | -bool   | false  |      |
| *New windows open with:* ~Empty Page~                                   | com.apple.Safari        | NewWindowBehavior                                                                      | -int    | 1      |      |
| *New tabs open with:* ~Empty Page~                                      | com.apple.Safari        | NewTabBehavior                                                                         | -int    | 1      |      |
| ~off~ *Open “safe” files after downloading*                             | com.apple.Safari        | AutoOpenSafeDownloads                                                                  | -bool   | false  |      |
| *Open pages in tabs instead of windows:* ~Always~                       | com.apple.Safari        | TabCreationPolicy                                                                      | -int    | 2      |      |
| *AutoFill web forms:* ~off~ *Using info from my contacts*               | com.apple.Safari        | AutoFillFromAddressBook                                                                | -bool   | false  |      |
| *AutoFill web forms:* ~on~ *User names and passwords*                   | com.apple.Safari        | AutoFillPasswords                                                                      | -bool   | true   |      |
| *AutoFill web forms:* ~off~ *Credit cards*                              | com.apple.Safari        | AutoFillCreditCardData                                                                 | -bool   | false  |      |
| *AutoFill web forms:* ~off~ *Other forms*                               | com.apple.Safari        | AutoFillMiscellaneousForms                                                             | -bool   | false  |      |
| ~on~ *Include search engine suggestions*                                | com.apple.Safari        | SuppressSearchSuggestions                                                              | -bool   | false  |      |
| *Smart Search Field:* ~off~ *Include Safari Suggestions*                | com.apple.Safari        | UniversalSearchEnabled                                                                 | -bool   | false  |      |
| *Smart Search Field:* ~on~ *Enable Quick Website Search*                | com.apple.Safari        | WebsiteSpecificSearchEnabled                                                           | -bool   | true   |      |
| *Smart Search Field:* ~on~ *Preload Top Hit in the background*          | com.apple.Safari        | PreloadTopHit                                                                          | -bool   | true   |      |
| *Smart Search Field:* ~off~ *Show Favorites*                            | com.apple.Safari        | ShowFavoritesUnderSmartSearchField                                                     | -bool   | false  |      |
| *Website use of location services:* ~Deny without prompting~            | com.apple.Safari        | SafariGeolocationPermissionPolicy                                                      | -int    | 0      |      |
| *Website tracking: ~on~ *Prevent cross-site tracking*                   | com.apple.Safari        | BlockStoragePolicy                                                                     | -int    | 2      |      |
|                                                                         | com.apple.Safari        | WebKitStorageBlockingPolicy                                                            | -int    | 1      |      |
|                                                                         | com.apple.Safari        | com.apple.Safari.ContentPageGroupIdentifier.WebKit2StorageBlockingPolicy               | -int    | 1      |      |
| *Website tracking:* ~on~ *Ask websites not to track me*                 | com.apple.Safari        | SendDoNotTrackHTTPHeader                                                               | -bool   | true   |      |
| *Cookies and website data:* ~off~ *Block all cookies*                   | com.apple.WebFoundation | NSHTTPAcceptCookies                                                                    | -string | always |      |
| *Apple Pay:* ~on~ *Allow websites to check if Apple Pay is set up*      | com.apple.Safari        | com.apple.Safari.ContentPageGroupIdentifier.WebKit2ApplePayCapabilityDisclosureAllowed | -bool   | true   |      |
| ~off~ *Allow websites to ask for permission to send push notifications* | com.apple.Safari        | CanPromptForPushNotifications                                                          | -bool   | false  |      |
| *Smart Search Field:* ~on~ *Show full website address*                  | com.apple.Safari        | ShowFullURLInSmartSearchField                                                          | -bool   | true   |      |
| *Default encoding:* ~Unicode (UTF-8)~                                   | com.apple.Safari        | WebKitDefaultTextEncodingName                                                          | -string | utf-8  |      |
|                                                                         | com.apple.Safari        | com.apple.Safari.ContentPageGroupIdentifier.WebKit2DefaultTextEncodingName             | -string | utf-8  |      |
| ~on~ *Show Develop menu in menu bar*                                    | com.apple.Safari        | IncludeDevelopMenu                                                                     | -bool   | true   |      |
|                                                                         | com.apple.Safari        | WebKitDeveloperExtrasEnabledPreferenceKey                                              | -bool   | true   |      |
|                                                                         | com.apple.Safari        | com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled              | -bool   | true   |      |
| *View* ▶ *Show Favorites Bar*                                           | com.apple.Safari        | ShowFavoritesBar-v2                                                                    | -bool   | true   |      |
| *View* ▶ *Show Tab Bar*                                                 | com.apple.Safari        | AlwaysShowTabBar                                                                       | -bool   | true   |      |
| *View* ▶ *Show Status Bar*                                              | com.apple.Safari        | ShowStatusBar                                                                          | -bool   | true   |      |
|                                                                         | com.apple.Safari        | ShowStatusBarInFullScreen                                                              | -bool   | true   |      |
|-------------------------------------------------------------------------+-------------------------+----------------------------------------------------------------------------------------+---------+--------+------|

*** Customize Sieve
#+begin_src sh
custom_sieve () {
  cat > "${HOME}/.sieve" << EOF
require ["date", "fileinto", "imap4flags", "mailbox", "relational", "variables"];

setflag "\\\\Seen";

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
#+end_src

*** Customize Sonarr
#+begin_src sh :var _sonarr=_sonarr[3:-2,0:1]

custom_sonarr () {
  open "http://localhost:7878/settings/mediamanagement"
  open "http://localhost:8989/settings/mediamanagement"
  printf "%s" "$_sonarr" | \
  while IFS="$(printf '\t')" read pref value; do
    printf "\033[1m\033[34m%s:\033[0m %s\n" "$pref" "$value"
  done
}

#+end_src

**** _sonarr
#+name: _sonarr
|---------------------------------+--------------------------------------------------------------|
| Preference                      | Value                                                        |
|---------------------------------+--------------------------------------------------------------|
| Advanced Settings               | Shown                                                        |
| Rename Episodes                 | Yes                                                          |
| Standard Episode Format         | {Series Title} - s{season:00}e{episode:00} - {Episode Title} |
| Daily Episode Format            | {Series Title} - {Air-Date} - {Episode Title}                |
| Anime Episode Format            | {Series Title} - s{season:00}e{episode:00} - {Episode Title} |
| Multi-Episode Style             | Scene                                                        |
| Create empty series folders     | Yes                                                          |
| Ignore Deleted Episodes         | Yes                                                          |
| Change File Date                | UTC Air Date                                                 |
| Set Permissions                 | Yes                                                          |
| Download Clients                | NZBGet                                                       |
| NZBGet: Name                    | NZBGet                                                       |
| NZBGet: Category                | Sonarr                                                       |
| Failed: Remove                  | No                                                           |
| Drone Factory Interval          | 0                                                            |
| Connect: Custom Script          |                                                              |
| postSonarr: Name                | postSonarr                                                   |
| postSonarr: On Grab             | No                                                           |
| postSonarr: On Download         | Yes                                                          |
| postSonarr: On Upgrade          | Yes                                                          |
| postSonarr: On Rename           | No                                                           |
| postSonarr: Path                | ${HOME}/.config/mp4_automator/postSonarr.py                  |
| Start-Up: Open browser on start | No                                                           |
| Security: Authentication        | Basic (Browser popup)                                        |
|---------------------------------+--------------------------------------------------------------|

*** Customize SSH
#+begin_src sh
custom_ssh () {
  if ! test -d "${HOME}/.ssh"; then
    mkdir -m go= "${HOME}/.ssh"
    e="$(ask 'New SSH Key: Email Address?' 'OK' '')"
    ssh-keygen -t ed25519 -a 100 -C "$e"
    cat << EOF > "${HOME}/.ssh/config"
Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
EOF
    pbcopy < "${HOME}/.ssh/id_ed25519.pub"
    open "https://github.com/settings/keys"
  fi
}
#+end_src

*** Customize System Preferences
#+begin_src sh
custom_sysprefs () {
  custom_general
  custom_desktop "/Library/Desktop Pictures/Solid Colors/Solid Black.png"
  custom_screensaver
  custom_dock
  custom_dockapps
  # custom_security
  custom_text
  custom_dictation
  custom_mouse
  custom_trackpad
  custom_sound
  custom_loginitems
  custom_siri
  custom_clock
  custom_a11y
  custom_other
}
#+end_src

**** Customize General
#+begin_src sh :var _general=_general[3:-2,1:5]

custom_general () {
  osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
  config_defaults "${_general}"
  osascript << EOF
<<recent-items.applescript>>
EOF
}
#+end_src

**** =recent-items.applescript=
#+begin_src applescript :noweb-ref recent-items.applescript
    tell application "System Events"
      tell appearance preferences
        set recent documents limit to 0
        set recent applications limit to 0
        set recent servers limit to 0
      end tell
    end tell
#+end_src

**** _general
#+name: _general
|----------------------------------------------------------------+--------------------------------------+------------------------------+---------+----------------------------+--------------|
| Preference                                                     | Domain                               | Key                          | Type    | Value                      | Host         |
|----------------------------------------------------------------+--------------------------------------+------------------------------+---------+----------------------------+--------------|
| *Appearance:* ~Graphite~ *For Buttons, Menus, and Windows*     | -globalDomain                        | AppleAquaColorVariant        | -int    | 6                          |              |
| *Appearance:* ~on~ *Use dark menu bar and Dock*                | -globalDomain                        | AppleInterfaceStyle          | -string | Dark                       |              |
| *Appearance:* ~off~ *Automatically hide and show the menu bar* | -globalDomain                        | _HIHideMenuBar               | -bool   | false                      |              |
| *Highlight color:* ~#99CC99~ ~Other…~                          | -globalDomain                        | AppleHighlightColor          | -string | 0.600000 0.800000 0.600000 |              |
| *Sidebar icon size:* ~Small~                                   | -globalDomain                        | NSTableViewDefaultSizeMode   | -int    | 1                          |              |
| *Show scroll bars:* ~Always~                                   | -globalDomain                        | AppleShowScrollBars          | -string | Always                     |              |
| *Click in the scroll bar to:* ~Jump to the next page~          | -globalDomain                        | AppleScrollerPagingBehavior  | -bool   | false                      |              |
| ~on~ *Ask to keep changes when closing documents*              | -globalDomain                        | NSCloseAlwaysConfirmsChanges | -bool   | true                       |              |
| ~on~ *Close windows when quitting an app*                      | -globalDomain                        | NSQuitAlwaysKeepsWindows     | -bool   | false                      |              |
| ~on~ *Allow Handoff between this Mac and your iCloud devices*  | com.apple.coreservices.useractivityd | ActivityAdvertisingAllowed   | -bool   | true                       | -currentHost |
|                                                                | com.apple.coreservices.useractivityd | ActivityReceivingAllowed     | -bool   | true                       | -currentHost |
| ~on~ *Use LCD font smoothing when available*                   | -globalDomain                        | AppleFontSmoothing           | -int    | 1                          | -currentHost |
|----------------------------------------------------------------+--------------------------------------+------------------------------+---------+----------------------------+--------------|

**** Customize Desktop Picture
#+begin_src sh
custom_desktop () {
  osascript - "${1}" << EOF 2> /dev/null
<<custom_desktop.applescript>>
EOF
}
#+end_src

**** =custom_desktop.applescript=
#+begin_src applescript :noweb-ref custom_desktop.applescript
    on run { _this }
      tell app "System Events" to set picture of every desktop to POSIX file _this
    end run
#+end_src

**** Customize Screen Saver
#+begin_src sh :var _screensaver=_screensaver[3:-2,1:5]

custom_screensaver () {
  if test -e "/Library/Screen Savers/BlankScreen.saver"; then
    defaults -currentHost write com.apple.screensaver moduleDict \
      '{
        moduleName = "BlankScreen";
        path = "/Library/Screen Savers/BlankScreen.saver";
        type = 0;
      }'
  fi
  config_defaults "${_screensaver}"
}
#+end_src

**** _screensaver
#+name: _screensaver
|-------------------------------------------------------------+-----------------------+--------------------------+---------+---------+--------------|
| Preference                                                  | Domain                | Key                      | Type    | Value   | Host         |
|-------------------------------------------------------------+-----------------------+--------------------------+---------+---------+--------------|
| *Start after:* ~Never~                                      | com.apple.screensaver | idleTime                 | -int    | 0       | -currentHost |
| *Hot Corners…: Top Left:* ~⌘ Mission Control~               | com.apple.dock        | wvous-tl-corner          | -int    | 2       |              |
|                                                             | com.apple.dock        | wvous-tl-modifier        | -int    | 1048576 |              |
| *Hot Corners…: Bottom Left:* ~Put Display to Sleep~         | com.apple.dock        | wvous-bl-corner          | -int    | 10      |              |
|                                                             | com.apple.dock        | wvous-bl-modifier        | -int    | 0       |              |
|-------------------------------------------------------------+-----------------------+--------------------------+---------+---------+--------------|

**** Customize Dock
#+begin_src sh :var _dock=_dock[3:-2,1:5]

custom_dock () {
  config_defaults "${_dock}"
}
#+end_src

**** _dock
#+name: _dock
|-----------------------------------------------------+----------------+--------------------------+---------+--------+------|
| Preference                                          | Domain         | Key                      | Type    | Value  | Host |
|-----------------------------------------------------+----------------+--------------------------+---------+--------+------|
| *Size:* ~32 px~                                     | com.apple.dock | tilesize                 | -int    | 32     |      |
| ~off~ *Magnification:* ~64 px~                      | com.apple.dock | magnification            | -bool   | false  |      |
|                                                     | com.apple.dock | largesize                | -int    | 64     |      |
| *Position on screen:* ~Right~                       | com.apple.dock | orientation              | -string | right  |      |
| *Minimize windows using:* ~Scale effect~            | com.apple.dock | mineffect                | -string | scale  |      |
| *Prefer tabs when opening documents:* ~Always~      | -globalDomain  | AppleWindowTabbingMode   | -string | always |      |
| ~off~ *Double-click a window’s title bar to* ~None~ | -globalDomain  | AppleActionOnDoubleClick | -string | None   |      |
| ~on~ *Minimize windows into application icon*       | com.apple.dock | minimize-to-application  | -bool   | true   |      |
| ~off~ *Animate opening applications*                | com.apple.dock | launchanim               | -bool   | false  |      |
| ~on~ *Automatically hide and show the Dock*         | com.apple.dock | autohide                 | -bool   | true   |      |
| ~on~ *Show indicators for open applications*        | com.apple.dock | show-process-indicators  | -bool   | true   |      |
|-----------------------------------------------------+----------------+--------------------------+---------+--------+------|

**** Customize Dock Apps
#+begin_src sh :var _dockapps=_dockapps[3:-2,0]

custom_dockapps () {
  defaults write com.apple.dock "autohide-delay" -float 0
  defaults write com.apple.dock "autohide-time-modifier" -float 0.5

  defaults delete com.apple.dock "persistent-apps"

  printf "%s\n" "${_dockapps}" | \
  while IFS="$(printf '\t')" read app; do
    if test -e "/Applications/${app}.app"; then
      defaults write com.apple.dock "persistent-apps" -array-add \
        "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/${app}.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    fi
  done

  defaults delete com.apple.dock "persistent-others"

  osascript -e 'tell app "Dock" to quit'
}
#+end_src

**** _dockapps
#+name: _dockapps
|--------------------|
| Dock Items         |
|--------------------|
| Metanota Pro       |
| Mail               |
| Safari             |
| Messages           |
| Emacs              |
| BBEdit             |
| Atom               |
| Utilities/Terminal |
| iTerm              |
| System Preferences |
| PCalc              |
| Hermes             |
| iTunes             |
| VLC                |
|--------------------|

**** Customize Security
#+begin_src sh :var _security=_security[3:-2,1:5]

custom_security () {
  config_defaults "${_security}"
}
#+end_src

**** _security
#+name: _security
|--------------------------------------------------------------------------+-----------------------+---------------------+------+-------+------|
| Preference                                                               | Domain                | Key                 | Type | Value | Host |
|--------------------------------------------------------------------------+-----------------------+---------------------+------+-------+------|
| ~on~ *Require password* ~5 seconds~ *after sleep or screen saver begins* | com.apple.screensaver | askForPassword      | -int |     1 |      |
|                                                                          | com.apple.screensaver | askForPasswordDelay | -int |     5 |      |
|--------------------------------------------------------------------------+-----------------------+---------------------+------+-------+------|

**** Customize Text
#+begin_src sh :var _text=_text[3:-2,1:5]
custom_text () {
  config_defaults "${_text}"
}
#+end_src

**** _text
#+name: _text
|----------------------------------------+---------------+--------------------------------------+-------+-------+------|
| Preference                             | Domain        | Key                                  | Type  | Value | Host |
|----------------------------------------+---------------+--------------------------------------+-------+-------+------|
| ~off~ *Capitalize words automatically* | -globalDomain | NSAutomaticCapitalizationEnabled     | -bool | false |      |
| ~off~ *Add period with double-space*   | -globalDomain | NSAutomaticPeriodSubstitutionEnabled | -bool | false |      |
| ~off~ *Use smart quotes and dashes*    | -globalDomain | NSAutomaticQuoteSubstitutionEnabled  | -bool | false |      |
|----------------------------------------+---------------+--------------------------------------+-------+-------+------|

**** Customize Dictation
#+begin_src sh :var _dictation=_dictation[2:3,1:5]

custom_dictation () {
  config_defaults "${_dictation}"
}
#+end_src

**** _dictation
#+name: _dictation
|-------------------+-----------------------------------------------------------+-----------------------------------+-------+-------+------|
| Preference        | Domain                                                    | Key                               | Type  | Value | Host |
|-------------------+-----------------------------------------------------------+-----------------------------------+-------+-------+------|
| *Dictation:* ~On~ | com.apple.speech.recognition.AppleSpeechRecognition.prefs | DictationIMMasterDictationEnabled | -bool | true  |      |
|-------------------+-----------------------------------------------------------+-----------------------------------+-------+-------+------|

**** Customize Mouse
#+begin_src sh :var _mouse=_mouse[2:3,1:5]

custom_mouse () {
  config_defaults "${_mouse}"
}
#+end_src

**** _mouse
#+name: _mouse
|-----------------------------------+---------------+--------------------------------+-------+-------+------|
| Preference                        | Domain        | Key                            | Type  | Value | Host |
|-----------------------------------+---------------+--------------------------------+-------+-------+------|
| ~off~ *Scroll direction: Natural* | -globalDomain | com.apple.swipescrolldirection | -bool | false |      |
|-----------------------------------+---------------+--------------------------------+-------+-------+------|

**** Customize Trackpad
#+begin_src sh :var _trackpad=_trackpad[3:-2,1:5]

custom_trackpad () {
  config_defaults "${_trackpad}"
}
#+end_src

**** _trackpad
#+name: _trackpad
|---------------------+----------------------------------------------------+-----------------------------+-------+-------+--------------|
| Preference          | Domain                                             | Key                         | Type  | Value | Host         |
|---------------------+----------------------------------------------------+-----------------------------+-------+-------+--------------|
| ~on~ *Tap to click* | com.apple.driver.AppleBluetoothMultitouch.trackpad | Clicking                    | -bool | true  |              |
|                     | -globalDomain                                      | com.apple.mouse.tapBehavior | -int  | 1     | -currentHost |
|---------------------+----------------------------------------------------+-----------------------------+-------+-------+--------------|

**** Customize Sound
#+begin_src sh :var _sound=_sound[3:-2,1:5]

custom_sound () {
  config_defaults "${_sound}"
}
#+end_src

**** _sound
#+name: _sound
|----------------------------------------------+---------------+---------------------------------+---------+------------------------------------+------|
| Preference                                   | Domain        | Key                             | Type    | Value                              | Host |
|----------------------------------------------+---------------+---------------------------------+---------+------------------------------------+------|
| *Select an alert sound:* ~Sosumi~            | -globalDomain | com.apple.sound.beep.sound      | -string | /System/Library/Sounds/Sosumi.aiff |      |
| ~off~ *Play user interface sound effects*    | -globalDomain | com.apple.sound.uiaudio.enabled | -int    | 0                                  |      |
| ~off~ *Play feedback when volume is changed* | -globalDomain | com.apple.sound.beep.feedback   | -int    | 0                                  |      |
|----------------------------------------------+---------------+---------------------------------+---------+------------------------------------+------|

**** Customize Login Items
#+begin_src sh :var _loginitems=_loginitems[3:-2,0]
custom_loginitems () {
  printf "%s\n" "${_loginitems}" | \
  while IFS="$(printf '\t')" read app; do
    if test -e "$app"; then
      osascript - "$app" << EOF > /dev/null
        on run { _app }
          tell app "System Events"
            make new login item with properties { hidden: true, path: _app }
          end tell
        end run
EOF
    fi
  done
}
#+end_src

**** _loginitems
#+name: _loginitems
|------------------------------------------------------------------------------------|
| Login Items                                                                        |
|------------------------------------------------------------------------------------|
| /Applications/Alfred 3.app                                                         |
| /Applications/autoping.app                                                         |
| /Applications/Caffeine.app                                                         |
| /Applications/Coffitivity.app                                                      |
| /Applications/Dropbox.app                                                          |
| /Applications/HardwareGrowler.app                                                  |
| /Applications/I Love Stars.app                                                     |
| /Applications/IPMenulet.app                                                        |
| /Applications/iTunes.app/Contents/MacOS/iTunesHelper.app                           |
| /Applications/Menubar Countdown.app                                                |
| /Applications/Meteorologist.app                                                    |
| /Applications/Moom.app                                                             |
| /Applications/NZBGet.app                                                           |
| /Applications/Plex Media Server.app                                                |
| /Applications/Radarr.app                                                           |
| /Applications/Sonarr-Menu.app                                                      |
| /Library/PreferencePanes/SteerMouse.prefPane/Contents/MacOS/SteerMouse Manager.app |
|------------------------------------------------------------------------------------|

**** Customize Siri
#+begin_src sh
custom_siri () {
  defaults write com.apple.assistant.backedup "Output Voice" \
    '{
      Custom = 1;
      Footprint = 0;
      Gender = 1;
      Language = "en-US";
    }'
  defaults write com.apple.Siri StatusMenuVisible -bool false
}
#+end_src

**** Customize Clock
#+begin_src sh
custom_clock () {
  defaults -currentHost write com.apple.systemuiserver dontAutoLoad \
    -array-add "/System/Library/CoreServices/Menu Extras/Clock.menu"
  defaults write com.apple.menuextra.clock DateFormat \
    -string "EEE MMM d  h:mm:ss a"
}
#+end_src

**** Customize Accessibility
#+begin_src sh :var _a11y=_a11y[2:3,1:5] :var _speech=_a11y[4:-2,1:5]

custom_a11y () {
  config_defaults "${_a11y}"

  if test -d "/System/Library/Speech/Voices/Allison.SpeechVoice"; then
    config_defaults "${_speech}"
    defaults write com.apple.speech.voice.prefs VisibleIdentifiers \
      '{
        "com.apple.speech.synthesis.voice.allison.premium" = 1;
      }'
  fi
}
#+end_src

**** _a11y
#+name: _a11y
|-------------------------------------+------------------------------+----------------------+---------+------------+------|
| Preference                          | Domain                       | Key                  | Type    | Value      | Host |
|-------------------------------------+------------------------------+----------------------+---------+------------+------|
| Display: ~on~ *Reduce transparency* | com.apple.universalaccess    | reduceTransparency   | -bool   | true       |      |
| Speech: System Voice: Allison       | com.apple.speech.voice.prefs | SelectedVoiceName    | -string | Allison    |      |
|                                     | com.apple.speech.voice.prefs | SelectedVoiceCreator | -int    | 1886745202 |      |
|                                     | com.apple.speech.voice.prefs | SelectedVoiceID      | -int    | 184555197  |      |
|-------------------------------------+------------------------------+----------------------+---------+------------+------|

**** Customize Other Prefs
#+begin_src sh :var _other_prefs=_other_prefs[3:-2,0:4]
custom_other () {
  T=$(printf '\t')
  printf "%s\n" "$_other_prefs" | \
  while IFS="$T" read pane anchor paneid anchorid icon; do
    osascript - "$pane" "$anchor" "$paneid" "$anchorid" "$icon" << EOF 2> /dev/null
<<open-syspref.applescript>>
EOF
  done
}
#+end_src

***** =open-syspref.applescript=
#+begin_src applescript :noweb-ref open-syspref.applescript
  on run { _pane, _anchor, _paneid, _anchorid, _icon }
    tell app "System Events"
      display dialog "Open the " & _anchor & " pane of " & _pane & " preferences." buttons { "Open " & _pane } default button 1 with icon POSIX file _icon
    end tell
    tell app "System Preferences"
      if not running then run
      reveal anchor _anchorid of pane id _paneid
      activate
    end tell
  end run
#+end_src

#+name: _other_prefs
|---------------------+---------------+----------------------------------------+--------------------------+---------------------------------------------------------------------------------------------|
| Pane                | Anchor        | Pane ID                                | Anchor ID                | Icon                                                                                        |
|---------------------+---------------+----------------------------------------+--------------------------+---------------------------------------------------------------------------------------------|
| Security & Privacy  | General       | com.apple.preference.security          | General                  | /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns         |
| Security & Privacy  | FileVault     | com.apple.preference.security          | FDE                      | /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns         |
| Security & Privacy  | Accessibility | com.apple.preference.security          | Privacy_Accessibility    | /System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns         |
| Displays            | Display       | com.apple.preference.displays          | displaysDisplayTab       | /System/Library/PreferencePanes/Displays.prefPane/Contents/Resources/Displays.icns          |
| Keyboard            | Modifer Keys  | com.apple.preference.keyboard          | keyboardTab_ModifierKeys | /System/Library/PreferencePanes/Keyboard.prefPane/Contents/Resources/Keyboard.icns          |
| Keyboard            | Text          | com.apple.preference.keyboard          | Text                     | /System/Library/PreferencePanes/Keyboard.prefPane/Contents/Resources/Keyboard.icns          |
| Keyboard            | Shortcuts     | com.apple.preference.keyboard          | shortcutsTab             | /System/Library/PreferencePanes/Keyboard.prefPane/Contents/Resources/Keyboard.icns          |
| Keyboard            | Dictation     | com.apple.preference.keyboard          | Dictation                | /System/Library/PreferencePanes/Keyboard.prefPane/Contents/Resources/Keyboard.icns          |
| Printers & Scanners | Main          | com.apple.preference.printfax          | print                    | /System/Library/PreferencePanes/PrintAndScan.prefPane/Contents/Resources/PrintScanPref.icns |
| Internet Accounts   | Main          | com.apple.preferences.internetaccounts | InternetAccounts         | /System/Library/PreferencePanes/iCloudPref.prefPane/Contents/Resources/iCloud.icns          |
| Network             | Wi-Fi         | com.apple.preference.network           | Wi-Fi                    | /System/Library/PreferencePanes/Network.prefPane/Contents/Resources/Network.icns            |
| Users & Groups      | Login Options | com.apple.preferences.users            | loginOptionsPref         | /System/Library/PreferencePanes/Accounts.prefPane/Contents/Resources/AccountsPref.icns      |
| Time Machine        | Main          | com.apple.prefs.backup                 | main                     | /System/Library/PreferencePanes/TimeMachine.prefPane/Contents/Resources/TimeMachine.icns    |
|---------------------+---------------+----------------------------------------+--------------------------+---------------------------------------------------------------------------------------------|

*** Customize Terminal
#+begin_src sh :var _term_plist=_term_plist[3:-2,1:4] :var _term_defaults=_term_defaults[3:-2,1:5]

custom_terminal () {
  config_plist "${_term_plist}" \
    "${HOME}/Library/Preferences/com.apple.Terminal.plist" \
    ":Window Settings:ptb"
  config_defaults "${_term_defaults}"
}
#+end_src

**** _term_plist
#+name: _term_plist
|------------+---------+---------------------------------------+---------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Preference | Command | Entry                                 | Type    | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|------------+---------+---------------------------------------+---------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|            | delete  |                                       |         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
|            | add     | :                                     |         | dict                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :name                                 | string  | ptb                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
|            | add     | :type                                 | string  | Window Settings                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
|            | add     | :ProfileCurrentVersion                | real    | 2.05                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :BackgroundColor                      | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC4xIDAuMSAwLjE=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :BackgroundBlur                       | real    | 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :BackgroundSettingsForInactiveWindows | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :BackgroundAlphaInactive              | real    | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :BackgroundBlurInactive               | real    | 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :Font                                 | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>3</integer></dict><key>NSName</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSSize</key><real>13</real><key>NSfFlags</key><integer>16</integer></dict><string>InconsolataLGC</string><dict><key>$classes</key><array><string>NSFont</string><string>NSObject</string></array><key>$classname</key><string>NSFont</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist> |
|            | add     | :FontWidthSpacing                     | real    | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :FontHeightSpacing                    | real    | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :FontAntialias                        | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :UseBoldFonts                         | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :BlinkText                            | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :DisableANSIColor                     | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :UseBrightBold                        | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :TextColor                            | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDAuOCAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :TextBoldColor                        | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDAuOCAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :SelectionColor                       | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC4zIDAuMyAwLjM=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ANSIBlackColor                       | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC4zIDAuMyAwLjM=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ANSIRedColor                         | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC45NSAwLjUgMC41</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ANSIGreenColor                       | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC42IDAuOCAwLjY=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ANSIYellowColor                      | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MSAwLjggMC40</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                     |
|            | add     | :ANSIBlueColor                        | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC40IDAuNiAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ANSIMagentaColor                     | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDAuNiAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ANSICyanColor                        | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC40IDAuOCAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ANSIWhiteColor                       | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDAuOCAwLjg=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ANSIBrightBlackColor                 | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC41IDAuNSAwLjU=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ANSIBrightRedColor                   | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MSAwLjcgMC43</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                     |
|            | add     | :ANSIBrightGreenColor                 | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC44IDEgMC44</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                     |
|            | add     | :ANSIBrightYellowColor                | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MSAxIDAuNg==</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                     |
|            | add     | :ANSIBrightBlueColor                  | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC42IDAuOCAx</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                     |
|            | add     | :ANSIBrightMagentaColor               | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MSAwLjggMQ==</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                     |
|            | add     | :ANSIBrightCyanColor                  | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC42IDEgMQ==</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                     |
|            | add     | :ANSIBrightWhiteColor                 | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC45IDAuOSAwLjk=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :CursorType                           | integer | 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :CursorBlink                          | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :CursorColor                          | data    | <?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>$archiver</key><string>NSKeyedArchiver</string><key>$objects</key><array><string>$null</string><dict><key>$class</key><dict><key>CF$UID</key><integer>2</integer></dict><key>NSColorSpace</key><integer>1</integer><key>NSRGB</key><data>MC43IDAuNyAwLjc=</data></dict><dict><key>$classes</key><array><string>NSColor</string><string>NSObject</string></array><key>$classname</key><string>NSColor</string></dict></array><key>$top</key><dict><key>root</key><dict><key>CF$UID</key><integer>1</integer></dict></dict><key>$version</key><integer>100000</integer></dict></plist>                                                                                 |
|            | add     | :ShowRepresentedURLInTitle            | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :ShowRepresentedURLPathInTitle        | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :ShowActiveProcessInTitle             | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :ShowActiveProcessArgumentsInTitle    | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowShellCommandInTitle              | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowWindowSettingsNameInTitle        | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowTTYNameInTitle                   | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowDimensionsInTitle                | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowCommandKeyInTitle                | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :columnCount                          | integer | 121                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
|            | add     | :rowCount                             | integer | 35                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|            | add     | :ShouldLimitScrollback                | integer | 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :ScrollbackLines                      | integer | 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :ShouldRestoreContent                 | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowRepresentedURLInTabTitle         | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowRepresentedURLPathInTabTitle     | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowActiveProcessInTabTitle          | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :ShowActiveProcessArgumentsInTabTitle | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowTTYNameInTabTitle                | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ShowComponentsWhenTabHasCustomTitle  | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :ShowActivityIndicatorInTab           | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :shellExitAction                      | integer | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :warnOnShellCloseAction               | integer | 1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :useOptionAsMetaKey                   | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :ScrollAlternateScreen                | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :TerminalType                         | string  | xterm-256color                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|            | add     | :deleteSendsBackspace                 | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :EscapeNonASCIICharacters             | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :ConvertNewlinesOnPaste               | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :StrictVTKeypad                       | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :scrollOnInput                        | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :Bell                                 | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :VisualBell                           | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :VisualBellOnlyWhenMuted              | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :BellBadge                            | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :BellBounce                           | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :BellBounceCritical                   | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|            | add     | :CharacterEncoding                    | integer | 4                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|            | add     | :SetLanguageEnvironmentVariables      | bool    | true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|            | add     | :EastAsianAmbiguousWide               | bool    | false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|------------+---------+---------------------------------------+---------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

**** _term_defaults
#+name: _term_defaults
|------------+--------------------+-------------------------+---------+-------+------|
| Preference | Domain             | Key                     | Type    | Value | Host |
|------------+--------------------+-------------------------+---------+-------+------|
|            | com.apple.Terminal | Startup Window Settings | -string | ptb   |      |
|            | com.apple.Terminal | Default Window Settings | -string | ptb   |      |
|------------+--------------------+-------------------------+---------+-------+------|

*** Customize Vim
#+begin_src sh
custom_vim () {
  true
}
#+end_src

*** Customize VLC
#+begin_src sh :var _vlc_defaults=_vlc_defaults[3:-2,1:5] :var _vlcrc=_vlcrc[3:-2,1:3]

custom_vlc () {
  config_defaults "${_vlc_defaults}"
  if which crudini > /dev/null; then
    test -d "${HOME}/Library/Preferences/org.videolan.vlc" || \
      mkdir -p "${HOME}/Library/Preferences/org.videolan.vlc"
    printf "%s\n" "${_vlcrc}" | \
    while IFS="$(printf '\t')" read section key value; do
      crudini --set "${HOME}/Library/Preferences/org.videolan.vlc/vlcrc" "${section}" "${key}" "${value}"
    done
  fi
}
#+end_src

**** _vlc_defaults
#+name: _vlc_defaults
|--------------------------------------+------------------+-------------------------+-------+-------+------|
| Preference                           | Domain           | Key                     | Type  | Value | Host |
|--------------------------------------+------------------+-------------------------+-------+-------+------|
| ~on~ Automatically check for updates | org.videolan.vlc | SUEnableAutomaticChecks | -bool | true  |      |
|                                      | org.videolan.vlc | SUHasLaunchedBefore     | -bool | true  |      |
|                                      | org.videolan.vlc | SUSendProfileInfo       | -bool | true  |      |
|--------------------------------------+------------------+-------------------------+-------+-------+------|

**** _vlcrc
#+name: _vlcrc
|---------------------------------------------------------------------+---------+-----------------------------+---------|
| Preference                                                          | Section | Key                         |   Value |
|---------------------------------------------------------------------+---------+-----------------------------+---------|
| *Interface:* ~on~ *Use the native fullscreen mode*                  | macosx  | macosx-nativefullscreenmode |       1 |
| *Interface:* ~off~ *Resize interface to the native video size*      | macosx  | macosx-video-autoresize     |       0 |
| *Interface:* ~off~ *Control playback with the Apple Remote*         | macosx  | macosx-appleremote          |       0 |
| *Interface:* ~on~ *Pause the video playback when minimized*         | macosx  | macosx-pause-minimized      |       1 |
| *Interface:* *Continue playback* ~Always~                           | macosx  | macosx-continue-playback    |       1 |
| *Interface:* ~on~ *Allow metadata network access*                   | core    | metadata-network-access     |       1 |
| *Audio:* ~Always reset audio start level to:~ ~100%~                | core    | volume-save                 |       0 |
| *Audio:* ~on~ *Use S/PDIF when available*                           | core    | spdif                       |       1 |
| *Subtitles / OSD:* *Preferred subtitle language* ~English~          | core    | sub-language                | English |
| *Interface:* *Hotkeys settings:* Medium jump length* ~30~           | core    | medium-jump-size            |      30 |
| *Subtitles / OSD:* *Default Encoding* ~Universal (UTF-8)~           | subsdec | subsdec-encoding            |   UTF-8 |
| *Input / Codecs: Hardware Acceleration* ~Video Decode Acceleration~ | avcodec | avcodec-hw                  |     vda |
|---------------------------------------------------------------------+---------+-----------------------------+---------|

** Personalize

*** Define Function =personalize=
#+begin_src sh
personalize () {
  printf "%b" "$(echo "${1}" | openssl enc -aes-256-ecb -a -d -pass "pass:${CRYPTPASS}")" | sh
}
#+end_src

*** Define Function =personalize_all=
#+begin_src sh
personalize_all () {
  personalize_ccc4
  personalize_sketchuppro8
  personalize_istatmenus5
  personalize_littlesnitch4
  personalize_meteorologist3
  personalize_moom
  personalize_nzbget
  personalize_nzbvortex
  personalize_pacifist
  personalize_pcalc3
  personalize_scrivener
  personalize_sizeup
  personalize_steermouse5
  personalize_tower2
  personalize_transmit4
  personalize_tune4mac
  personalize_vmwarefusion8pro
  personalize_logout
}
#+end_src

*** Personalize Carbon Copy Cloner 4
#+begin_src sh :var _ccc4_crypt=_ccc4_crypt

personalize_ccc4 () {
  personalize "${_ccc4_crypt}"
}
#+end_src

#+name: _ccc4_crypt
| U2FsdGVkX1/MLZ+EavKN4ODNZY1H0LENk6AnfNBq/JmkRR4f3uSZHoo0c7mZbLdU |
| 0V5ygQMCllFVHW0WgAQYyMMeihp6PQ+qjTNZvs05bBCm3ovV2ZJOaR5viJOMQj/v |
| aiYazKPPLhR8kNSxWloOS/3xqvENuwCPSjVj9mZxp4U6pSA0swevHhhopr01sube |
| 7ay3OykHFZGXAdkkPd64DthTSLTPnF5Yf0GIvLWlJwVJTZxDkb+4tiMRouE1gRPA |
| 51Qah/fTE4sFHuvmoCrrAnRBfEuYH5DaWc2FWLWM2srqjd0+TA6N3xIipm0D7jjw |
| urcxNanFv0oSBSJpwhYM4YAFGHvSHcbPk/orvtB1URN5+KmYPPjk8Ad2fF10PGBm |
| +TlnRloE3sITbYmIzi3MKSdqerw5wf2x69ioNgF/c4xUHZtrVioSIcR2oIwVua8N |
| 05OzDNG0XjI9bDo+bsevflV7cSg2YMhJElTlqQa7fUfQLUnP7+QJEeX1Azq2LdF6 |
| HpEgFgV9Ruv9XHwHJ2lrJG+/qpYhbv+X2wTmmgnqtQY=                     |

*** Personalize Sketchup Pro 8
#+begin_src sh :var _sketchuppro8_crypt=_sketchuppro8_crypt

personalize_sketchuppro8 () {
  personalize "${_sketchuppro8_crypt}"
}
#+end_src

#+name: _sketchuppro8_crypt
| U2FsdGVkX1/CiRi4IbSmF9DMnkgd74TA3yNaILrAIAJ6EkdS9a8eLeWLEGVItc9j |
| NWk8T5bIUkT3XCUFeBAFU4hX10smsLoT17MZD/vDevm+Nu1Efo4stPLOzg90pNEb |
| B0dn2LLBJV8dhDpBHvoBJYl6hXbu7khPZpfVwOTWUGPrdYULEbutjkbYF9R7j+KO |
| cTkFyHqpPMxDGGOEhoFUptifSo++KbX0oZWWK5S+XK4=                     |

*** Personalize iStat Menus 5
#+begin_src sh :var _istatmenus5_crypt=_istatmenus5_crypt

personalize_istatmenus5 () {
  personalize "${_istatmenus5_crypt}"
}
#+end_src

#+name: _istatmenus5_crypt
| U2FsdGVkX1+tdI0uAzK7kUWZN9APcwvzte3Q4E1Gr+lOlBTkn55cbHepHjYo0f+W |
| FC+v9NBp13EI+owprzVN8qU+Xs9pX69WKgLQuKa45d8ASrX6Pwz9HrYLVfauuh4r |
| d8Zd5K8KEsDDZJSmbPq9Xg==                                         |

*** Personalize Little Snitch 4
#+begin_src sh :var _littlesnitch4_crypt=_littlesnitch4_crypt

personalize_littlesnitch4 () {
  personalize "${_littlesnitch4_crypt}"
}
#+end_src

#+name: _littlesnitch4_crypt
| U2FsdGVkX18thR0gOmvkpKnSlLhcoHYWP4KcJZodKQIv+Epgi/zbNfW25qNYaxGq |
| o0/1HUxF+mTw7bsuAJxKM+u1iwLti/BRcicReoLvqSziH/LMvIt3pAEs5UfnHGpy |
| Bd/lcdnAVm7Sq+r1T5CsNzPR5z0Wuziju0ie14PmT/V/PpJ47B/k8ScT/b7mfwzv |
| 82RqOFdZJjdJ5sK50aiNt9K5h7up6uVwK7cdut44Xf4TDx/UTR46xsUew8jG4I5F |
| EAWUUBvoI2N9lSywCXdmes5qm2LQ3gxZlCrJgY3/oXe6fUi5BLdVK8iGL6NVq+PY |
| lDx4SOVP+hZ5kjOpVLe91zhw6nVy1yon6P447IJT0VxP9RaJW2F3VkckRU4xFfao |
| ShL49pYYhS4yCzxO/sSSHFR+hzaxCMyYGaddDFwN7u5sp4TOiTj+S6HiF6H9c+Uo |
| b4p9g/CwMsplzedpm9X/Y/hIQ0Uda42r91T75H0f4kWjGd2/LEBUjSVXzPBzYZ9a |
| o9SduxX3XE+506zBBpE5CGb20ndVEFXgJfq8CVnl7uEF87b+L9AxusLeZHycp83M |
| G9QbnGiv12M1P8dm6Az0YpOBiF7Xpn0AlQpg+3k9pNQZy7WRlb4symFW2ugUNgLV |
| BNkWD7W8D1PiLYoo0ZyDDI/FPNGb1uRwCZ4BfvtbjiMH28XAvxxZwMAySApfP4QV |
| y5UyS6L3olWNpUOFZE/Bgdd3tduCR5xllGAZcugUaN10aXh0EUiubn06i7uf9uQ1 |

*** Personalize Meteorologist 3
#+begin_src sh :var _meteorologist3_crypt=_meteorologist3_crypt

personalize_meteorologist3 () {
  personalize "${_meteorologist3_crypt}"
}
#+end_src

#+name: _meteorologist3_crypt
| U2FsdGVkX19gjPI4DdUhV25638tJvTh2zGck1vrs/MrQJI1ghBVzZu4YK5I3U4fR |
| 96YI2iy5YqVws5f9fPWKYPsEy7Y58Ppl10sHLo/QLmYbWWCPR7HU5sHITnAbtnid |
| wjgJtltscMlbSyn1ekyUz2yFM18I2bdKHklHo68UZet/1f8LnyJSBUhaL9l7sYVK |
| lw1J7xu9A2djc0s7tQYcondLL/sa1OWKXk4kI9IlzD09vTjmmx9U7g+arUV4Z9cB |
| uDkvQFd2W92+G5Da7NdgJJTrgV9hYH+uWznGG/rnTeIpPjyBMEZbIDtOtiq5j1m4 |
| +K2JieiExcX8CUSKPxBQbH/clmRT8dgr+C9BSDi7iJ2yTIvOU6wRGHvNUN9WrlD4 |
| L/0eW8p6B2E74SkvHjmmD7o0UcrWgS1DO0C4dcM8p3FcvZ7Tj1QPwX6i1roTqAQ5 |
| SbeZNE8UsDnaAfFeVtZNElaH3g5XpdONa7x3Q/L56rpANFW9x96HRCAe6zvl6sAj |

*** Personalize Moom
#+begin_src sh :var _moom_crypt=_moom_crypt

personalize_moom () {
  personalize "${_moom_crypt}"
}
#+end_src

#+name: _moom_crypt
| U2FsdGVkX18lU+JpUd5n3lZTfIBCHIyenbkWqcLZDtlQ0xNnzuOnHWEuVzMZTEMO |
| n32zp+nIgCBYCQU8cj1CT/jOKfuQ0bYEqMXls05yi5SfsLuHciUfgOZtaZdIo0HI |
| xi2ozsQaCX9tbxo9l2+l3AS5yE83TYvtWvg2QlTAkkOdPNnnHY7odDNCNICx+aZK |
| u5N9CGeB/Dg9yDtEUUZInmUG6wJ/lgPizNTRVVEfntKrjNGIy23nOHk5wdvuOYZP |
| ENnGfaoT3eBC0k1/0Rb4SBATDjP4EJyR1kiBRaV0Km+uNz5tH91e2Ows6gAWJc+e |
| InOgKTDVAweXmBLxAy5kRTeJAcIkjkAuluu41suzvlAE6e8SSqZXIoptYhNIoLIb |
| TyXgx5Ad16KSxla9HrdMWwCoxKnOwzuZbfmTasOy6g7tP18FdTiawfbwf20ZLdKc |
| 67ksIOfctKHToHee9g8R+4CtwS0bztEfgszzUhV5Q8BGsP+fYjCI64v3VlLKlPRh |
| /7DxoZ5T6Vf9vMM9B3TbEcupmH98Cq+PgZa8TLtjScFTw5rlGTyNC8AAFiJzfipA |
| nDZMcWeyhtep1BhL/LcBcPZja/uwtbNYIMxDwgmQzeyzBqBqzE1AX4St+oM4AQmC |
| bB7xmEZekWw8LhO4vGGxEkoaT+FXt7GZI6hvKjd2biMCs0LqW8OWWgArWsR7BjrP |
| /otPGFZi6RK655O069cEaeVaizxZJ/9kw8QvvRYElh1OzfiQQSfozRwnVghHuk9X |
| u9n8b6MnrRYOojufn9YHltb1UZ6WPEMSk0657TcNZkX5AeWLT6/LF9++/qw37nWr |
| Z0+xTMP4+BUrXRG2qVOy9gtRkWVr/m9Ap/xvs2IymM+sGPK8msCm+Sx2bL/QpMf9 |
| UunICoL9GHCz5iu47bLTVZPYkG8SAnsDzauHMxWxJcJOVrMNfJwLinc3GmWi7OXo |
| 8r/zcFc0vFA6bSym+3+qCgGrWZ3D84Wf4JO15/qej1o3UqvrHZN1XCgGdNoe7QQu |
| fuf003HH98R/KYbM7tnWCKTyr/rqbwNG3EzyM9qWABPsUKhhD4xNDSrAETg0gCcU |
| 17ZV74vWmXpBD6GEAvXtW0WxTFm4mX+SwoqA1YEkDDkAxhMIsG00T3X3OcdG8U8/ |
| NgeKG2PJcPK5ZzdCS1jKWQKh4+oS+UOjdJjH9CvpGnM6Ol/7GtnvjReRBn91qjBs |
| fpVhnmdK3+2+lQsiChCfVH8ZV7scGZqmHrT/Z5B80hxFoHXCBzc4aXqhRP3+8Kwc |
| 8Vdm8BexgPjn/f1h6mZt7V3J5+kaQFItwJgd8f6VYwU40/HVQWgggkBVfb6DFTq2 |
| u+XZ5aZkoM65B4s1HK0bO+Kr8pDxcvcf+O1a53043qPGoAP8l4M2xRHhkKbc2T6Z |
| r1dm7UQuLktwMAY2m4B1bg==                                         |

*** Personalize NZBGet
#+begin_src sh :var _nzbget_crypt=_nzbget_crypt

personalize_nzbget () {
  personalize "${_nzbget_crypt}"
}
#+end_src

#+name: _nzbget_crypt
| U2FsdGVkX18JS7hBuu5P5eeTADOpOz+HabaX/DtndESoj1HX1YElFbxrsrovH9IE |
| +m5jXFF9KgPHIt2ZjUw3H5KmHkix0GeO+ElBFwaGps8pGV6eh3ZqylUGVXc3+7Zt |
| K0DA2PwxAmyiboiUT2MKwjwYk4lt25+aOUxr6/BV1lo7FwQ9PaPkrVKtZYUClDzH |
| 6xLEp9vgAnQlHyTLtSF5XalbdtutBEInej20mGojHFniB4UW14FnH01KzBpCowGv |
| zAA0d8nft1Ubx9wI6XrcBpYpUOX8teJj3hmS06ciiWE7RW/UB2YLXcvEx/hzS2Ye |
| B+tQ5uapM8Ja/ISCcnyAKtNh1WcuKi50PtRo3mXKkxwjJP2pUMWOWe+bhHOX94Z4 |
| yff6KjQTms6BkT0RSpBKzsB98Q/R3G/CNN8Z15u9bP1Owm/9RdkbqoEO2lEang3j |
| vbJwttB2gmXOB68hh0plxoIEhXb32uJu+ULwFa3ho/5I1X93DgPQC4ab/K19vVhE |
| 28aQCYUkDWkFW1Z0VBIKqRKP6cMDzEPpGnz0sxMhU8Ps6KR4Fmt+CGJEOxTvsRb/ |
| D3Y7UeTTvsFxzmlsiPi/24w8pGAx4oXVPL7Q3DLvomdjBmE9EiJrYzCPOjjO/n4H |
| 9YcqjnObUiN9fphZzjiw4knbpzXXvz41eXTPwSSUoBT3Gv+BjpzA2Lx8Q9l5u0aA |
| Txm8dbTsddyGaaWPzJ/c6PAsuI9UqV1h01A4nmRVmk1Q0RPcAXON6IvM5gygtKcN |
| mbfgOf+S1sLNTGXmOxlVV08edHAk1zP3aE/jNTYi2JBeopUC2+9i+3910MEjkbhx |
| 7X0eytMoxHZCaEiLmORTPptouMhflRjbTHoxJJcLEee9p1xOgzxIfI4PzX1d4Jcs |
| gAVpUhQJhfEvCZReHjMQloVDc9Or2kQ5uRIGg7ZD1MRZWsh6BhB/afSEBRibS/HU |
| WQrmAWyFeIClaHIAK/Clbfqe40dV/RI592ROJ3Ng3wP7wpXgQAPotCskHFb2dMTm |
| sNwM1eY1ZgZqtzbCTL4GRUrd2VpoZq417W0HKnr75wctEudn/AOEIp+2l0gOJRKv |
| HBkzUYrfkbgTVcYDcFh8Yr9CurOA6aWQXVHiNvQmr46jQNqvE/dqQZoAbFrngtJH |
| 4H/SgjvuDiocJitIqVUhNBdX5AtasEhByfzCxalZHGIBxEKdqXMugTaLTcj/nB2C |
| TfdZnoTMryqJxLlF/pAEZA==                                         |

*** Personalize NZBVortex
#+begin_src sh :var _nzbvortex_crypt=_nzbvortex_crypt

personalize_nzbvortex () {
  personalize "${_nzbvortex_crypt}"
}
#+end_src

#+name: _nzbvortex_crypt
| U2FsdGVkX1+307HjJGIf7rdVkS4iA3amckwax3cNni3YYdUjVoOa8Dzldh2o4zVc |
| Xv7Wt0rUR434pPu+IeYH+vLqSU4KDibBPT2TZNyv3bcLKNot91E1TWmdEPrxiIPx |
| ZTw6G9ZJlAUdZPK1PL8SN/32wcuQfRyX6d1NHiQ/rsleIedUvcb1Q2L1MJldD9ZU |
| vfIE2TZVQA73h2DQsY/HeZXsGudOVhF1A8S5pFP6goocJ8lgmBF0rS0Z2HZ3h8Po |
| eBMXudhMltv6kApIB2bj39GsECL5fbZUilX83o7tjn89x/eMra4EXwPv7aAlz9dg |
| qr58SoELeC0BySdYr69KiPD13l3KsHRtQv6FBUKPt7iqlw2Ck9JDtpArSKbPXSfE |
| efEfu9JIqd3C0A7nNyzapJhjNx5SQLDsu3HbtXvRvztE4BIj2yjLUywWH7BynEEx |
| 74tVEmEKmHcXVpOm11qxtKznkRole4RF97V3FT36juAYQ++2xambRxsd8APDKnQx |
| x4+uaXLi4A3X2hkxweE4Aw==                                         |

*** Personalize Pacifist
#+begin_src sh :var _pacifist_crypt=_pacifist_crypt

personalize_pacifist () {
  personalize "${_pacifist_crypt}"
}
#+end_src

#+name: _pacifist_crypt
| U2FsdGVkX1/wjLIEMp8Q0VgD8rDKDOmWVnoNS0wYicHRoTehfFThWcVNiJT8SvwI |
| 0X0pkFgRDq5Le+idSjwfKFIMzmgmKLBZNiMMVbJ6WuWAMaYwl70M5LRfAe4vCvUB |
| 4/vRSrH3+OB9k187XLViAgDadJY95T1bZZ/OGuRTiMR6shAe31XMv0DrI4ksNc/2 |
| clLLzhlnaekyFeCKUYaoywH+BMl0r3nGysFsT9UTxujXmw5RjhsRWJXS7YodvCT6 |
| DVXa9I2B7Q6XV/1KzVZNRg83A6u3oXBqHHKVHi/VWnrRfJf6O095F6EeIr54gzu1 |
| EvJ9+a9qvovJZam37q2QrBvpiugbNZcBb0AAVvdscjIVhrdkIpVbdyHiKCO+rugS |
| svGkCw28FBdOKIkXgEjudzmj/uXnWQ/9Ru1YFZw0Pv7iFjrubt4Ujgux5CUf5kfr |
| xdE02nx6TYRBPH6H6fK5IloX1yMDW48CVR/hVLARoSu7rlJTVqd8U27Sx/HhJ625 |
| lcV5Y2kBd7DLKqs3nRIkta90gOxFYCD1G0JYw6dAUSTF7xME9aY5UE8p3ODdmD/8 |

*** Personalize PCalc 3
#+begin_src sh :var _pcalc3_crypt=_pcalc3_crypt

personalize_pcalc3 () {
  personalize "${_pcalc3_crypt}"
}
#+end_src

#+name: _pcalc3_crypt
| U2FsdGVkX1+j54XVyGcpSm/+sDyrrLvt1XqzSIlDSwvLwh8geuJzNPVKOfRHWZK1 |
| bRHEQIavsXUXmCR92vV+JtlV5Un2g29R5hvC0GDieCGghzt41Y5BypUEHP8dzWIB |
| QqNrlqPQ+Wx61AQPVhiIu0y4rocctHx36vArgfuiVlvfYE29APOIJa+0nk3rJ5dB |
| HsSxwDsaAQAl+psbtzfvixxtCaRa0RrgzGr0Nx1RVZNDgEbTM/mWNQH3TlFE6Vo3 |
| jsZIzuUYJwb526KMk8ADC2aKNqh4fufTuWI7nCG+8RXI+t331Ge4KLXjOKsPNdwi |
| UQ58r8HS7O2WqOe8Bmqw+/pBlhjLMEsqzsxSmi+KtYzHH5T5s0hOx2DK9fX65pbv |
| z1t6035CgWuu+U5FezyjaBQX5XZisv51R0pmLh0akNyYKssRn8KQgeaRDmOztHwz |
| Zqfi5MjUUYNPAyYFfY3EUHjzLfnwXKbQz5LNh3LpGq36nsm/NlkgAS4uOsQQuBA7 |
| vj729zsRh36+psJUhA63+JiQbx5uMVjVq3pXXU0c/I/uWYwDwRNtzPUvfQIUJfZv |
| Jjy9pxDOY+ybPdkmkcY+cUbPIExYCkRZkWbeqKCGIijXsJKXA6d5E/snYPa5/ckC |
| zWz2E4RXmOjb3FpL3SL3TTdcpCulVRY47e9kP+P0GHADHOe3YoGEJAdwa0IWzKgC |
| Zoo2qHh+59O5YjucIb7xFcHZkXvuVzJ5J1iLL/91GsS8oPCp6fci66knv2bpJyAe |
| aPk31wCBIlOcIC8Y1JSyLUwZWL6CSu2OUOoqjNB2FgK50Xp/4Y0MkypLBCrq3upa |
| K/jINp0AvPdrQB927lgB6BXkcKfGsRiPySepZ8pYwy1UeN1j58yemjcAtOoKiAYH |
| tVjRjCyW3FspyFr0RDcxiZD+mJSG/5dxujUqpW7oGsfBtDCF1krfccVYDu3KJ1GF |
| CVflh0fAO5em/3RnEyaarbscbV29bjl3cbnUejC2Y1Ofh5WrIrk8dlDNllsJNAdN |
| Zuu6zS4sKFuooMDdzPaVf+YoYgZaOjMhIMTNt5ExsihZOMAr4W4KfGzx02fJHxmC |
| w462hd1SC+7pjJFTjMjEWnBjUfxi6OiZFPnpgYi9H9iijFKSBu1Z4QNJj3y6V1sK |
| xyWmE3/p5Aov6qPy+e7SUe84TF4oVyPQVugtdUxmeVI=                     |

*** Personalize Scrivener
#+begin_src sh :var _scrivener_crypt=_scrivener_crypt

personalize_scrivener () {
  personalize "${_scrivener_crypt}"
}
#+end_src

#+name: _scrivener_crypt
| U2FsdGVkX1/tPt4XjHPDEtcu53cxgt0Q7GDNbNvu1VhXB+/ly+13tuMU9fA1QGm7 |
| 7YBXZ89yhLY15/FzumwHY22T7cU6+y4ULRh5O4weZEX/EyOswJiMYd/MD+mNS+Cf |
| dk5X6P/Y6OGPbFjL9GjfKcJi96UeZCxjf9Og39k3pqBLjTZ0iSaAUhKsTxVY9QAD |
| UPrUmHuzPVrrkVQ5gArcWg==                                         |

*** Personalize SizeUp
#+begin_src sh :var _sizeup_crypt=_sizeup_crypt

personalize_sizeup () {
  personalize "${_sizeup_crypt}"
  test -d "/Applications/SizeUp.app" && \
    open "/Applications/SizeUp.app"
}
#+end_src

#+name: _sizeup_crypt
| U2FsdGVkX1/5orle7q9WUYhaIgZFfM6G+vKsevlp7WxvCSoL/7VGdaXNfGr8yzjy |
| tVfmgCAgnLH1kSGY9Xl90/iTaFJOfITzmRpmirqBzUIQVBojWyANkX9JghEnQaZ/ |
| RWP/uZJ/ftxcc+dH1c/crUayobF/vhqHKuEno5IA9WAa9hdjRYvym59+Sbm2dA+3 |
| +Dd8c2SawJ5MwxUWWxUn9lIg4tRtNdoh75ls7JQfvSIalINDidTxd+f43mRmOlzU |
| 6Dzr2tRLuY6jeLE8JJCsqS1tUI1ADuI7kvrTioAg6pdFYaAqLt3SUjDw0VRZlaE4 |
| 4GtZ+jPZFxoQe9tKpjwcEKXWxQ1aaIZwYDpsPHhdG6BPWHyyuJiAWYhuVUbQA7Zy |
| IcRdQklOJ/25rzzYVCze6qZP/3oKg4CRcZ1nTurb0QG3hC5VKuYOB5UEBlejI0lp |
| iweSpFdwopuXne13bKLfhJGDHz9u1/0f+WW0hVr6SFImbb1jN31GjRpv0yoZH+ia |
| i5cr32WPHj+qYCkA2lWu0rCNUOb1SoG/CvPtqgM+0EzPIU3kokdZP8hLTVIAfo7i |
| UCN1fiNMEYE5hVYf4pPe83EK2QDW1BcVApFn0XI2X9YlEecJTnPKLhD6TR+tUWa9 |
| Qjcni9YYoiVniehkRRJcaIy0iii7h295iUcMApduC9PoN4mwtuNOmzT5L32f+ak2 |
| esIgdF8T4KMQcPrbbu2/+8FLWwLlnlVSe7meaBsxEJW5W7xC6A4kEpownQOMRjJm |
| Zn2y+i49ZwTA2oClXFX3JpIg0P8qvdGM7Fn5OX/0ZqsIe1GsAg2Lbw9/obq2pj0L |
| peb+6JRTXI7gRgygNCIMbihBvEj+ndp+Nu8XUNQGjgm4lknqkulP/xtoi0k45FT0 |
| 1duVXZSOm5heXzTFn0z7FnKNmGCZEXVUDC0gbTPLKeCaKFHsxNTfQ/sY4h/THqRO |
| h5mziRVzPwrOkzl6lzKESTQbvSDwmc2wl5BgMMlwrQGe5F9xrs2sUkhLdpfGG2QL |
| uPhw1AQdRrqH4yU7SAXSpvZFCw3yl7LqEPIDwIn8VuIHfStHYo0ZR1nrMAJkD7Ys |
| +G/E8593amGUWCrAtJWCXlXvlDCcmhMKYPoQHYWQH3JEtkof1J4FFBZ5e85jiLhw |
| KmZj/JA9hvCghBffMEFZUfg2SdrgkPo4XW51qvDyIvCiOVOBgWQ7yRYCSW2LoRyF |
| mihR7MTU30P7GOIf0x6kThAN5yXdWQRNrS/JxjUBk4NqWzfi3svXmZOIVZUbjo7O |
| Sq89IECDpn/5kYeYmMGwEG1j4L5U9PcEHjelZfnQEIIcZZbcONQXXVHk8w1zd/fF |
| wilkne44R/twnneP4QOmU8MTrX7zo10nZo1Sbxigh0tz4I1HoLAKPYAyIIH+NBqw |
| 6FrT8NAo+FQJf87MIYcnftIuX7s/8+9N7mNrVzMeWfWs66L+uNy5yVmYxr1sA2/B |
| 6T+GRoKusYmjLe7ZeRVY5M1L7W6/HqWOJmW0ojRFz1yDtaymlqExuGirq2F88UM8 |
| 6hnJYMJkeYOj0Yn77JT1MIRx2vVuk6JxwmlxGPQwU58os63JNXbRYlc0jJTLu6yo |
| yUFjmw1tO7/oKMbqHoxKCKz4gcm3fWx9PF9ewNgTorbVoAE1vpz8B2EKcJtAkjwk |
| n+XJeNEkZsfZi66sDCzAs7TMQsBq67QLhyBqguhK5vQ=                     |

*** Personalize SteerMouse 5
#+begin_src sh :var _steermouse5_crypt=_steermouse5_crypt

personalize_steermouse5 () {
  personalize "${_steermouse5_crypt}"
  test -d "/Library/PreferencePanes/SteerMouse.prefPane/Contents/MacOS/SteerMouse Manager.app" && \
    osascript -e 'tell app "System Preferences" to reveal pane id "jp.plentycom.prefpane.SteerMouse"' > /dev/null && \
    osascript -e 'tell app "System Preferences" to activate'
}
#+end_src

#+name: _steermouse5_crypt
| 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 |

*** Personalize Tower 2
#+begin_src sh :var _tower2_crypt=_tower2_crypt
personalize_tower2 () {
  personalize "${_tower2_crypt}"
}
#+end_src

#+name: _tower2_crypt
| U2FsdGVkX18oq4VX1emauD73227dbXXMGSeLQUmIsPFyU6+6Q8KFCqbqR7GNsucJ |
| LXv/OdspHtCJXtDlaWtqZd1NHs+ggn25OjlYUtdMUWKVRPgGlOTyHJdatXs5gB5W |
| eAhPiTi2426B/2/EG6oP4yCppBzg2Futx67NPJ+IQjV2FXCA6trV/yFUu8OD4L0G |
| naiVi0l2pCF5Wi1TKNOy/lm9s2+NlCHzRVn7UidI3npHbo2qNPDZaZS/OQ5pW45p |
| san6ZcVOSQnvpe89Zn7ytuc1ya5ndVppyY8ZNC/CeSrXWvGlXgdv3xOaLAIcl0l7 |
| n5DBDW2eKhwcQAc8V5cK1MUHVJpjjChibB5u/XzewMJ5fqB/Foezbppk0C/qB+NG |
| Bky5PkBIMGTZxgmSUm015Q0PaaLzypung1wOeUoW3uooW0JXRjHQ+PMz5a7fSwEF |
| VJnHS5obu6EpOLALMKeHVNr0pebUrZniblnM/ZYpew4CBLS+Ff90ynwAFXqqMQEd |
| SWavfH0nOn6GJGSPaBC7BtsnPP6f8HGzn/zEg2nV4Tdi+2FyKPJGzVpJX/45BGCH |
| tqhtNRuuUjBNtgcKq+lKiM0kdKYqIq5178cAQAjSV2CV7MsxpSk3UVgdV0C/lJlc |
| dp+IGLgewlA26cZ7mAhmF5rGqnEXwK60GJV/wxiixrzMP2yixNNpejgXku0b+rx5 |
| MrIdxFffsNZEEs7Zc9akn1MZpipRSQrwaT89BJ16/plkKiXZPaO4BsLXMqLL3Xui |
| AgBH9f/Hw3eskinf78r/nkx7l/Gs/zrJS2gb2huAOj37DJBakIyfsmyEfNfyHW5P |
| 2nUMynRGLl4vLl3EBYp9X+nbLDqcLz1qllabMqFYwQ75UWlmiAq3PePKdiY9JnzS |
| 3dfX/PCWw1maMxGFmnxjXqNEMwaP9dHypuQKO45WpvZ1lTs0DWysvuMf7TsHmR7B |
| N6dmrGKVzxdmVpIndQSsgwcjAoAq1S2shtoKxmd1ew3+yp+SiEui9hvb+VmsAH8w |
| l4hZRrJOak5+20xeumVQbk7nwz7xdl9K76/jy9RKBXA/3DB2K4iLhkng/vJzAKGz |
| 4w7w9F9bLiZI2j4CSR4Mg9Qs4N2nq3Tr2iON14VXsUtUBmBsDhqCcDneRendQApE |
| Q835k9ZGbhHn4jjc3YXjRK0ZQlJOzpr1Cin1q+R63DZYtonqVLXa3JiquxjH0z1e |
| 90ZFuIABUyCNkpkb7RSwW0aj3gUvX2uKJ1Jm9PRHFzA0Bb/8bDbqN6U/CabExJXk |
| fsMvQhP2ZFamNHARTssD1yL+AQoUjIDFp2FAfID2NwKUazQAMIYDS/zRt7lHVWjn |
| /0N3R2fegJAjaUaFvGBPc++meoCmOOv2A9cOTa1B+omVJiTuLQNFbWzegeZ6of2B |
| dILRTte1UYE1Z/JIDCH0EnoUyH8YvU9fcC+XpvnCrSwWQTUJNylLUF2gDjXIgIti |
| 11rxpV4Hb98TmiwCHJdJeww6ab0qawmU1ScPGH642X7Pwku805gZPuUeVuCunlj7 |
| ZZXp9pjCcuK9jMxRBlgXVVVjomYzeF6Qu8Ld+GMGZks=                     |

*** Personalize Transmit 4
#+begin_src sh :var _transmit4_crypt=_transmit4_crypt
personalize_transmit4 () {
  personalize "${_transmit4_crypt}"
}
#+end_src

#+name: _transmit4_crypt
| U2FsdGVkX1/A63DIwdmh9ZT09vTHrkKyLuzKUoAwLXVzz8W9KGmBUqIUCw0qBEU7 |
| ybcj/Pce96IEQX/T+7dcDuMhZ9+XLFmkgjDWbygTSDyqK1JOf5VSfRbHpFv3IIDT |
| UJzgFiz9bchSACQ39qVigQ==                                         |

*** Personalize Tune4mac
#+begin_src sh :var _tune4mac_crypt=_tune4mac_crypt
personalize_tune4mac () {
  personalize "${_tune4mac_crypt}"
}
#+end_src

#+name: _tune4mac_crypt
| U2FsdGVkX19wxlroNoTkSCFqKoMF+/uM244ExTuMuKN3RtARpy6mL0fDIcsJOA9+ |
| UeireHnKQP//WhCYdvUSEeXI51tiqfO05OiasiD0SkqQEY8okh9s5CJ2a8hErUEJ |
| rhvPgmlrPMvJkm+w1zabOM/DCUBgpfocCTbaZSmkMAVhWXwGHso1gKuLyxBhswQF |
| Mpx+flYNykcvPqr/6/eiB12OgwY2K/GKQJqGslRiO64jrD/mgYx/7tDM6mLwKIxm |
| w4DqWY0f63qEwbxb9Ott5CA3RpR5ocV/WHGvKdji6us=                     |

*** Personalize VMware Fusion 8 Pro
#+begin_src sh :var _vmwarefusion8pro_crypt=_vmwarefusion8pro_crypt
personalize_vmwarefusion8pro () {
  personalize "${_vmwarefusion8pro_crypt}"
}
#+end_src

#+name: _vmwarefusion8pro_crypt
| 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                     |

*** Log Out Then Log Back In
#+begin_src sh
personalize_logout () {
  /usr/bin/read -n 1 -p "Press any key to continue.
" -s
  if run "Log Out Then Log Back In?" "Cancel" "Log Out"; then
    osascript -e 'tell app "loginwindow" to «event aevtrlgo»'
  fi
}
#+end_src
