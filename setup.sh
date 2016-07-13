#!/bin/bash

# OSX workstation bootstrap - https://github.com/markhuge/bootstrap-osx

# inspired by https://github.com/drduh/OS-X-Security-and-Privacy-Guide

# Install xcode
xcode-select --install

## Homebrew ##

# Disable homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# Install homebrew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install eocker
brew update
brew install Cask

# Firewall/Alerting
brew cask install security-growler
brew cask install little-snitch # I own a license. Change based on your prefs

 ## Docker ##
brew Cask install docker
read -n1 -r -p '[30;48;5;82mGo start docker so the rest of this doesnt get pissed..[0m' key
# Setup X11 for docker
brew install socat
brew install Caskroom/cask/xquartz

## DNSSEC ##
echo "Installing DNSSEC..."
  brew install dnsmasq --with-dnssec
  mkdir -p /usr/local/etc
  cp etc/dnsmasq.conf /usr/local/etc/dnsmasq.conf
  sudo cp -fv /usr/local/opt/dnsmasq/*.plist /Library/LaunchDaemons
  sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
  sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist

echo "Checking DNSMASQ..."
  dnsmasq_check=$(sudo lsof -ni UDP:53)
  if [[ $dnsmasq_check  ]]; then
    echo "DNSMASQ is running"
    echo "$dnsmasq_check"
  else
    echo "DNSMASQ failed! EXITING"
    exit 1
  fi

# Set use local DNS resolver
sudo networksetup -setdnsservers "Wi-Fi" 127.0.0.1

echo "Checking DNSSEC..."
  dig_test=$(dig +dnssec icann.org|grep NOERROR)
  
  if [[ $dig_test == *"NOERROR"* ]]; then
    echo "DNSSEC Worky"
  else
    echo "DNSSEC failed to dig. EXITING!"
    exit 1
  fi
 
# dnscrypt
# TODO setup personal resolver
echo "Installing dnscrypt"

brew install dnscrypt-proxy
sudo cp -fv /usr/local/opt/dnscrypt-proxy/*.plist /Library/LaunchDaemons
sudo chown root /Library/LaunchDaemons/homebrew.mxcl.dnscrypt-proxy.plist
echo "Configuring dnscrypt for dnsmasq"
sudo gsed -i "/sbin\\/dnscrypt-proxy<\\/string>/a<string>--local-address=127.0.0.1:5355<\\/string>\n" /Library/LaunchDaemons/homebrew.mxcl.dnscrypt-proxy.plist

echo "Launching dnscrypt"
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.dnscrypt-proxy.plist

echo "Checking dnscrypt..."
  dnscrypt_check=$(sudo lsof -ni UDP:5355)
  if [[ $dnscrypt_check ]]; then
    echo "dnscrypt is running"
    echo "$dnscrypt_check"
  else
    echo "dnscrypt failed! EXITING"
    echo "Try rebooting and run again. dnscrypt service is a little flaky the first time"
    exit 1
  fi
## Openssl ##

brew install openssl
brew install curl --with-openssl
brew link --force curl

## Wifi ##
# Disable captive portal
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control Active -bool false

## Privoxy ##
# TODO change config to not force tor
echo "Setting up privoxy"
docker pull jess/privoxy

echo "Starting prixovy..."
docker run -d --restart always -p 8118:8118 --name privoxy jess/privoxy

echo "checking privoxy"
  privoxy_check=$(ALL_PROXY=127.0.0.1:8118 curl -I http://p.p/)
  if [[ $privoxy_check == *"200 OK"* ]]; then
    echo "privoxy working!"
  else
    echo "privoxy failed"
  fi
