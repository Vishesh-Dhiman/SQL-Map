#!/bin/bash

# Function to check if a port is in use
is_port_in_use() {
  if lsof -i :$1 >/dev/null; then
    return 0  # port is in use
  else
    return 1  # port is available
  fi
}

# List of default ports to check
PORTS=(8082 8083 8084 8085)
SELECTED_PORT=""

# Find the first available port
for PORT in "${PORTS[@]}"; do
  if ! is_port_in_use "$PORT"; then
    SELECTED_PORT=$PORT
    break
  fi
done

# If no port found in the list, exit with an error
if [ -z "$SELECTED_PORT" ]; then
  echo "No default ports (8082-8085) are available. Please close an application or specify another port."
  exit 1
fi

# Notify the user about the available port
echo "Port $SELECTED_PORT is available."

# Wait 10 seconds in the background without showing countdown
echo -n "You have 10 seconds to choose (Press 'C' to continue or 'O' to specify another port)..."
sleep 10  # 10-second wait

# Clear the line after waiting (removes countdown)
echo ""

# Prompt the user to confirm or choose another port
echo "Press 'C' to continue with port $SELECTED_PORT, or 'O' to specify another port."
read -n 1 choice
echo ""

# Handle the user's choice
if [[ "$choice" == "O" || "$choice" == "o" ]]; then
  while true; do
    read -p "Enter the port you'd like to use: " user_port
    if ! [[ "$user_port" =~ ^[0-9]+$ ]]; then
      echo "Invalid input. Please enter a numeric port."
    elif is_port_in_use "$user_port"; then
      echo "Port $user_port is already in use. Please choose another."
    else
      SELECTED_PORT=$user_port
      break
    fi
  done
fi

echo "Starting HTTP server on port $SELECTED_PORT..."
python3 -m http.server "$SELECTED_PORT" &

# Open Firefox with the chosen port
firefox "http://localhost:$SELECTED_PORT" &
