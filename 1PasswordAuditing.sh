#!/bin/bash

# 1Password auditing script. Designed to pull groups and their members, and vaults with the groups and users that have access.
# 1Password command line documentation: https://support.1password.com/command-line-reference/
# sleep commands in the for loops added after I hit 1Password with too many requests and was blocked as
#	potentially suspicious.

# Remember to log in to op before starting this process:
#	eval $(op signin virtru)
# Needs a method of creating the GROUP and VAULT arrays automatically from
#	op list groups | op get group -
#	op list vaults | op get vault -
# Needs a method of cleaning up the text files to be proper CSV, perhaps with headers.

# Add your group and vaults to the arrays. Single quote items with spaces.
GROUP=(Vault 'Vault Number 2' VaultThree 'Fourth Vault')
VAULT=('Group One' Group2 'ThirdVault' 4thVault)

OLDPWD=$( pwd )

mkdir 1P-Audit && cd 1P-Audit

# List all Users
mkdir Users && cd Users
op list users | op get user - > "Users.txt"
cd ..

# List the Users in each Group.
mkdir Groups && cd Groups
sleep 5
for i in "${GROUP[@]}"; do
	op list users --group "${i}" | op get user - > "${i}.txt"
	sleep 3
done
cd ..

# For each Vault list the Groups and Users that have access.
mkdir Vaults && cd Vaults
mkdir GroupAccess && cd GroupAccess
for i in "${VAULT[@]}"; do
	op list groups --vault "${i}" | op get group - > "${i}.txt"
	sleep 3
done
# the default admin group has commas in the descriptor, which is snafu if you want to use this for CSV so:
sed -i 's/users, groups, and vaults/users groups and vaults/g' *
cd ..
mkdir UserAccess && cd UserAccess
for i in "${VAULT[@]}"; do
	op list users --vault "${i}" | op get user - >> "${i}-users.txt"
	sleep 3
done
cd .. && cd ..

cd "${OLDPWD}"

exit 0
