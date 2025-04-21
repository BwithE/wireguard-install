# WireGuard Setup Script

This script helps automate the installation and configuration of a **WireGuard VPN server** and the creation of client configuration files.

---

## Features

- Install WireGuard on Debian/Ubuntu systems
- Generate secure private/public key pairs and preshared keys
- Automatically configure server and client `.conf` files
- Adds NAT, firewall, and IP forwarding for full internet routing
- Supports DNS settings for clients
- Appends clients to the server config automatically

---

## Requirements

- A Debian/Ubuntu Linux server
- Root privileges (use `sudo`)
- WireGuard installed on client devices

---

## How to Use

1. **Run this script on your WireGuard server first** to:
   - Install WireGuard
   - Generate the server’s private/public keys and preshared key
   - Create the server’s `wg0.conf`

2. **Add clients** one by one using the script to:
   - Generate client keys
   - Create a ready-to-use `.conf` file for each client
   - Append client peer details to the server config

3. **Start the server**:

```bash
sudo wg-quick up wg0
```

4. Distribute the client config files to their respective devices.

### Security Tip

Keep all private keys and config files secure. Never share private keys.

