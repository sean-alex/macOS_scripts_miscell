#!/bin/bash

# NoMAD 1.4 - Demobilization

# install pkg
installer -pkg /private/var/tmp/NoMAD-Login-AD-1.4.0.pkg -target /

# sleep 2
sleep 2

# use xattr to recursively eliminate com.apple.quarantine from /Library/Security/SecurityAgentPlugins
xattr -r -d com.apple.quarantine /Library/Security/SecurityAgentPlugins

# insert the demobilization mechanism
/usr/local/bin/authchanger -reset -demobilize

# enabling the demobilization
defaults write /Library/Preferences/menu.nomad.login.ad.plist DemobilizeUsers -bool true