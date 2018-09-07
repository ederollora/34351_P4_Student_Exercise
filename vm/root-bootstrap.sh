#!/bin/bash
set -xe

# Create user student

useradd -m -d /home/student -s /bin/bash student
echo "student:student" | chpasswd
echo "student ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99_student
chmod 440 /etc/sudoers.d/99_student
usermod -aG vboxsf student
update-locale LC_ALL="en_US.UTF-8"

# Java 8, may not be ncessary but let's get it
apt-get install software-properties-common -y
add-apt-repository ppa:webupd8team/java -y
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections


apt-get -y --no-install-recommends install \
    avahi-daemon \
    curl \
    bridge-utils \
    emacs \
    git \
    git-review \
    htop \
    nano \
    ntp \
    oracle-java8-installer \
    oracle-java8-set-default \
    python2.7 \
    python2.7-dev \
    tcpdump \
    unzip \
    valgrind \
    vim \
    vlan \
    zip \


curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python2.7 get-pip.py --force-reinstall
rm -f get-pip.py

tee -a /etc/ssh/sshd_config <<EOF

UseDNS no
EOF

su student <<'EOF'
cd /home/student
bash /vagrant/p4-bootstrap.sh
EOF

su student <<'EOF'
cd /home/student
bash /vagrant/sim-bootstrap.sh
EOF

su student <<'EOF'
cd /home/student
bash /vagrant/p4-bootstrap.sh
EOF

su student <<'EOF'
cd /home/student
bash /vagrant/apps-bootstrap.sh
EOF
