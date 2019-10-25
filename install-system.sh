#!/bin/bash
set -e

if [[ $# -gt 1 ]]; then
    echo "Usage: install.sh [--flash | --no-flash]" >&2
    exit 1
fi

if [[ $# -gt 0 ]]; then
    case "$1" in
        "--flash")
            flash=true
            ;;
        "--no-flash")
            flash=false
            ;;
        *)
            echo "Usage: install.sh [--flash | --no-flash]" >&2
            exit 1
            ;;
    esac
else
    echo "Would you like to install Adobe Flash Player? (Only required for crawls with Flash) [y,N]"
    read -s -n 1 response
    if [[ $response = "" ]] || [ $response == 'n' ] || [ $response == 'N' ]; then
        flash=false
        echo Not installing Adobe Flash Plugin
    elif [ $response == 'y' ] || [ $response == 'Y' ]; then
        flash=true
        echo Installing Adobe Flash Plugin
    else
        echo Unrecognized response, exiting
        exit 1
    fi
fi

if [ "$flash" = true ]; then
    pacman -S --needed flashplayer
fi

yes | sudo pacman -S --needed firefox htop git python libxml2 libxslt libffi openssl base-devel boost leveldb libjpeg curl wget bash vim
 
if [ "$flash" = true ]; then
    yes | sudo pacman -S --needed flashplugin
fi

# Use the Unbranded build that corresponds to a specific Firefox version (source: https://wiki.mozilla.org/Add-ons/Extension_Signing#Unbranded_Builds)
# UNBRANDED_FF68_RELEASE_LINUX_BUILD="https://queue.taskcluster.net/v1/task/HYGMEM_UT06yMsOpWtHyVQ/runs/0/artifacts/public/build/target.tar.bz2"
# wget "$UNBRANDED_FF68_RELEASE_LINUX_BUILD"
UNBRANDED_FF69_RELEASE_LINUX_BUILD="https://queue.taskcluster.net/v1/task/TSw-9H80SrqYLYJIYTXGVg/runs/0/artifacts/public/build/target.tar.bz2"
wget "$UNBRANDED_FF69_RELEASE_LINUX_BUILD"
tar jxf target.tar.bz2
rm -rf firefox-bin
mv firefox firefox-bin
rm target.tar.bz2

# Selenium 3.3+ requires a 'geckodriver' helper executable, which is not yet
# packaged.
GECKODRIVER_VERSION=0.24.0
case $(uname -m) in
    (x86_64)
        GECKODRIVER_ARCH=linux64
        ;;
    (*)
        echo Platform $(uname -m) not known to be supported by geckodriver >&2
        exit 1
        ;;
esac
wget https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-${GECKODRIVER_ARCH}.tar.gz
tar zxf geckodriver-v${GECKODRIVER_VERSION}-${GECKODRIVER_ARCH}.tar.gz
rm geckodriver-v${GECKODRIVER_VERSION}-${GECKODRIVER_ARCH}.tar.gz
mv geckodriver firefox-bin
