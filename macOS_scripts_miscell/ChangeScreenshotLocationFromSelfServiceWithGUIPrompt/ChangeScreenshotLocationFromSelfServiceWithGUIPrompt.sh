#!/bin/bash
####################################################################################################
# REFERENCE: https://macmule.com/2013/07/13/change-screenshot-location-from-self-service-with-gui-prompt/
# 
# License: https://macmule.com/license/
# The MIT License (MIT)
# 
# Copyright (c) 2013 macmule
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the “Software”), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################

###
# Get the Username of the logged in user
###
loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

###
# Prompt the user for the location of the folder that they wish screen shots to be created in
###
folderPath=$(osascript -e 'try
tell application "SystemUIServer"
   choose folder with prompt "Which folder would like screenshots to go to? (the default location is your Desktop)"
  set folderPath to POSIX path of result
end
end')

# Echo chosen location
echo "User has chosen $folderPath..."

# Update User plist
defaults write /Users/"$loggedInUser"/Library/Preferences/com.apple.screencapture location "$folderPath"

# As we're root, amend ownership back to set for plist
chown "$loggedInUser" /Users/"$loggedInUser"/Library/Preferences/com.apple.screencapture.plist

# Correct the file mode
chmod 755 /Users/"$loggedInUser"/Library/Preferences/com.apple.screencapture.plist

# Restart SystemUIServer for changes to take affect
killall SystemUIServer

exit 0