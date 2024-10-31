#!/bin/bash

# Load configuration
source /ticket/application/config

echo "Enter the issue description:"
read issue_description
echo "ADD $issue_description" > $addpipe

# Backoff function
backoff() {
    sleep $backoff
    backoff=$((backoff + 2))
}

while [ $attempt -le $max_attempts ]; do
    if mkdir "$lockdir"; then
        echo "Connected to Server"
        if read response < "$responsepipe"; then
            echo "$response"
            rmdir "$lockdir"
            break  # Exit the loop if successful
        fi
    else
        echo "Failed to acquire lock"
        attempt=$((attempt + 1))
        backoff
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "Failed to connect to the server after $max_attempts attempts."
fi
