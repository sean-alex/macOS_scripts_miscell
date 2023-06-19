#!/usr/bin/python

# REFERENCE: https://apple.stackexchange.com/questions/123730/is-there-a-way-to-detect-what-program-is-stealing-focus-on-my-mac
# added parentheses in call to 'print'.
# Start running the script – it will print out the name of the active app every 3 seconds. 
# Keep working as usual, wait for the problem to occur, and after a few seconds see the output in the terminal. 
# You’ll have your culprit.

from AppKit import NSWorkspace
import time
t = range(1,100)
for i in t:
    time.sleep(3)
    activeAppName = NSWorkspace.sharedWorkspace().activeApplication()['NSApplicationName']
    print(activeAppName)