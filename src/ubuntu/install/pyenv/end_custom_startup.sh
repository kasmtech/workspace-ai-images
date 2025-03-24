
# Function to handle termination gracefully
cleanup() {
    echo -e "\nScript terminated."
    exit 0
}

# Set up trap to catch SIGINT (Ctrl+C) and SIGTERM
trap cleanup SIGINT SIGTERM

# Main loop that sleeps most of the time
while true; do
    # Sleep for 60 seconds
    # During sleep, the process consumes almost no CPU
    sleep 60

    # Optional: print a timestamp to show it's still running
    # Comment this out if you want completely silent operation
    echo "Still running: $(date)"
done