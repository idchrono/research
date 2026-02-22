# SSH Tunnel Script

## Overview

This script sets up a VPN‑like tunnel with **sshuttle**. It forwards all outbound traffic (except a local subnet) through an SSH connection to a remote host. DNS queries are also proxied.

## Features

- `--dns` – DNS forwarding
- `-x` – exclude local network (default `192.168.0.0/16` and `192.168.1.0/24`)
- Strict error handling (`set -euo pipefail`)
- Log output is tee’d to `/var/log/ssh-tunnel.log`

## Requirements

- `sshuttle` (Python implementation)
- `tee` (standard on Linux)
- Writable `/var/log/` directory (or edit the log path in the script)

## Configuration

The script reads options from a **`.env`** file in the same directory (copy `.env.sample` to `.env` and adjust the values). Variables:

```bash
REMOTE_USER=repo_user        # SSH username
REMOTE_HOST=repo.example.com  # SSH host or IP
NETWORK=0/0                    # Subnet to forward (default all)
EXCLUDE=192.168.0.0/16 192.168.1.0/24
          # Subnet(s) to exclude
```

## Usage

```bash
# Make script executable
chmod +x ssh-tunnel.sh

# Run (foreground; or use nohup/systemd for background)
./ssh-tunnel.sh
```

> **Tip**: For custom targets, just change the variables in `.env` – no need to edit the script.

### Running under `systemd`

Create a unit file, e.g. `/etc/systemd/system/ssh-tunnel.service`:

```
[Unit]
Description=SSHuttle VPN tunnel
After=network.target

[Service]
WorkingDirectory=/home/idchrono/research/ssh-tunel
ExecStart=/home/idchrono/research/ssh-tunel/ssh-tunnel.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Then enable and start:

```bash
sudo systemctl enable ssh-tunnel
sudo systemctl start ssh-tunnel
```

## Troubleshooting

- **Log** – check `/var/log/ssh-tunnel.log` for details.
- **SSH auth** – ensure key or password is accepted.
- **Firewall** – outbound SSH (port 22) must be allowed.

---

**Author**: idchrono

