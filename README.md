# TVT26KMO-Linux

Course assignments for Linux server administration (cPouta/OpenStack).

## Structure

- `week1/` — basic web page
- `week2/` — Flask + SQLite visitor counter (now MariaDB on Server A)
- `week3/` — server status report script + cron
- `week4/` — server cloning, hourly backups, MariaDB replication
- `week5/` — LLM chat with CI/CD (separate repository: https://github.com/saarijk/TVT26KMO-Linux-LLM)

## Week 4 — Server cloning, backups and replication

Two servers in cPouta:

- **Server A** (master): `195.148.31.130`
  - Week 2 app at `http://195.148.31.130/viikko2/` (increments counter)
  - Week 3 report at `http://195.148.31.130/viikko3/`
- **Server B** (read-only replica): `86.50.23.104`
  - Week 4 page at `http://86.50.23.104/viikko4/` (displays replicated counter)

### How Server B was created

B was launched from a snapshot of A (`serverB-week4`). The same `.pem` key was reused; a new Floating IP was assigned. MariaDB was installed separately on B because the snapshot predated MariaDB setup on A.

### What's in `week4/`

| File | Purpose |
|---|---|
| `backup.sh` | Hourly rsync of A's `/var/www/html` to B's `/var/backups/website/` |
| `cron.txt` | Crontab line for the hourly schedule |
| `replication-config-sanitized.cnf` | A's and B's MariaDB settings (no passwords) |
| `index.php` | B's `/viikko4/` read-only counter page (public copy; real password only on B) |

### Backups

- Script: `backup.sh`, run by root's cron (`0 * * * *`) on A
- Destination: `/var/backups/website/html-<timestamp>/` on B, mode 700, owned by `backupuser`
- Access: `backupuser`'s SSH key is restricted with `from="195.148.31.130"` on B
- Log: `/var/log/website-backup.log` on A

### Database replication

- A: `server-id=1`, binary log on, `binlog_format=row`
- B: `server-id=2`, `read_only=ON`, replica of A
- Replication user `repl@86.50.23.104` has only `REPLICATION SLAVE` on A
- Read-only user `replica_ro@localhost` on B has only `SELECT` on `visitor_counter.*`

### Why replication ≠ backup

Replication mirrors changes — including deletions and corruption — within seconds. Historical backups are point-in-time snapshots that let you roll back. Replication provides availability and read scaling; backups provide recoverability.

### Links

- Server A: http://195.148.31.130/
- Server B: http://86.50.23.104/

## Week 5 — CI/CD pipeline and self-hosted LLM chat

Built in its own repository, because GitHub Actions only reads workflows from the repository root.

- Chat: http://195.148.31.130/viikko5/
- Documentation and test results: http://195.148.31.130/viikko5/docs
- Repository: https://github.com/saarijk/TVT26KMO-Linux-LLM

Deployed to Server A, since the chat writes to MariaDB and Server B's database is a read-only replica.
