#!/bin/bash

# Parallel processes in script form. Based on how & will throw things in the background.
# Demo shows a variety of ways to make this work, with function, linebreak, and single lines.
# $! is the last launched process' PID

# Function to be called for Process1
function Proc1() {
	sleep 3
	echo "ONE"
}

# Create PID array for nuking all processes as desired.
declare -a PID=()

# Start Process1
Proc1 \
&
PID1=$! && PID+=(${PID1})

# Start Process2
sleep 2 && \
	echo "TWO" \
&
PID2=$! && PID+=(${PID2})

# Wait until Process1 is completed before starting anything after
#	Useful if you need a process to complete before continuation
#wait ${PID1}

# Start Process3
sleep 1 && echo "THREE" &
PID3=$! && PID+=(${PID3})

# Wait for all remaining jobs to finish before continuing to further actions
wait
# If you want to wait only until a specific thing above completed before continuing
#wait ${PID3}

# List all of the process IDs
#echo "Process1 PID = ${PID1}" && echo "Process2 PID = ${PID2}" && echo "Process3 PID = ${PID3}"
#echo "PIDS are: ${PID[@]}"

sleep 1 && echo "Finished"

wait #always best to have if you've specified a PID to wait for above
exit 0
