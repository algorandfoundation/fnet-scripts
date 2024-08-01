#!/usr/bin/env bash


# This script will run after an automated reset due to a network reset/genesis change
# If you want to automate any "network bootstrap" actions such as registering participation keys or funding accounts, you can do this here

# Requirement: schedule /check-update.sh to run on regular intervals

# Example: wait for funds, send keyreg online

cd "$(dirname "$(realpath "$0")")"

source utils/_common.sh

# --------------8<------------- #
# EXAMPLES follow               #
#                               #
# CHANGE ME AFTER THIS LINE     #
# and remove exit 0             #
# --------------8<------------- #

exit 0

# Example KMD commands may fail if your default wallet is password protected. Adapt to your use case.

# KMD persists, but for the sake of this example:
echo 'buyer cancel food diary opinion silent forget belt caution glove unlock clap cool defense grief autumn example mushroom series volcano couch miracle popular absorb ride' | goal account import

# utility to wait for address to have at least 100 ALGO. Assumes something will fund it
./utils/wait_for_balance.sh B7MRZ23W2PXP2NPG5S4VSKLOFSVXCIJERQ4RUKK53KQ3BMIF7D6YZH3I3Q 100000000

# Example: send some ALGO
goal clerk send --from B7MRZ23W2PXP2NPG5S4VSKLOFSVXCIJERQ4RUKK53KQ3BMIF7D6YZH3I3Q --to DI3INONU2PBZCZG4FEE5KJTBJTOC5KWTSG772NSTBS3VZC7MQAGMKCOF3A --amount 13

# Example: register online
# assumes a particiaption key was pre-generated with algokey 
#   and placed in /var/lib/algorand/fnet-v1/
# Note: 2A fee for incentives eligibility
goal account changeonlinestatus -a B7MRZ23W2PXP2NPG5S4VSKLOFSVXCIJERQ4RUKK53KQ3BMIF7D6YZH3I3Q -o=1 --fee 2000000
