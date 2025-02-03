#!/usr/bin/env bash
#
# disk_monitor.sh
#
# Purpose: Periodically checks the storage usage of the root partition (/) 
#          on an Ubuntu server, and sends notifications to a Discord webhook 
#          if usage thresholds are exceeded. Also optionally notifies on script start.
#

#########################
# Configurable Variables
#########################

# Percentage threshold for first warning
FIRST_WARNING_PERCENT=70

# Percentage threshold for second (critical) warning
SECOND_WARNING_PERCENT=90

# Whether to send a notification to Discord when the script is started (true/false)
NOTIFY_START=true

# Interval (in seconds) for how often to check storage usage
CHECK_INTERVAL=3600  # 1 hour

# Discord Webhook URL
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/your-webhook-id/your-webhook-token"

#########################
# End of Configurable Variables
#########################

# Make sure FIRST_WARNING_PERCENT < SECOND_WARNING_PERCENT is logical
if [ "$FIRST_WARNING_PERCENT" -ge "$SECOND_WARNING_PERCENT" ]; then
  echo "Error: FIRST_WARNING_PERCENT should be less than SECOND_WARNING_PERCENT."
  exit 1
fi

# Function to send a Discord message with a specified color, title, and description.
# color is an integer (decimal) representing an RGB hex color. Example: 
#   Red   = 16711680
#   Yellow= 16776960
#   Green = 65280
send_discord_message() {
  local color="$1"
  local title="$2"
  local description="$3"

  # Construct the JSON payload. 
  # Note: We use @everyone in the content to mention everyone in the channel.
  curl -s -H "Content-Type: application/json" -X POST \
    -d "{
      \"content\": \"@everyone\",
      \"embeds\": [
        {
          \"title\": \"$title\",
          \"description\": \"$description\",
          \"color\": $color
        }
      ]
    }" "$DISCORD_WEBHOOK_URL" > /dev/null
}

# If NOTIFY_START is true, send a notification to confirm the script is running
if [ "$NOTIFY_START" = "true" ]; then
  send_discord_message \
    65280 \
    "Disk Monitor Started" \
    "Monitoring started on $(hostname). Will check every $CHECK_INTERVAL seconds."
fi

# Main monitoring loop
while true
do
  # Get the usage percentage of the root partition (without the '%')
  usage=$(df -h / --output=pcent | tail -1 | tr -dc '0-9')

  if [ "$usage" -ge "$SECOND_WARNING_PERCENT" ]; then
    # Critical warning
    send_discord_message \
      16711680 \
      "Disk Usage Critical on $(hostname)" \
      "Root partition is at ${usage}% capacity!"
  elif [ "$usage" -ge "$FIRST_WARNING_PERCENT" ]; then
    # First warning
    send_discord_message \
      16776960 \
      "Disk Usage Warning on $(hostname)" \
      "Root partition is at ${usage}% capacity."
  fi

  # Sleep until the next check
  sleep "$CHECK_INTERVAL"
done
