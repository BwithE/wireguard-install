#!/bin/bash
echo "########################################################"
echo "This script can be ran on the Server and Client seperately"
echo "It is recommended to build your keys and conf files on a"
echo "different device than your server."
echo "########################################################"

show_menu() {
    clear
    echo "########################"
    echo "        WIREGUARD"
    echo "########################"
    echo "1) Server Install"
    echo "2) Client Install"
    echo "3) Configure Server Conf file"
    echo "4) Configure Client Conf files"
    echo "*) Exit"
}

install_server() {
    clear
    echo "########################################################"
    echo "Installing WireGuard on server..."
    echo "########################################################"
    sudo apt-get update
    sudo apt-get install -y wireguard

    echo "########################################################"
    echo "WireGuard installation on server completed."
    echo ""
    read -p "Press Enter to continue..."
}

install_client() {
    clear
    echo "########################################################"
    echo "Installing WireGuard on client..."
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
    echo "Endpoint = $server_ip:$server_port" >> /etc/wireguard/$clientconf.conf

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
        1) install_server ;;
        2) install_client ;;
        3) configure_server_conf ;;
        4) configure_client_conf ;;
        *) echo "Exiting..." && exit ;;
    esac
done