#!/bin/bash

exec 1>>/var/log/fwcld.log
exec 2>>/var/log/fwcld.log

# using mdfind, find all instances of an app.
# if app is located in /Applications, then compare installed version with a version level.
# (version level is defined by this variable: $if_app_is_below_this_version_then_delete_it)
# if installed app version < version level, then it is "old" and must be deleted.
# if installed app version > or = version level, then leave it alone.
# if app is in a non-standard path (i.e. outside /Applications), then delete the app.

################################################################################
# FUNCTIONS
#################################################################################
# reference for functions: https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash

vercomp () 
{
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

testvercomp () 
{
	# $1 = $if_app_is_below_this_version_then_delete_it (defined later), #2 installed version
    vercomp $1 $2
    case $? in
        0) 	writelog "installed app is same version compared to version we are checking against" ;;
        1) 	writelog "installed app is OLDER version compared to version we are checking against"
			writelog "pretending to delete..."
			# rm -rf "$file"
			;;
        2) writelog "installed app is NEWER version compared to version we are checking against" ;;
    esac
}

# -----------------------------------------------------------------------------
# Add context to log messages
# -----------------------------------------------------------------------------
writelog() 
{
    DATE=$( date "+%Y-%m-%d %H:%M:%S %Z" )
    echo "$DATE" " $1"
}

printed-line ()
{
echo "# -----------------------------------------------------------------------------"
}
################################################################################
# SCRIPT
#################################################################################

theDate=$( date "+%Y-%m-%d %H:%M:%S %Z" )

echo "#---------------------------------------------------------------"
echo "# Date: $theDate"
echo "# Fileset: 450_UCI - Delete Google Chrome - non-standard installation paths"
echo "# using mdfind, find all instances of an app."
echo "# if app is in a non-standard path (i.e. outside /Applications), then delete the app."
echo "#---------------------------------------------------------------"

# Find and delete all instances of Google Chrome.app

if_app_is_below_this_version_then_delete_it="114.0.5735.106"

mdfind kind:application "Google Chrome.app" | while read -r  file; do
printed-line
	if [[ "$file" == "/Applications/Google Chrome.app" ]]; then
			writelog "we found /Applications/Google Chrome.app"
			version_installed_app=$(defaults read "$file/Contents/Info.plist" CFBundleShortVersionString)
			writelog "Google Chrome version: $version_installed_app"
			# $1 = version level, #2 installed version of app
			# writelog "let's do version check... delete any version below $if_app_is_below_this_version_then_delete_it..."
			# testvercomp "$if_app_is_below_this_version_then_delete_it" "$version_installed_app"
		else
			writelog "found app in non-standard path..."
			writelog "path is $file, do deleting non-standard installation..."
			# writelog "pretending to delete..."
			rm -rf "$file"
	fi

done

