#!/bin/bash
set -xe

# Create user student
useradd -m -d /home/student -s /bin/bash student
echo "student:student" | chpasswd
echo "student ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_student
chmod 440 /etc/sudoers.d/99_student
usermod -aG vboxsf student
update-locale LC_ALL="en_US.UTF-8"

# Java 8
apt-get install software-properties-common -y
add-apt-repository ppa:webupd8team/java -y
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections

KERNEL=$(uname -r)
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get -y --no-install-recommends install \
    arping \
    avahi-daemon \
    curl \
    bridge-utils \
    emacs \
    git \
    git-review \
    htop \
    lubuntu-desktop \
    nano \
    ntp \
    oracle-java8-installer \
    oracle-java8-set-default \
    python \
    python-dev \
    python-ipaddr \
    python-pip \
    python-scapy \
    python-setuptools \
    tcpdump \
    unzip \
    valgrind \
    vim \
    vlan \
    zip

tee -a /etc/ssh/sshd_config <<EOF

UseDNS no
EOF

# wallpaper
cd /usr/share/lubuntu/wallpapers/
cp /home/vagrant/p4-logo.png .
rm lubuntu-default-wallpaper.png
ln -s p4-logo.png lubuntu-default-wallpaper.png
rm /home/vagrant/p4-logo.png
cd /home/vagrant
sed -i s@#background=@background=/usr/share/lubuntu/wallpapers/1604-lubuntu-default-wallpaper.png@ /etc/lightdm/lightdm-gtk-greeter.conf

# Automatically log into the student user
cat << EOF | tee -a /etc/lightdm/lightdm.conf.d/10-lightdm.conf
[SeatDefaults]
autologin-user=student
autologin-user-timeout=0
user-session=Lubuntu
EOF

# Disable screensaver
sudo apt-get -y remove light-locker

cp /etc/skel/.bashrc /home/student
cp /etc/skel/.profile /home/student
cp /etc/skel/.bash_logout /home/student

su student <<'EOF'
cd /home/student
bash /vagrant/p4-bootstrap.sh
EOF

su student <<'EOF'
cd /home/student
bash /vagrant/user-bootstrap.sh
EOF
