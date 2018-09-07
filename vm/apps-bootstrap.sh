#!/usr/bin/env bash

# Inspired by the scripts in the ONOS project and at the same time
# Largely inspired by the P4.org tutorial VM scripts:
# https://github.com/p4lang/tutorials/


set -xe

#Sublime requirements
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

#Atom requirements
sudo add-apt-repository ppa:webupd8team/atom -y

sudo apt-get update

# Wireshark requirement
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure wireshark-common

#Chrome
mkdir -p ~/Downloads
cd ~/Downloads
wget https://dl.google.com/linux/linux_signing_key.pub
sudo apt-key add linux_signing_key.pub
rm linux_signing_key.pub

echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' \
     | sudo tee -a /etc/apt/sources.list

sudo apt-get update

# Lubuntu desktop and some applications
sudo apt-get -y --no-install-recommends install \
    lubuntu-desktop \
    atom \
    gdebi \
    google-chrome-stable \
    sublime-text \
    terminator \
    vim \
    wget

# Guest additions
sudo apt-get -y --no-install-recommends install \
    linux-headers-$(uname -r) \
    build-essential \
    dkms


# Disable screensaver
sudo apt-get -y remove light-locker

# Automatically log into the student user
cat << EOF | sudo tee -a /etc/lightdm/lightdm.conf.d/10-lightdm.conf
[SeatDefaults]
autologin-user=student
autologin-user-timeout=0
user-session=Lubuntu
EOF

# Vim
cd /home/student
mkdir -p .vim
mkdir -p .vim/ftdetect
mkdir -p .vim/syntax
echo "au BufRead,BufNewFile *.p4      set filetype=p4" >> .vim/ftdetect/p4.vim
echo "set bg=dark" >> .vimrc
wget https://github.com/p4lang/tutorials/blob/master/vm/p4.vim
mv p4.vim .vim/syntax/p4.vim

# Sublime
cd /home/student
mkdir -p ~/.config/sublime-text-3/Packages/
cd .config/sublime-text-3/Packages/
git clone https://github.com/c3m3gyanesh/p4-syntax-highlighter.git

# Atom
apm install language-p4

#Intellij Toolbox
cd ~/Downloads
wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.8.3868.tar.gz
tar -xvzf jetbrains-toolbox-1.8.3868.tar.gz
rm jetbrains-toolbox-1.8.3868.tar.gz

#Gitkraken
cd ~/Downloads
wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
sudo dpkg -i gitkraken-amd64.deb
rm gitkraken-amd64.deb

# Adding Desktop icons
DESKTOP=/home/student/Desktop
mkdir -p ${DESKTOP}

cat > ${DESKTOP}/Terminal << EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Terminal
Name[en_US]=Terminal
Icon=konsole
Exec=/usr/bin/x-terminal-emulator
Comment[en_US]=
EOF

cat > ${DESKTOP}/Wireshark << EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Wireshark
Name[en_US]=Wireshark
Icon=wireshark
Exec=/usr/bin/wireshark
Comment[en_US]=
EOF

cat > ${DESKTOP}/Sublime\ Text << EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Sublime Text
Name[en_US]=Sublime Text
Icon=sublime-text
Exec=/opt/sublime_text/sublime_text
Comment[en_US]=
EOF

cat > ${DESKTOP}/Atom << EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=Atom
Name[en_US]=Atom
Icon=atom
Exec=/usr/bin/atom
Comment[en_US]=
EOF

cat > ${DESKTOP}/Google\ Chrome << EOF
[Desktop Entry]
Encoding=UTF-8
Name=Google Ghrome
Name[en_US]=Google Chrome
Exec=/usr/bin/google-chrome-stable %U
Terminal=false
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
EOF

cat > ${DESKTOP}/Terminator << EOF
[Desktop Entry]
Name=Terminator
Name[en_US]=Terminator
Comment=Multiple terminals in one window
TryExec=terminator
Exec=terminator
Icon=terminator
Type=Application
Categories=GNOME;GTK;Utility;TerminalEmulator;System;
StartupNotify=true
X-Ubuntu-Gettext-Domain=terminator
X-Ayatana-Desktop-Shortcuts=NewWindow;
Keywords=terminal;shell;prompt;command;commandline;
[NewWindow Shortcut Group]
Name=Open a New Window
Exec=terminator
TargetEnvironment=Unity
EOF

#VBoxGuestAdditions
response=$(curl -o /dev/null -Isw '%{http_code}\n'\
 https://download.virtualbox.org/virtualbox/5.2.12/VBoxGuestAdditions_5.2.12.iso)
if [[ "$response" -eq 200 ]] ; then
  set +e
  cd ~
  wget -c https://download.virtualbox.org/virtualbox/5.2.12/VBoxGuestAdditions_5.2.12.iso \
                       -O VBoxGuestAdditions_5.2.12.iso
  sudo mount VBoxGuestAdditions_5.2.12.iso -o loop /mnt
  cd /mnt
  sudo sh VBoxLinuxAdditions.run
  cd ~
  sudo umount /mnt
  rm *.iso
  set -e
fi
