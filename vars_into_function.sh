#!/bin/zsh

# Files to search for in an array
Term_Items=(
	"One.docx"
	"Two.xlsx"
	"Three.plist"
	"Four.md"
	"test.sh"
)

# Current user
CURRENT_USER=$( stat -f "%Su" /dev/console )

# Function that will search for the Term_Items
function TermFunction(){
	if ls "$1"/"$2"/"$3" 1> /dev/null 2>&1; then
		echo "$3 exists on $2."
	else
		echo "$3 does NOT exist on $2."
	fi   
}

# Run the loop with $1, $2, and $3 fed to the function
for TERM in "${Term_Items[@]}"; do
	TermFunction "/Users/${CURRENT_USER}" "Desktop" "${TERM}"
done

exit 0
