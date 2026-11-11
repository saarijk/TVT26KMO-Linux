#!/usr/bin/env bash

# define paths
REPORT_DIR="/var/www/html/viikko3"
TEMP_FILE="/tmp/viikko3_report.html"

# collect information
GENERATED_AT="$(date '+%Y-%m-%d %H:%M:%S %Z')"
UPTIME_TEXT="$(uptime -p)"
DISK_USAGE="$(df -P / | awk 'NR==2 {print $5}')"
MEM_TOTAL="$(free -m | awk 'NR==2 {print $2}')"
MEM_AVAILABLE="$(free -m | awk 'NR==2 {print $7}')"

# function to determine disk space status
check_disk_status() {
    local usage="$1"
    local percent="${usage%\%}"  # Poista %-merkki
    if [ "$percent" -ge 80 ]; then
        echo "WARNING"
    else
        echo "OK"
    fi
}

# call function
DISK_STATUS="$(check_disk_status "$DISK_USAGE")"

# check directory exists
mkdir -p "$REPORT_DIR"

# create HTML report
cat > "$TEMP_FILE" <<EOF
<!DOCTYPE html>
<html>
<head><title>Viikko 3 - Server Status</title></head>
<body>
<h1>Server Status Report</h1>
<p>Generated: $GENERATED_AT</p>
<p>Uptime: $UPTIME_TEXT</p>
<p>Disk usage: $DISK_USAGE</p>
<p>Disk status: $DISK_STATUS</p>
<p>Total RAM: $MEM_TOTAL MiB</p>
<p>Available RAM: $MEM_AVAILABLE MiB</p>
</body>
</html>
EOF

# move file to final location
mv "$TEMP_FILE" "$REPORT_DIR/index.html"