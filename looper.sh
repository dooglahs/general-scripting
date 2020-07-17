#!/bin/bash -x

# Demonstration of how a script can continue to run between reboots to do
#	sequential tasks and store variables between reboots as well.
# Run the script from the location of your choice; I use a USB stick.

#----------------------------------------------------------------------------------------#

##### This is the administrative stuff that has to happen on each pass

# Insure script is run as sudo initially

if [[ $EUID -ne 0 ]]; then
	echo "You must run this script as root. Try again with \"sudo\""
	echo ""
	exit 1
fi


# Create persistent source file
# This file contains variables for use in the script between reboots

echo " " >> /usr/local/looper.txt
source /usr/local/looper.txt

#----------------------------------------------------------------------------------------#
#          --------------------------------------------------------------------          #
#                    ------------------------------------------------                    #
#                              ----------------------------                              #
#                                        --------                                        #
#---------------------------------- FIRST PASS SECTION ----------------------------------#

if [[ ${FIRST_PASS_DONE} != yes ]]; then
# Put all the tasks you want done in the first pass here
echo "Doing first pass tasks..." >> /usr/local/looper.txt

# Create the LaunchDaemon that will load the script after reboot

cat > /Library/LaunchDaemons/com.company.looper.plist <<LAUNCHDAEMON
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.company.looper</string>
	<key>Program</key>
	<string>/usr/local/looper.sh</string>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
LAUNCHDAEMON
chmod 644 /Library/LaunchDaemons/com.company.looper.plist
chown root:wheel /Library/LaunchDaemons/com.company.looper.plist
echo "   Created LaunchDaemon." >> /usr/local/looper.txt

# Copy this script to the computer so it can be used on reboot

# Function finds the path to the script without dirname or basename
scriptPath() {
	[ ${1:0:1} == '/' ] && x=$1 || x=${PWD}/$1
	cd "${x%/*}"
	echo $( pwd -P )/${x##*/}
}
SCRIPT_PATH=$( scriptPath "${BASH_SOURCE[0]}" )
SCRIPT_PATH=${SCRIPT_PATH%/*}
cp "${SCRIPT_PATH}"/looper.sh /usr/local/looper.sh
chown root:wheel /usr/local/looper.sh
chmod +x /usr/local/looper.sh
echo "   Copied script to /user/local." >> /usr/local/looper.txt

echo "...First pass tasks are done." >> /usr/local/looper.txt
echo "FIRST_PASS_DONE=\"yes\"" >> /usr/local/looper.txt

reboot

else
	echo "First pass tasks already completed." >> /usr/local/looper.txt
# you should be done with all the tasks you wanted done in the first pass above this line
fi #fi to close out FIRST_PASS_DONE

#----------------------------------------------------------------------------------------#
#          --------------------------------------------------------------------          #
#                    ------------------------------------------------                    #
#                              ----------------------------                              #
#                                        --------                                        #
#---------------------------------- SECOND PASS SECTION ---------------------------------#

if [[ ${SECOND_PASS_DONE} != "yes" ]]; then

echo "Doing second pass tasks..." >> /usr/local/looper.txt

# Put all the tasks you want done on the SECOND PASS here
echo "   Statement of task done." >> /usr/local/looper.txt

echo "...Second pass tasks are done." >> /usr/local/looper.txt
echo "SECOND_PASS_DONE=\"yes\"" >> /usr/local/looper.txt

reboot

else
	echo "Second pass tasks already completed." >> /usr/local/looper.txt
fi #fi to close out SECOND_PASS_DONE

#----------------------------------------------------------------------------------------#
#          --------------------------------------------------------------------          #
#                    ------------------------------------------------                    #
#                              ----------------------------                              #
#                                        --------                                        #
#----------------------------------- THIRD PASS SECTION ---------------------------------#

if [[ ${THIRD_PASS_DONE} != "yes" ]]; then

echo "Doing third pass tasks..." >> /usr/local/looper.txt

# Put all the tasks you want to do on the THIRD PASS here.
echo "   Statement of task done." >> /usr/local/looper.txt

echo "...Third pass tasks are done." >> /usr/local/looper.txt
echo "THIRD_PASS_DONE=\"yes\"" >> /usr/local/looper.txt

reboot

else
	echo "Third pass tasks already completed." >> /usr/local/looper.txt
fi #fi to close out THIRD_PASS_DONE

#----------------------------------------------------------------------------------------#
#          --------------------------------------------------------------------          #
#                    ------------------------------------------------                    #
#                              ----------------------------                              #
#                                        --------                                        #
#-------------------------------------- END SCRIPT --------------------------------------#

# You could choose to add a final round of tasks here

echo "Cleaning up; deleting files associated with the looper script." >> /usr/local/looper.txt

# Remove the files associated with this script

rm -fr /Library/LaunchDaemons/com.company.looper.plist
sleep 1
rm -fr /usr/local/looper.sh
sleep 1

# If you choose to remove this file, comment the "echo" and "open" lines below.
# rm -fr /usr/local/looper.txt
echo "The looping script is done and this line should only appear once, at the end" >> /usr/local/looper.txt
open /usr/local/looper.txt

exit 0