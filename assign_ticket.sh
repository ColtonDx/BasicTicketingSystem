#!/bin/bash

# Load configuration
source /ticket/application/config


# Backoff function
backoff() {
    sleep $backoff
    backoff=$((backoff + 2))
}

while [ $attempt -le $max_attempts ]; do
    if mkdir "$lockdir"; then
        echo "Connected to the Server."
        echo "ASSIGN" > /ticket/application/addaticket
        if read response < /ticket/application/ticketresponse; then
           echo $response
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
