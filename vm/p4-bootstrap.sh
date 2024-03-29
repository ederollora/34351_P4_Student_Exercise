#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Builds and installs all tools needed for developing and testing P4 support in
# ONOS.
#
# Tested on Ubuntu 14.04 and 16.04.
#
# Recommended minimum system requirements:
# 4 GB of RAM
# 2 cores
# 8 GB free hard drive space (~4 GB to build everything)
# -----------------------------------------------------------------------------

# Exit on errors.
set -e

BUILD_DIR=~/p4tools
#BMV2_COMMIT="ed130d01be985d814c17de949839d484e76400b1"
#PI_COMMIT="59c940916b4f5b182f33b4788d8c410972eaecce"
#P4C_COMMIT="618d15155dcc2d784cc14a8e83131b407cf893e2"
MININET_COMMIT="master"
BMV2_COMMIT="7e25eeb19d01eee1a8e982dc7ee90ee438c10a05"
PI_COMMIT="219b3d67299ec09b49f433d7341049256ab5f512"
P4C_COMMIT="48a57a6ae4f96961b74bd13f6bdeac5add7bb815"
PROTOBUF_COMMIT="tags/v3.2.0"
GRPC_COMMIT="tags/v1.3.2"
LIBYANG_COMMIT="v0.14-r1"
SYSREPO_COMMIT="v0.7.2"
P4RT_TEST_COMMIT="master"

NUM_CORES=`grep -c ^processor /proc/cpuinfo`

KERNEL=$(uname -r)
# DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

function do_requirements {
    sudo apt update
    sudo apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bison \
        build-essential \
        cmake \
        cpp \
        emacs24 \
        flex \
        libavl-dev \
        libboost-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-test-dev \
        libboost-thread-dev \
        libc6-dev \
        libev-dev \
        libevent-dev \
        libffi-dev \
        libfl-dev \
        libgc-dev \
        libgc1c2 \
        libgflags-dev \
        libgmp-dev \
        libgmp10 \
        libgmpxx4ldbl \
        libjudy-dev \
        libpcap-dev \
        libpcre3-dev \
        libreadline6 \
        libreadline6-dev \
        libssl-dev \
        libtool \
        linux-headers-$KERNEL \
        make \
        mktemp \
        pkg-config \
        protobuf-c-compiler \
        wget \
        xcscope-el \
        xterm

    #sudo -H pip install setuptools cffi grpcio scapy ipaddr
}

function do_requirements_1404 {
    sudo apt install -y python-software-properties software-properties-common
    sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
    sudo add-apt-repository -y ppa:george-edison55/cmake-3.x
    sudo apt update
    sudo apt install -y \
        dpkg-dev \
        g++-4.9 \
        gcc-4.9 \
        cmake \
        libbz2-dev

    # Needed for p4c.
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 50
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 50

    if [ -z "$(ldconfig -p | grep libboost_iostreams.so.1.58.0)"  ]; then
        do_boost
    fi
}

function do_boost {
    cd ${BUILD_DIR}
    wget https://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.bz2/download -O boost_1_58_0.tar.bz2
    tar --bzip2 -xf boost_1_58_0.tar.bz2
    cd boost_1_58_0

    ./bootstrap.sh --with-libraries=iostreams
    sudo ./b2 install
    sudo ldconfig

    cd ..
    sudo rm -rf boost_1_58_0
}

function do_requirements_1604 {
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends \
        ca-certificates \
        g++ \
        libboost-iostreams1.58-dev \
        libprotobuf-c-dev
}

function do_mininet {

  # Mininet
  git clone git://github.com/mininet/mininet mininet
  cd mininet
  sudo ./util/install.sh -nwv
  cd ..

}

function do_protobuf {
    cd ${BUILD_DIR}
    if [ ! -d protobuf ]; then
      git clone https://github.com/google/protobuf.git
    fi
    cd protobuf
    git fetch
    git checkout ${PROTOBUF_COMMIT}

    export CFLAGS="-Os"
    export CXXFLAGS="-Os"
    export LDFLAGS="-Wl,-s"
    ./autogen.sh
    ./configure --prefix=/usr
    make -j${NUM_CORES}
    sudo make install
    sudo ldconfig
    unset CFLAGS CXXFLAGS LDFLAGS
    # force install python module
    cd python
    sudo python setup.py install
}

function do_grpc {
    cd ${BUILD_DIR}
    if [ ! -d grpc ]; then
      git clone https://github.com/grpc/grpc.git
    fi
    cd grpc
    git fetch
    git checkout ${GRPC_COMMIT}
    git submodule update --init --recursive

    export LDFLAGS="-Wl,-s"
    make -j${NUM_CORES}
    sudo make install
    sudo ldconfig
    unset LDFLAGS
    cd ..
    # Install gRPC Python Package
    sudo pip install grpcio
}

function do_pi_bmv2_deps {
    checkout_bmv2
    # From bmv2's install_deps.sh.
    # Nanomsg is required also by p4runtime.
    tmpdir=`mktemp -d -p .`
    cd ${tmpdir}
    bash ../travis/install-thrift.sh
    bash ../travis/install-nanomsg.sh
    sudo ldconfig
    bash ../travis/install-nnpy.sh
    cd ..
    sudo rm -rf $tmpdir
}

function checkout_bmv2 {
    cd ${BUILD_DIR}
    if [ ! -d bmv2 ]; then
        git clone https://github.com/p4lang/behavioral-model.git bmv2
    fi
    cd bmv2
    git fetch
    git checkout ${BMV2_COMMIT}
}

function do_p4runtime {
    cd ${BUILD_DIR}
    if [ ! -d p4runtime ]; then
        git clone https://github.com/p4lang/PI.git p4runtime
    fi
    cd p4runtime
    git fetch
    git checkout ${PI_COMMIT}
    git submodule update --init --recursive

    # FIXME: re-enable --with-sysrepo when gNMI support becomes more stable
    # ./configure --with-proto --with-sysrepo 'CXXFLAGS=-O0 -g'
    # ./configure --with-proto 'CXXFLAGS=-O0 -g'
    ./autogen.sh
    ./configure --with-proto
    make -j${NUM_CORES}
    sudo make install
    sudo ldconfig

    # FIXME: re-enable when gNMI support becomes more stable
    # sudo proto/sysrepo/install_yangs.sh
}

function do_bmv2 {
    checkout_bmv2

    ./autogen.sh
    #./configure --enable-debugger --with-pi 'CXXFLAGS=-O0 -g'
    ./configure --enable-debugger --with-pi
    make -j${NUM_CORES}
    sudo make install
    sudo ldconfig

    # Simple_switch_grpc target
    cd targets/simple_switch_grpc
    ./autogen.sh

    # FIXME: re-enable --with-sysrepo when gNMI support becomes more stable
    # ./configure --with-sysrepo --with-thrift 'CXXFLAGS=-O0 -g'
    # ./configure --with-thrift 'CXXFLAGS=-O0 -g'
    ./configure --with-thrift
    make -j${NUM_CORES}
    sudo make install
    sudo ldconfig
}

function do_p4c {
    cd ${BUILD_DIR}
    if [ ! -d p4c ]; then
        git clone https://github.com/p4lang/p4c.git
    fi
    cd p4c
    git fetch
    git checkout ${P4C_COMMIT}
    git submodule update --init --recursive

    mkdir -p build
    cd build
    cmake ..
    make -j${NUM_CORES}
    #make -j${NUM_CORES} check
    sudo make install
    sudo ldconfig
}

#START OF NOT EXECUTED FUNCTIONS AT THIS MOMENT
function do_p4rt_test {
    cd ${BUILD_DIR}
    if [ ! -d p4rt-test ]; then
        git clone https://github.com/TakeshiTseng/P4-runtime-test-tool.git p4rt-test
    fi
    cd p4rt-test
    git pull origin master

    sudo rm -f /usr/local/bin/p4rt-test
    sudo ln -s ${BUILD_DIR}/p4rt-test/main.py /usr/local/bin/p4rt-test
}

function do_libyang {
    cd ${BUILD_DIR}
    if [ ! -d libyang ]; then
      git clone https://github.com/CESNET/libyang.git
    fi
    cd libyang
    git fetch
    git checkout ${LIBYANG_COMMIT}

    mkdir -p build
    cd build
    cmake ..
    make -j${NUM_CORES}
    sudo make install
    sudo ldconfig
}

function do_sysrepo {
    do_sysrepo_deps

    cd ${BUILD_DIR}
    if [ ! -d sysrepo ]; then
      git clone https://github.com/sysrepo/sysrepo.git
    fi
    cd sysrepo
    git fetch
    git checkout ${SYSREPO_COMMIT}

    mkdir -p build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=Off \
        -DCALL_TARGET_BINS_DIRECTLY=Off ..
    make -j${NUM_CORES}
    sudo make install
    sudo ldconfig
}

function do_sysrepo_deps {
    RELEASE=`lsb_release -rs`
    if version_ge $RELEASE 14.04 && [ -z "$(ldconfig -p | grep libprotobuf-c)"  ]; then
        do_protobuf-c
    fi
}

function do_protobuf-c {
    cd ${BUILD_DIR}
    git clone https://github.com/protobuf-c/protobuf-c.git
    cd protobuf-c

    ./autogen.sh
    ./configure --prefix=/usr
    make -j${NUM_CORES}
    sudo make install
    sudo ldconfig

    cd ..
    sudo rm -rf protobuf-c
}

function check_commit {
    if [ ! -e $2 ]; then
        return 0 # true
    fi
    if [[ $(< $2) != "$1" ]]; then
        return 0 # true
    fi
    return 1 # false
}

# END OF NOT EXECUTED FUNCTIONS

# The following is borrowed from Mininet's util/install.sh
function version_ge {
    # sort -V sorts by *version number*
    latest=`printf "$1\n$2" | sort -V | tail -1`
    # If $1 is latest version, then $1 >= $2
    [ "$1" == "$latest" ]
}

MUST_DO_ALL=false
DID_REQUIREMENTS=false

function check_and_do {
    # Check if the latest built commit is the same we are trying to build now,
    # or if all projects must be built. If true builds this project.
    commit_id="$1"
    proj_dir="$2"
    func_name="$3"
    simple_name="$4"
    if [ ${MUST_DO_ALL} = true ] \
        || [ ${commit_id} = "master" ] \
        || check_commit ${commit_id} ${proj_dir}/.last_built_commit; then
        echo "#"
        echo "# Building ${simple_name} (${commit_id})"
        echo "#"
        # Print commands used to install to aid debugging
        set -x
        if ! ${DID_REQUIREMENTS} = true; then
            do_requirements
            # TODO consider other Linux distros; presently this script assumes
            # that it is running on Ubuntu.
            RELEASE=`lsb_release -rs`
            if version_ge $RELEASE 16.04; then
                do_requirements_1604
            elif version_ge $RELEASE 14.04; then
                do_requirements_1404
            else
                echo "Ubuntu version $RELEASE is not supported"
                exit 1
            fi
            DID_REQUIREMENTS=true
        fi
        eval ${func_name}
        echo ${commit_id} > ${BUILD_DIR}/${proj_dir}/.last_built_commit
        # Build all next projects as they might depend on this one.
        MUST_DO_ALL=true
        # Disable printing to reduce output
        set +x
    else
        echo "${proj_dir} is up to date (commit ${commit_id})"
    fi
}

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
# In dependency order.
check_and_do ${MININET_COMMIT} mininet do_mininet mininet
check_and_do ${PROTOBUF_COMMIT} protobuf do_protobuf protobuf
check_and_do ${GRPC_COMMIT} grpc do_grpc grpc
# FIXME: re-enable when gNMI support becomes more stable
# check_and_do ${LIBYANG_COMMIT} libyang do_libyang libyang
# check_and_do ${SYSREPO_COMMIT} sysrepo do_sysrepo sysrepo
check_and_do ${BMV2_COMMIT} bmv2 do_pi_bmv2_deps bmv2-deps
check_and_do ${PI_COMMIT} p4runtime do_p4runtime p4runtime
check_and_do ${BMV2_COMMIT} bmv2 do_bmv2 bmv2
check_and_do ${P4C_COMMIT} p4c do_p4c p4c
#check_and_do ${P4RT_TEST_COMMIT} p4rt-test do_p4rt_test p4rt-test

echo "Done!"
