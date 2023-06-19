#!/bin/bash

#-----------------------------------------------------------------------------------------
# Purpose:
# To determine if a computer is properly bound to Active Directory (AD)
#-----------------------------------------------------------------------------------------
# History:
# Possible future improvements
#	- maybe add code to unbind, then rebind, if computer proves to be not properly bound
#
# 2019-05-10 SMA, initial draft
#-----------------------------------------------------------------------------------------
# References
# bbot, https://www.jamf.com/jamf-nation/discussions/14864/lost-connection-to-active-directory
#
#-----------------------------------------------------------------------------------------
# Set Variables
#-----------------------------------------------------------------------------------------

# theDate=$( date "+%Y-%m-%d %H:%M:%S %Z" )

#-----------------------------------------------------------------------------------------
# Set Functions
#-----------------------------------------------------------------------------------------
# n/a

#-----------------------------------------------------------------------------------------
# Run script
#-----------------------------------------------------------------------------------------

# Check if Mac is on the network
# echo "#----------------------------------------------"
# echo "# Date: $theDate"
# echo "# Starting Active Directory (AD) Healthcheck..."
# echo "# Check if Mac is on the network..."
# echo "#----------------------------------------------"
if ping -c 2 -o CORP.NET &>/dev/null; then
          # echo "ANSWER: Yes. On the network."
          # echo "#----------------------------------------"
          # echo "# Check if has correct dsconfigad info..."
          # echo "#----------------------------------------"
          if [[ $(dsconfigad -show | awk '/Active Directory Domain/{ print $NF }') == "CORP.NET ]]; then
              ADCompName=$(dsconfigad -show | awk '/Computer Account/{ print $NF }')
              ## Mac has correct dsconfigad info
                              # echo "ANSWER: Yes. Correct dsconfigad info."
                              # echo "#-------------------------------------"
                              # echo "# Check if AD keychain entry exists..."
                              # echo "#-------------------------------------"
                              security find-generic-password -l "/Active Directory/CORP" | grep "Active Directory" &>/dev/null
                              if [ "$?" == "0" ]; then
                                  ## AD keychain entry exists
                                  # echo "ANSWER: Yes. AD keychain entry exists."
                                  # echo "#----------------------------"
                                  # echo "# Check if AD entry exists..."
                                  # echo "#----------------------------"
                                  dscl "/Active Directory/CORP/All Domains" read /Computers/"${ADCompName}" | grep -i "${ADCompName}" &>/dev/null
                                        if [ "$?" == "0" ]; then
                                                  ## Found AD entry. Binding is good
                                                  # echo "ANSWER: Yes. AD entry exists."
                                                  # echo "######## SUMMARY ########"
                                                  # echo "AD Binding is good."
                                                  # echo "AD Healthcheck PASSED."
                                                  res="Bound"
                                            else
                                                  # echo "ANSWER: No. AD entry does NOT exist."
                                                  res="NotBound-ADentryNOTexist"
                                        fi
                                  else
                                      # echo "ANSWER: No. AD keychain entry does NOT exist."
                                      res="NotBound-ADkeychainEntryNOTexist"
                              fi
              else
                  # echo "ANSWER: No. dsconfigad entry is NOT correct."
                  res="NotBound-dsconfigadEntryNOTcorrect"
          fi
    else
        # echo "ANSWER: Mac is not on the network."
        res="Mac is not on the network."
fi

echo "$res"

# reset the time from the domain, then force unbind if bound

# if [[ $res == "Not bound" ]]; then
#
#     /usr/sbin/systemsetup -setusingnetworktime off
#     /usr/sbin/systemsetup -setnetworktimeserver "domaincontroller.company.com"
#     /usr/sbin/systemsetup -setusingnetworktime on
#     sleep 10
#
#     /usr/sbin/dsconfigad -remove -force -username macimaging -password $4
#     sleep 10
#     echo "Unbinding"
#     killall opendirectoryd
#     sleep 5
#
# ## Testing has shown that unbinding twice may be necessary.
#     /usr/sbin/dsconfigad -remove -force -username macimaging -password $4 &> /dev/null
#     sleep 10
#     echo "Unbinding twice just incase"
#
# ## Begin rebinding process
#
#     #Basic variables
#     computerid=`scutil --get LocalHostName`
#     domain=domaincontroller.company.com
#     udn=account
#     ou="CN=Computers,DC=DOMAIN,DC=DOMAIN,DC=us"
#
#     #Advanced variables
#     alldomains="disable"
#     localhome="enable"
#     protocol="smb"
#     mobile="enable"
#     mobileconfirm="disable"
#     user_shell="/bin/bash"
#     admingroups="Corp\Helpdesk"
#     namespace="domain"
#     packetsign="allow"
#     packetencrypt="allow"
#     useuncpath="disable"
#     passinterval="90"
#
#     # Bind to AD
#     /usr/sbin/dsconfigad -add $domain -alldomains $alldomains -username $udn -password $4 -computer $computerid -ou "$ou" -force -packetencrypt $packetencrypt
#     sleep 1
#     echo "Rebinding to AD and setting advanced options"
#
#     #set advanced options
#     /usr/sbin/dsconfigad -localhome $localhome
#     sleep 1
#     /usr/sbin/dsconfigad -groups "$admingroups"
#     sleep 1
#     /usr/sbin/dsconfigad -mobile $mobile
#     sleep 1
#     /usr/sbin/dsconfigad -mobileconfirm $mobileconfirm
#     sleep 1
#     /usr/sbin/dsconfigad -alldomains $alldomains
#     sleep 1
#     /usr/sbin/dsconfigad -useuncpath "$useuncpath"
#     sleep 1
#     /usr/sbin/dsconfigad -protocol $protocol
#     sleep 1
#     /usr/sbin/dsconfigad -shell $user_shell
#     sleep 1
#     /usr/sbin/dsconfigad -passinterval $passinterval
#     sleep 1
#
#     #dsconfigad adds "All Domains"
#     # Set the search paths to "custom"
#     dscl /Search -create / SearchPolicy CSPSearchPath
#     dscl /Search/Contacts -create / SearchPolicy CSPSearchPath
#
#     sleep 1
#
#     # Add the "corp.tlcinternal.us" search paths
#     dscl /Search -append / CSPSearchPath "/Active Directory/CORP/domaincontroller.company.com"
#     dscl /Search/Contacts -append / CSPSearchPath "/Active Directory/CORP/domaincontroller.company.com"
#
#     sleep 1
#
#     # Delete the "All Domains" search paths
#     dscl /Search -delete / CSPSearchPath "/Active Directory/CORP/All Domains"
#     dscl /Search/Contacts -delete / CSPSearchPath "/Active Directory/CORP/All Domains"
#
#     sleep 1
#
#     # Restart opendirectoryd
#     killall opendirectoryd
#     sleep 5
# else
#     echo "Mac is already bound. Exiting."
# fi

exit 0
