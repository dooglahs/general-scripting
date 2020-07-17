#!/bin/bash

# IT Functions is an incomplete but ready script that can be run from an MDM system to
# an endpoint as root to run various utilities by techs on the floor. It is an
# interactive menu system with breadcrumbs, containing a series of functions that can
# be called.

# I never finished building all the functionality I wanted, so clean/clear/hack away!

######################################################################################
# Checks, balances, and variables
######################################################################################

# If run locally instead of from an MDM, insure we're running as root
if [[ $EUID -ne 0 ]]; then
	echo "You must run this script as root. Try again with \"sudo\""
	echo ""
	exit 1
fi

# Prevent user from exiting script with cntrl-c. Cleared using the quit option in main menu
trap '' 2

# Required global variables; do not edit
MENU=("Main Menu ")
USER=""

# User variables for functions you may add.
TESTURL="https://www.google.com" # for the networkConnection function

######################################################################################
# Functions that are called from the various menus, or by other functions
# As a rule, the deeper into the menus, the higher the function is listed
######################################################################################

function targetVolume(){
VOLUMES_BASE=$( ls /Volumes/ | grep "Macintosh HD" )
if [[ -n ${VOLUMES_BASE} ]]; then
	TARGET="/Volumes/Macintosh HD"
else
	unset VOLUMES_BASE
	declare -a VOLUMES_BASE
	i=1
	for v in /Volumes/*/private; do
		VOLUMES_BASE[i++]="${v%/*}"
	done
	echo "There are ${#VOLUMES_BASE[@]} volumes to work with."
	echo ""
	LOOP=true
	while [ ${LOOP} = true ]; do
		for((i=1;i<=${#VOLUMES_BASE[@]};i++)); do
		    echo "   [$i] ${VOLUMES_BASE[i]}"
		done
		echo ""
		read -p "Which volume do you want to work with? " CHOICE;
		echo ""
		if [[ ${CHOICE} -le ${#VOLUMES_BASE[@]} ]] && [[ ${CHOICE} -gt 0 ]] && [[ ! -z "${CHOICE}" ]]; then
			TARGET=${VOLUMES_BASE[$CHOICE]}
			break
		else
			echo "Invalid selection. Please try again."
			sleep 1
		fi
		echo ""
	done
fi
unset CHOICE
}

function userName(){
if [[ -z ${USER} ]]; then
	unset WHICH_USER
	declare -a WHICH_USER
	i=1
	# Someday I'll run this with dscl . list /Users | grep -v '_' or better, but not today
	for v in $( ls /Users/ | grep -v 'Shared' ); do
		WHICH_USER[i++]="${v%/*}"
	done
	echo "There are ${#WHICH_USER[@]} potential users, or you can set up a new user."
	WHICH_USER+=('new user')
	echo ""
	LOOP=true
	while [ ${LOOP} = true ]; do
		for((i=1;i<=${#WHICH_USER[@]};i++)); do
		    echo "   $i) ${WHICH_USER[i]}"
		done
		echo ""
		read -p "Which user do you want to work with? " CHOICE;
		echo ""
		if [[ ${CHOICE} -le ${#WHICH_USER[@]} ]] && [[ ${CHOICE} -gt 0 ]] && [[ ! -z "${CHOICE}" ]]; then
			USER=${WHICH_USER[$CHOICE]}
			if [[ ${USER} == "new user" ]]; then
				USER=""
				echo "We need the short username for the person getting this computer. For example: jdoe"
				echo ""
				read -p "Enter the correct short username for the user and press [ENTER]: " USER;
				echo ""
				if [[ ${USER} != "setup" ]]; then
					read -p "What is the Real Name for ${USER}? Use \"Firstname Lastname\" format: " USER_REALNAME;
					echo ""
				else
					USER_REALNAME="Setup"
				fi
			fi
			clear
			break
		else
			echo "Invalid selection. Please try again."
			sleep 1
		fi
		echo ""
	done
fi
unset CHOICE
}

function computerName(){
# We use a specific naming convention for our computers; TAG-USERNAME. You may want to customize yourself
COMPUTERNAME=$( scutil --get ComputerName );
HOSTNAME=$( scutil --get HostName );
LOCALHOSTNAME=$( scutil --get LocalHostName );
echo "ComputerName is: ${COMPUTERNAME}"
echo "HostName is: ${HOSTENAME}"
echo "LocalHostName is: ${LOCALHOSTNAME}"
echo ""
read -p "Would you like to change the name of this computer? Type yes or no and press [ENTER]: " CHANGE;
echo ""
if [[ ${CHANGE} =~ ^([yY][eE][sS]|[yY])$ ]]; then
	if [[ -z ${USER} ]]; then
		userName
	fi
	echo "We need the computer's asset tag number."
	read -p "Enter the tag number: " TAG_ID;
	echo ""
	COMP_NAME=${TAG_ID}-${USER}
	sudo scutil --set ComputerName "${COMPUTERNAME}"
	sudo scutil --set HostName "${COMPUTERNAME}"
	sudo scutil --set LocalHostName "${COMPUTERNAME}"
	sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTERNAME}"
	echo "Computer name set to \"${COMPUTERNAME}\"."
fi
echo ""
}

function serialNumber(){
SERIAL=$( system_profiler SPHardwareDataType | awk '/Serial/ {print $4}' )
echo "Serial number: ${SERIAL}"
#Gets the final set of the serial number to be curled:
ATTRIBSFILE=/System/Library/PrivateFrameworks/ServerInformation.framework/Versions/A/Resources/English.lproj/SIMachineAttributes
if [ -f "${ATTRIBSFILE}.plist" ]; then
    MODELID="$(sysctl -n hw.model)"
    MODEL="$(defaults read "${ATTRIBSFILE}" "${MODELID}" |sed -n -e 's/\\//g' -e 's/.*marketingModel = "\(.*\)";/\1/p')"
    echo "Model version: ${MODEL}"
else
	LAST_CODE=$( ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{ sn=$(NF-1); if (length(sn) == 12) count=3; else if (length(sn) == 11) count=2; print substr(sn, length(sn) - count, length(sn))}' )
	MODEL=$( curl -s http://support-sp.apple.com/sp/product?cc=${LAST_CODE} )
	echo "${MODEL}"
fi
echo ""
}

function pingSweep(){
# This function I didn't get a chance to complete. Ultimately it would have presented your
# local IP and asked if you wanted to use that, else ask you for the class C range.
#get IP range to work with and feed that in below, else assume 10.7.136.x
#for i in {1..254}; do
#	ping -c 1 -W 10 10.7.136.$i | grep 'from'
#done
echo "This will eventually return a bunch of results of active pings across the network."
echo ""
}

function networkConnection(){
unset NETWORK
local URL=$1
URL=$( echo  "${TESTURL}" | sed 's~http[s]*://~~g' )
PINGTEST=$( ping -c 3 "${URL}" | grep "64 bytes" )
echo "Testing for network connection using ping."
if [ ! -z "${PINGTEST}" ]; then
	NETWORK="yes"
	echo "Ping test to \"${URL}\" was successful."
else
	NETWORK="yes"
	echo "Ping test to \"${URL}\" failed. Please check your network connection."
fi
echo ""
}

function menuCrumbs(){
# Creates breadcrumbs at the top of the window
echo "${MENU[@]}"
echo ""
}

# Called from Main Menu
function quitScript(){
	# I'm sure there is a better way to gather all the variables in the script but...
	VARIABLES=(TESTURL SHORTURL URL NETWORK WHICH_USER CHOICE USER USER_REALNAME SERIAL ATTRIBSFILE MODELID MODEL LAST_CODE COMP_NAME COMPUTERNAME HOSTNAME LOCALHOSTNAME CHANGE TAG_ID MENU OPTION)
	for((i=0;i<=${#VARIABLES[@]};i++)); do
	    unset ${VARIABLES[i]}
	done
	unset VARIABLES
	# Re-enable cntrl-c escaping
	trap 2
	clear
	exit
}

######################################################################################
# Menus for the interface
######################################################################################

# Main > General Information > End User Menu
function enduser_menu(){
clear
while true; do
	menuCrumbs
	echo "You need to select a user to work with. If option 2) does not appear start with option 1)"
	echo ""
	echo "  1) Select a new user."
	if [[ -n ${USER} ]]; then
		echo "  2) Continue working with \"${USER}\"."
	fi
	echo "  3) Return to menu"
	echo ""
	echo -n "Enter choice: "
	read OPTION
	echo ""
	case ${OPTION} in
		1 ) USER="" ; userName ;;
		2 ) unset 'MENU[${#MENU[@]}-1]'; general_information_menu ;;
		3 ) unset 'MENU[${#MENU[@]}-1]'; general_information_menu ;;
		* ) echo "";echo "Please enter 1, 2 (if available), or 3"; echo ""; 
	esac
done
}

# Main > General Information Menu
function general_information_menu(){
clear
while true; do
	menuCrumbs
	echo "What information would you like to know?"
	echo ""
	echo "  1) Computer Name"
	echo "  2) Local Serial Number"
	echo "  3) End User"
	echo "  4) Return to menu"
	echo ""
	echo -n "Enter choice: "
	read OPTION
	echo ""
	case ${OPTION} in
		1 ) computerName ;;
		2 ) serialNumber ;;
		3 ) MENU+=('> End User '); enduser_menu ;;
		4 ) unset 'MENU[${#MENU[@]}-1]'; main_menu ;;
		* ) echo "";echo "Please enter 1, 2, 3, or 4"; echo ""; 
	esac
done
}

# Main > Troubleshooting > Network Menu
function network_menu(){
clear
while true; do
	menuCrumbs
	echo "What would you like to do?"
	echo ""
	echo "  1) Ping test"
	echo "  2) Ping sweep"
	echo "  3) Check WiFi"
	echo "  4) Other stuffs"
	echo "  5) Return to Troubleshooting menu"
	echo ""
	echo -n "Enter choice: "
	read OPTION
	echo ""
	case ${OPTION} in
		1 ) networkConnection ${TESTURL} ;;
		2 ) pingSweep ;;
		3 ) echo "function to check the wifi connection runs"; echo "" ;;
		4 ) echo "other functions or menus that are network related"; echo "" ;;
		5 ) unset 'MENU[${#MENU[@]}-1]'; troubleshooting_menu ;;
		* ) echo "";echo "Please enter 1, 2, 3, or 4"; echo ""; 
	esac
done
}

# Main > Troubleshooting Menu
function troubleshooting_menu(){
clear
while true; do
	menuCrumbs
	echo "What would you like to do?"
	echo ""
	echo "  1) Clear caches"
	echo "  2) Fix/Update Binding"
	echo "  3) Networking OPTIONs"
	echo "  4) Return to menu"
	echo ""
	echo -n "Enter choice: "
	read OPTION
	echo ""
	case ${OPTION} in
		1 ) echo "function to clear caches"; echo "" ;;
		2 ) echo "function for binding stuffs"; echo "" ;;
		3 ) MENU+=('> Networking '); network_menu ;;
		4 ) unset 'MENU[${#MENU[@]}-1]'; main_menu ;;
		* ) echo "";echo "Please enter 1, 2, 3, or 4"; echo ""; 
	esac
done
}

# Main Menu
function main_menu(){
clear
while true; do
	menuCrumbs
	echo "What would you like to do?"
	echo ""
	echo "  1) Troubleshooting"
	echo "  2) General Information"
	echo "  3) Quit"
	echo ""
	echo -n "Enter choice: "
	read OPTION
	echo ""
	case ${OPTION} in
		1 ) MENU+=('> Troubleshooting '); troubleshooting_menu ;;
		2 ) MENU+=('> General Information '); general_information_menu ;;
		3 ) quitScript ;;
		* ) echo "";echo "Please enter 1, 2, 3, or 4"; echo ""; 
	esac
done
 }

######################################################################################
# Start of runtime
######################################################################################

echo ""
main_menu