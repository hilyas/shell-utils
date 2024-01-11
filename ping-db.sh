#!/bin/bash

# Check if the connection string is passed as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 '<connection-string>'"
    exit 1
fi

# PostgreSQL connection command
PG_COMMAND="psql $1 -c 'SELECT 1'"

# Function to get current time
function current_time {
  date "+%Y-%m-%d %H:%M:%S"
}

# Initialize previous status
PREV_STATUS=0

while true; do
    # Try to connect to PostgreSQL
    if eval $PG_COMMAND &>/dev/null; then
        # Connection successful
        echo "$(current_time): Connected successfully"
        PREV_STATUS=1
    else
        # Connection failed
        echo "$(current_time): Connection failed"
        if [ $PREV_STATUS -ne 0 ]; then
            # If previous status was success, log the start of downtime
            echo "$(current_time): Downtime started"
        fi
        PREV_STATUS=0
    fi

    # Wait for 2 seconds
    sleep 2
done
