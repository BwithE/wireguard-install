#!/bin/bash

show_menu() {
    clear
    echo "########################"
    echo "        WIREGUARD"
    echo "########################"
    echo "1) Wireguard Install"
    echo "2) Configure Server Conf file"
    echo "3) Configure Client Conf files"#!/bin/bash

WIREGUARD_DIR="/etc/wireguard"
SERVER_PRIV="$WIREGUARD_DIR/srvprivate"
SERVER_PUB="$WIREGUARD_DIR/srvpublic"
PSK_FILE="$WIREGUARD_DIR/preshared.key"

show_menu() {
    clear
    echo "########################"
    echo "        WIREGUARD"
    echo "########################"
    echo "1) Install WireGuard"
    echo "2) Configure Server"
    echo "3) Add Client"
    echo "*) Exit"
}

install_wireguard() {
    clear
    echo "Installing WireGuard..."
    sudo apt-get update
    sudo apt-get install -y wireguard iptables resolvconf
    echo "Installation complete."
    read -p "Press Enter to continue..."
}

configure_server_conf() {
    clear
    read -p "Enter VPN subnet (e.g., 10.0.0.1/24): " server_ip
    read -p "Enter server listen port (default 51820): " server_port
    server_port=${server_port:-51820}

    echo "Generating server keys..."
    sudo mkdir -p $WIREGUARD_DIR
    umask 077
    wg genkey | sudo tee $SERVER_PRIV | wg pubkey | sudo tee $SERVER_PUB > /dev/null
    wg genpsk | sudo tee $PSK_FILE > /dev/null

    echo "Creating server config..."
    cat <<EOF | sudo tee $WIREGUARD_DIR/wg0.conf > /dev/null
[Interface]
PrivateKey = $(cat $SERVER_PRIV)
Address = $server_ip
ListenPort = $server_port
SaveConfig = true

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

    echo "Enabling IP forwarding..."
    sudo sh -c "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf"
    sudo sh -c "echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf"
    sudo sysctl -p

    echo "Server config created at $WIREGUARD_DIR/wg0.conf"
    echo "Start it with: sudo wg-quick up wg0"
    read -p "Press Enter to continue..."
}

configure_client_conf() {
    clear
    read -p "Client name (no spaces): " client_name
    read -p "Client VPN IP (e.g., 10.0.0.2/32): " client_ip
    read -p "Server public IP (e.g., 203.0.113.1): " pubip
    read -p "DNS for client (e.g., 10.0.0.1 or 1.1.1.1): " dns

    CLIENT_PRIV="$WIREGUARD_DIR/${client_name}_private"
    CLIENT_PUB="$WIREGUARD_DIR/${client_name}_public"
    CLIENT_CONF="$WIREGUARD_DIR/${client_name}.conf"

    echo "Generating client keys..."
    wg genkey | sudo tee $CLIENT_PRIV | wg pubkey | sudo tee $CLIENT_PUB > /dev/null

    server_pub=$(cat $SERVER_PUB)
    client_priv=$(cat $CLIENT_PRIV)
    client_pub=$(cat $CLIENT_PUB)
    psk=$(cat $PSK_FILE)

    read -p "Server listen port (default 51820): " server_port
    server_port=${server_port:-51820}

    echo "Creating client config..."
    cat <<EOF | sudo tee $CLIENT_CONF > /dev/null
[Interface]
PrivateKey = $client_priv
Address = $client_ip
DNS = $dns

[Peer]
PublicKey = $server_pub
PresharedKey = $psk
Endpoint = $pubip:$server_port
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

    echo "Adding client to server config..."
    cat <<EOF | sudo tee -a $WIREGUARD_DIR/wg0.conf > /dev/null

[Peer]
PublicKey = $client_pub
PresharedKey = $psk
AllowedIPs = ${client_ip%%/*}/32
EOF

    echo "Client config created: $CLIENT_CONF"
    echo "Copy this file to the client and import it into WireGuard."
    echo "Restart server config with: sudo wg-quick down wg0 && sudo wg-quick up wg0"
    read -p "Press Enter to continue..."
}

while true; do
    show_menu
    read -p "Enter your choice: " choice
    case $choice in
        1) install_wireguard ;;
        2) configure_server_conf ;;
        3) configure_client_conf ;;
        *) echo "Exiting..." && exit ;;
    esac
done

    echo "*) Exit"
}

install_client() {
    clear
    echo "########################################################"
    echo "Installing WireGuard..."
    echo "########################################################"
    sudo apt-get update
    sudo apt-get install -y wireguard

    echo "########################################################"
    echo "WireGuard installation on client completed."
    echo ""
    read -p "Press Enter to continue..."
}

configure_server_conf() {
    clear

    echo "########################################################"
    read -p "Enter server IP address (e.g., 10.0.0.1/24): " server_ip
    read -p "Enter server listen port (default 51820): " server_port
    echo "########################################################"
    echo "Generating Server keys"

    sudo mkdir -p /etc/wireguard
    sudo wg genkey | sudo tee /etc/wireguard/srvprivate | sudo wg pubkey | sudo tee /etc/wireguard/srvpublic

    echo "########################################################"
    echo "Configuring server conf file..."
    echo "[Interface]" > /etc/wireguard/wg0.conf
    echo "PrivateKey = $(cat /etc/wireguard/srvprivate)" >> /etc/wireguard/wg0.conf
    echo "Address = $server_ip" >> /etc/wireguard/wg0.conf
    echo "ListenPort = $server_port" >> /etc/wireguard/wg0.conf
    echo "SaveConfig = true" >> /etc/wireguard/wg0.conf

    echo "########################################################"
    echo "Server configuration completed. Config file saved as /etc/wireguard/wg0.conf."
    echo "########################################################"
    echo "Copy the wg0.conf to your SERVER in the /etc/wireguard directory."
    echo "Run the following command on your SERVER."
    echo ""
    echo "wg-quick up /etc/wireguard/wg0.conf"
    echo ""
    read -p "Press Enter to continue..."
}

configure_client_conf() {
    clear
    echo "########################################################"
    read -p "Please enter a name for the client. (Ex: BobsPC): " $clientconf
    read -p "Enter client IP address (e.g., 10.0.0.2/24): " client_ip
    read -p "What is the SERVERS public IP? (NOT VPN IP): " pubip
    echo "########################################################"
    echo "Generating $clientconf keys"

    sudo mkdir -p /etc/wireguard
    sudo wg genkey | sudo tee /etc/wireguard/$clientconf-private | sudo wg pubkey | sudo tee /etc/wireguard/$clientconf-public
    echo "########################################################"
    echo "Configuring $clientconf conf files..."

    echo "[Interface]" > /etc/wireguard/$clientconf.conf
    echo "PrivateKey = $(cat $clientconf-private)" >> /etc/wireguard/$clientconf.conf
    echo "Address = $client_ip" >> /etc/wireguard/$clientconf.conf
    echo "[Peer]" >> /etc/wireguard/$clientconf.conf
    echo "PublicKey = $(cat /etc/wireguard/srvpublic)" >> /etc/wireguard/$clientconf.conf
    echo "Endpoint = $pubip:$server_port" >> /etc/wireguard/$clientconf.conf
    echo "AllowedIPs = $server_ip" >> /etc/wireguard/$clientconf.conf

    echo "[Peer]" >> /etc/wireguard/wg0.conf
    echo "PublicKey = $(cat /etc/wireguard/$clientconf-public)" >> /etc/wireguard/wg0.conf
    echo "AllowedIPs = $client_ip, 0.0.0.0/24" >> /etc/wireguard/wg0.conf
    echo "########################################################"
    echo "Client configuration completed. Config file saved as $clientconf.conf."
    echo "########################################################"
    echo "Copy your $clientconf.conf to your device, and connect to your SERVER."
    echo ""
    read -p "Press Enter to continue..."
}

while true
do
    show_menu

    read -p "Enter your choice: " choice
    case $choice in
        1) install_client ;;
        2) configure_server_conf ;;
        3) configure_client_conf ;;
        *) echo "Exiting..." && exit ;;
    esac
done
