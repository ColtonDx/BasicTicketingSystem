#!/bin/bash

# Load configuration
source /ticket/application/config

echo "Enter the issue description:"
read issue_description
echo "ADD $issue_description" > $addpipe

# backoff
backoff() {
    sleep $backoff
    backoff=$((backoff / 2))
}

# Create the lock file if it doesn't exist
if [ ! -f "$lockpath" ]; then
    echo $$ > "$lockpath"
fi

# Read the PID from the lock file
lock_pid=$(cat "$lockpath")

# Check if the PID in the lock file matches the current PID
while [ "$lock_pid" -ne "$$" ] && [ $attempt -le $max_attempts ]; do
    echo "Server is busy. Trying again shortly."
    attempt=$((attempt + 1))
    backoff
    lock_pid=$(cat "$lockpath")
done

if [ "$lock_pid" -eq "$$" ]; then
    echo "Connected to the Server."
    if read response <$responsepipe; then
    echo "$response"
    rm -rf $lockpath
fi

else
    echo "Server Appears to be VERY busy. Please try again later."
    exit 1
fi
