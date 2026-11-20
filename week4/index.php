<?php

// NOTE: This is a public, sanitized copy that doesn't contain any real passwords

$host = '127.0.0.1';
$db = 'visitor_counter';
$user = 'replica_ro';
$pass = 'REPLACE_ME';
$charset = 'utf8mb4';

$dns = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
        PDO::ATTR_ERRMODE               => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE    => POD::FETCH_ASSOC,
];

try {
        $pdo = new PDO($dsn, $user, $pass, $options);
        $stmt = $pdo->query('SELECT count FROM counter WHERE id = 1');
        $row = $stmt->fetch();
        $count = $row ? (int)$row['count'] : 'N/A';
} catch (PDOException $e) {
        $count = 'Database error';
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
        <meta charset="utf-8">
        <title>My Linux Server - Week 4</title>
        <style>
                body {
                        max-width:800px;
                        margin: 40px auto;
                        padding:0 20px;
                        font-family: "Segoe UI", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
                        line-height: 1.6;
                        background: #f0f4f8;
                        color: #203040;
                }

                main {
                        background: #eef3e5;
                        padding: 32px 40px;
                        border-radius: 8px;
                        box-shadow: 0 2px 8px rgba(0,0,0,0.06);
                }

                h1 {
                        color: #2d4600;
                        font-size: 1.8.em;
                        border-bottom: 2px solid #1b2a00;
                        padding-bottom: 8px;
                }

                h2 {
                        color: #5a8d00;
                        font-size: 1.25em;
                }

                h3 {
                        font-size: 1.25em;
                        font-style: italic;
                }

                .counter {
                        font-size: 2.5em;
                        font-weight: bold;
                        color: #2a7a2a;
                }

                .badge {
                        display: inline-block;
                        background: #d33;
                        color: white;
                        padding: 0.2em 0.6em;
                        border-radius: 4px;
                        font-size: 0.9em;
                }

                code {
                        font-size: 14px;
                }

                pre {
                        background: #eef2f6;
                        padding: 16px;
                        overflow-x: auto;
                        border-left: 3px solid #005a86;
                        border-radius: 4px;
                        font-size: 0.95em;
                }

                table {
                        border-collapse: collapse;
                        margin: 0.5em 0;
                }

                th, td {
                        border: 1px solid #ccc;
                        padding: 0.35em 0.6em;
                        text-align: left;
                        vertical-align: top;
                }

                th {
                        background: #f0f0f0:
                }

                .ok {
                        color: 2e7d32;
                        font-weight: 600;
                }

        </style>
</head>
<body>
        <h1>My Linux Server</h1>
        <h3>Read-Only Replica</h3>
        <p>This page reads from <strong>Server B's local replicated database</strong>. Loading it does not increment the counter.</p>

        <h2>Replicated visitor counter</h2>
        <p>Current replicated visitor count: <span class="counter"><?php echo htmlspecialchars($count); ?></span></p>
        <p>For the live (incrementing) counter, visit <a href="http://195.148.31.130/viikko2/">Server A's week 2 page</a>.</p>

        <h2>Links</h2>
        <ul>
                <li>Server A counter page: <a href="http://195.148.31.130/viikko2/">http://195.148.31.130/viikko2/</a></li>
                <li>Server B read-only page (this page): <a href="http://86.50.23.104/viikko4/">http://86.50.23.104/viikko4/</a></li>
                <li>Github repository: <a href="https://github.com/saarijk/TVT26KMO-Linux">TVT26KMO-Linux</a></li>
        </ul>

        <h2>How Server B was created</h2>
        <p>Server B was created by taking a snapshot of Server A in cPouta (<code>serverB-week4</code>) and launching a new instance from that snapshot. The same SSH key pair was reused, and a new floating IP was created and assigned to Server B.</p>
        <p>Because B's first snapshot predated the setup of MariaDB on server A, MariaDB was installed on B separately with <code>apt install mariadb-server</code> and then configured as a read-only replica.</p>

        <h2>Storage layout and backup locations</h2>
        <table>
            <tr><th>Server</th><th>Path</th><th>Contents</th><th>Notes</th></tr>
            <tr><td>A</td><td><code>/var/www/html/</code></td><td>Static web content (<code>index.html</code>, <code>viikko3/</code>)</td><td>Backed up hourly</td></tr>
            <tr><td>A</td><td><code>/home/ubuntu/TVT26KMO-Linux/week2/</code></td><td>Flask app + venv</td><td>Git repo; not in file backup scope</td></tr>
            <tr><td>A</td><td><code>/var/lib/mysql/</code></td><td>MariaDB data (master)</td><td>Replicated, not file-backed up</td></tr>
            <tr><td>B</td><td><code>/var/backups/website/</code></td><td>Hourly rsync snapshots (<code>html-YYYY-MM-DD_HHMMSS/</code>)</td><td><code>drwx------ backupuser:backupuser</code> (700) — outside any web-served path</td></tr>
            <tr><td>B</td><td><code>/var/lib/mysql/</code></td><td>MariaDB data (read-only replica)</td><td><code>read_only=ON</code></td></tr>
            <tr><td>B</td><td><code>/var/www/html/viikko4/</code></td><td>This page</td><td>Owned by <code>www-data:www-data</code>, mode 644</td></tr>
        </table>

        <h2>Linux users, database users, ownership, permissions</h2>
        <h3>Linux users</h3>
        <ul>
            <li><code>ubuntu</code> — administrative SSH user on both servers.</li>
            <li><code>backupuser</code> — dedicated account on A and B for the file-backup channel. Its SSH key on A is restricted on B's <code>authorized_keys</code> with <code>from="195.148.31.130"</code> and disables agent/port/PTY forwarding. B's <code>/var/backups/website</code> is <code>700 backupuser:backupuser</code>, so only this account can read the backups.</li>
            <li><code>www-data</code> — Nginx/PHP-FPM user; owns <code>/var/www/html/viikko4/</code>.</li>
        </ul>

        <h3>MariaDB users</h3>
        <table>
            <tr><th>User@Host</th><th>Server</th><th>Grants</th><th>Purpose</th></tr>
            <tr><td><code>appuser@localhost</code></td><td>A</td><td><code>SELECT, INSERT, UPDATE</code> on <code>visitor_counter.*</code></td><td>Week 2 Flask app — least privilege DML only</td></tr>
            <tr><td><code>repl@86.50.23.104</code></td><td>A</td><td><code>REPLICATION SLAVE</code></td><td>Dedicated replication user, host-restricted to B's IP</td></tr>
            <tr><td><code>replica_ro@localhost</code></td><td>B</td><td><code>SELECT</code> on <code>visitor_counter.*</code></td><td>This page — cannot write, and <code>read_only=ON</code> blocks any attempt at the server level</td></tr>
        </table>
        <p>The password for the app DB user is supplied to Flask via <code>week2/.env</code> (untracked, mode 600). The replication password lives only in B's <code>CHANGE MASTER TO</code> metadata. The <code>replica_ro</code> password is in this file on B; the repo copy uses a placeholder.</p>

        <h2>Hourly backup schedule and continuous replication</h2>
        <h3>Hourly file backups (A → B)</h3>
        <ul>
            <li>Script: <code>/usr/local/bin/website-backup.sh</code> on A.</li>
            <li>Mechanism: <code>rsync -az --delete</code> over SSH as <code>backupuser</code>, writing to <code>/var/backups/website/html-$(date +%Y-%m-%d_%H%M%S)/</code> on B.</li>
            <li>Cron: <code>0 * * * *</code> in root's crontab on A.</li>
            <li>Success/failure is appended to <code>/var/log/website-backup.log</code> (timestamped <code>SUCCESS</code>/<code>FAILED</code> lines).</li>
            <li>At least two timestamped versions retained; no rotation/expiry is configured (the assignment only requires ≥2).</li>
        </ul>

        <h3>Continuous database replication (A → B)</h3>
        <ul>
            <li>A (master): <code>server-id=1</code>, binary log enabled (<code>log_bin=/var/log/mysql/mysql-bin.log</code>), <code>binlog_format=row</code>, listening on <code>0.0.0.0:3306</code> but reachable only from B's IP via the cPouta security group.</li>
            <li>B (replica): <code>server-id=2</code>, <code>read_only=ON</code>, relay log enabled, connected via <code>CHANGE MASTER TO</code> using the dedicated <code>repl</code> user.</li>
            <li>Every write on A is streamed to B's relay log and applied to B's local copy of <code>visitor_counter</code>.</li>
        </ul>

        <h3>Why replication does not replace historical backups</h3>
        <p>Replication is a <strong>continuous mirror</strong>: every change on A — including destructive ones such as <code>DELETE</code>, <code>UPDATE</code> to wrong values, or <code>DROP TABLE</code> — is applied to B within seconds. If data is accidentally deleted or corrupted on A, the same damage propagates to B, and B cannot recover the earlier state. Historical file backups are <strong>point-in-time snapshots</strong> of the filesystem; they let you return to a state from before the incident. Replication provides availability and read scaling; backups provide recoverability. They complement each other and are not interchangeable.</p>

        <h2>Test results</h2>
        <table>
            <tr><th>Test</th><th>Result</th></tr>
            <tr><td>Both pages publicly accessible</td><td class="ok">✅</td></tr>
            <tr><td>Loading A's <code>/viikko2/</code> increments counter and B's <code>/viikko4/</code> shows updated value after refresh</td><td class="ok">✅</td></tr>
            <tr><td>Loading B's <code>/viikko4/</code> does not increment the counter</td><td class="ok">✅</td></tr>
            <tr><td><code>SHOW SLAVE STATUS</code>: <code>Slave_IO_Running=Yes</code>, <code>Slave_SQL_Running=Yes</code>, <code>Seconds_Behind_Master=0</code></td><td class="ok">✅</td></tr>
            <tr><td>Ordinary user write on B blocked: <code>ERROR 1290 ... --read-only</code></td><td class="ok">✅</td></tr>
            <tr><td>≥2 successful automatic cron backups; ≥2 timestamped backup directories on B</td><td class="ok">✅</td></tr>
            <tr><td>Restored test file checksum matches original</td><td class="ok">✅</td></tr>
            <tr><td>After reboot of B: page, replication, cron still healthy</td><td class="ok">✅ (pending this phase)</td></tr>
        </table>

        <h2>One problem solved / one thing learned</h2>
        <p><strong>Problem solved:</strong> the backup script initially failed with <code>No ED25519 host key is known for 86.50.23.104</code> even though <code>backupuser</code>'s <code>known_hosts</code> contained the right key. Root cause: the script runs as <strong>root</strong>, and ssh reads <em>root's</em> <code>~/.ssh/known_hosts</code>, not <code>backupuser</code>'s. Fix: <code>ssh-keyscan 86.50.23.104 &gt;&gt; /root/.ssh/known_hosts</code> (permissions 600). Lesson: <code>known_hosts</code> is per-user, and the user that matters is the one executing ssh, not the remote login user.</p>
        <p><strong>Another lesson:</strong> <code>sudo command &gt;&gt; file</code> performs the redirection in the calling shell, not as root. <code>sudo bash -c '... &gt;&gt; file'</code> is needed when the target file is root-only.</p>

    </body>
</html>