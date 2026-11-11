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
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Linux Server - Week 3</title>
    <style>
    :root {
      color-scheme: light;
      --page: #f4f6ef;
      --surface: #fffefa;
      --surface-soft: #eef2e8;
      --ink: #252b24;
      --muted: #60695d;
      --green-900: #263d19;
      --green-800: #365525;
      --green-700: #4e7137;
      --green-100: #e5eddc;
      --line: #d9dfd2;
      --blue-700: #315c70;
      --shadow: 0 12px 34px rgb(38 61 25 / 7%), 0 2px 8px rgb(38 61 25 / 4%);
      font-family: "Segoe UI", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
    }

    * { box-sizing: border-box; }

    body {
      max-width: 860px;
      margin: 0 auto;
      padding: 52px 24px 40px;
      background: var(--page);
      color: var(--ink);
      font-size: 16px;
      line-height: 1.7;
    }

    header { margin: 0 0 30px; padding: 0 4px; }

    .eyebrow {
      margin: 0 0 8px;
      color: var(--green-700);
      font-size: .76rem;
      font-weight: 700;
      letter-spacing: .12em;
      text-transform: uppercase;
    }

    h1, h2, h3 { line-height: 1.3; }

    h1 {
      margin: 0;
      padding-bottom: 13px;
      border-bottom: 2px solid var(--green-800);
      color: var(--green-900);
      font-size: clamp(1.8rem, 4vw, 2.25rem);
      letter-spacing: -.035em;
    }

    header > p:last-child { margin: 13px 0 0; color: var(--muted); }

    section {
      margin: 18px 0;
      padding: 26px 30px;
      border: 1px solid rgb(217 223 210 / 80%);
      border-radius: 12px;
      background: var(--surface);
      box-shadow: var(--shadow);
    }

    h2 {
      margin: 0 0 18px;
      color: var(--green-800);
      font-size: 1.3rem;
      letter-spacing: -.02em;
    }

    h3 { margin: 25px 0 8px; color: var(--green-900); font-size: 1.04rem; }
    h3:first-of-type { margin-top: 20px; }
    p { margin: 12px 0; }

    .table-container {
      overflow-x: auto;
      margin: 18px 0;
      border: 1px solid var(--line);
      border-radius: 8px;
      scrollbar-color: var(--green-700) var(--surface-soft);
    }

    table { width: 100%; border-collapse: collapse; text-align: left; }
    th, td { padding: 11px 14px; border-bottom: 1px solid var(--line); vertical-align: top; }
    tr:last-child th, tr:last-child td { border-bottom: 0; }
    thead th { background: var(--green-100); color: var(--green-900); font-size: .9rem; font-weight: 700; }
    tbody th { width: 48%; background: #fbfcf8; color: #3e4939; font-weight: 600; }
    td { color: var(--ink); }

    code {
      padding: .12em .38em;
      border: 1px solid #e2e6dc;
      border-radius: 4px;
      background: #f0f2ec;
      color: #34452b;
      font-family: ui-monospace, "SFMono-Regular", Consolas, "Liberation Mono", monospace;
      font-size: .88em;
      overflow-wrap: anywhere;
    }

    ul { padding-left: 1.35rem; }
    li { margin: 9px 0; padding-left: 2px; }
    .note { margin-top: 18px; padding: 13px 15px; border-left: 3px solid var(--green-700); border-radius: 0 6px 6px 0; background: var(--surface-soft); color: #485343; }
    a { color: var(--blue-700); text-decoration-thickness: 1px; text-underline-offset: 3px; }
    a:hover { color: var(--green-800); }
    a:focus-visible { outline: 3px solid #8eaa70; outline-offset: 3px; border-radius: 2px; }

    footer { padding: 12px 4px; text-align: center; }
    footer p { margin: 0; }

    @media (max-width: 600px) {
      body { padding: 30px 15px 24px; font-size: 15px; }
      section { margin: 14px 0; padding: 21px 18px; }
      th, td { padding: 10px; }
      tbody th { min-width: 145px; }
    }

    @media (prefers-reduced-motion: no-preference) {
      a { transition: color 140ms ease; }
    }
  </style>
</head>
<body>
    <header>
        <p class="eyebrow">Linux · Week 3</p>
        <h1>Server Status Report</h1>
        <p>Week 3: Linux command line and Bash scripting</p>
        <p>TODO: Add your own introduction.</p>
    </header>
    <main>
    <section aria-labelledby="status-heading">
      <h2 id="status-heading">Current server status</h2>
      <div class="table-container">
        <table>
          <thead><tr><th scope="col">Information</th><th scope="col">Value</th></tr></thead>
          <tbody>
            <tr><th scope="row">Report generated</th><td>$GENERATED_AT</td></tr>
            <tr><th scope="row">Server uptime</th><td>$UPTIME_TEXT</td></tr>
            <tr><th scope="row">Root filesystem disk usage</th><td>$DISK_USAGE</td></tr>
            <tr><th scope="row">Disk space status</th><td>$DISK_STATUS</td></tr>
            <tr><th scope="row">Total RAM</th><td>$MEM_TOTAL MiB</td></tr>
            <tr><th scope="row">Available RAM</th><td>$MEM_AVAILABLE MiB</td></tr>
          </tbody>
        </table>
      </div>
      <p>Disk space status is <strong>OK</strong> below 80% usage and <strong>WARNING</strong> at 80% or above.</p>
      <p class="note">Bash generates this report once per minute. Wait approximately 1–2 minutes and reload the page to see a new generation time.</p>
    </section>

    <section aria-labelledby="commands-heading">
      <h2 id="commands-heading">Commands used</h2>
      <ul>
        <li><code>date</code>: displays the current date, time and time zone using the format specified in the script.</li>
        <li><code>uptime -p</code>: displays how long the server has been running.</li>
        <li><code>df -P / | awk 'NR == 2 {print &#36;5}'</code>: passes filesystem information to awk, which extracts the usage percentage from the second row.</li>
        <li><code>free -m</code>: displays memory information in mebibytes (MiB).</li>
      </ul>
    </section>

    <section aria-labelledby="script-heading">
      <h2 id="script-heading">How the script works</h2>
      <p>The script collects server information using Linux commands and stores the results in Bash variables through command substitution. A function uses an if statement to determine the disk space status.</p>
      <p>The script generates a temporary HTML file and then moves the completed file into place as index.html. Nginx serves this file at /viikko3/.</p>
      <p>TODO: Explain the disk space function and one example of piping from your own script.</p>
    </section>

    <section aria-labelledby="schedule-heading">
      <h2 id="schedule-heading">Scheduling</h2>
      <p>TODO: State whether you used cron or a systemd timer. Explain the schedule and how you ensured that it continues after a reboot.</p>
    </section>

    <section aria-labelledby="tests-heading">
      <h2 id="tests-heading">Test results</h2>
      <h3>Syntax check and manual execution</h3>
      <p>TODO: Describe the results of running <code>bash -n report.sh</code> and executing the script manually.</p>
      <h3>Disk space status tests</h3>
      <p>TODO: Test the status logic using temporary input values. Record your actual results below and restore real disk usage afterwards.</p>
      <div class="table-container">
        <table>
          <thead><tr><th scope="col">Test input</th><th scope="col">Expected status</th><th scope="col">Actual status</th></tr></thead>
          <tbody>
            <tr><td>50%</td><td>OK</td><td>TODO</td></tr>
            <tr><td>80%</td><td>WARNING</td><td>TODO</td></tr>
            <tr><td>90%</td><td>WARNING</td><td>TODO</td></tr>
          </tbody>
        </table>
      </div>
      <h3>Automatic updates</h3>
      <p>TODO: Record the generation times of at least two consecutive automatic updates.</p>
      <h3>Reboot test</h3>
      <p>TODO: Record when you rebooted the VM and whether the Week 2 application and Week 3 page opened afterwards. Include evidence that the report continued to update.</p>
    </section>

    <section aria-labelledby="lesson-heading">
      <h2 id="lesson-heading">A problem solved or a lesson learned</h2>
      <p>TODO: Describe one example from your own work.</p>
    </section>
  </main>

  <footer><p><a href="$GITHUB_URL">View the source code on GitHub</a></p></footer>
</html>
EOF

# move file to final location
mv "$TEMP_FILE" "$REPORT_DIR/index.html"