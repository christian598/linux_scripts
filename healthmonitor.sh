#!/bin/bash

LOG_FILE="/var/log/server_health.log"
EMAIL="cccc203@gmail.com" # Problem with using Gmail. Test setting up SMTP ?

sudo touch "$LOG_FILE"
sudo chown $USER:$USER "$LOG_FILE"

# Get metrics
disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
mem_usage=$(free | awk '/Mem/{printf("%.0f"), $3/$2 * 100}')
cpu_usage=$(top -bn2 | grep "Cpu(s)" | tail -n1 | awk '{print 100 - $8}' | cut -d. -f1)

# Log timestamp
{
    echo "$(date '+%Y-%m-%d %H:%M:%S')"
    echo "Disk usage: ${disk_usage}%"
    echo "Memory usage: ${mem_usage}%"
    echo "CPU usage: ${cpu_usage}%"
} >> "$LOG_FILE"

# Mail
send_alert() {
    subject="$1"
    body="$2"
    echo "$body" | mail -s "$subject" "$EMAIL"
}

# Alerts
if [ "$disk_usage" -gt 90 ]; then
    alert_msg="ALERT: Disk usage is above 90% (Current: ${disk_usage}%)"
    echo "$alert_msg" >> "$LOG_FILE"
    send_alert "Server Alert: High Disk Usage" "$alert_msg"
fi

if [ "$mem_usage" -gt 80 ]; then
    alert_msg="ALERT: Memory usage is above 80% (Current: ${mem_usage}%)"
    echo "$alert_msg" >> "$LOG_FILE"
    send_alert "Server Alert: High Memory Usage" "$alert_msg"
fi

if [ "$cpu_usage" -gt 85 ]; then
    alert_msg="ALERT: CPU usage is above 85% (Current: ${cpu_usage}%)"
    echo "$alert_msg" >> "$LOG_FILE"
    send_alert "Server Alert: High CPU Usage" "$alert_msg"
fi

echo "" >> "$LOG_FILE"