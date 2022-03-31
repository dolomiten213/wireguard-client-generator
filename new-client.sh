if  [ ! -d /etc/wireguard/clients ]; then mkdir /etc/wireguard/clients
fi
read -p "Client name: " client
read -p "Device name: " device

if [ ! -d $client ]; then mkdir /etc/wireguard/$client
fi

if [ ! -d $device ]; then mkdir /etc/wireguard/$client/$device
        else
                echo already have this client with this device
                exit
fi
wg genkey | tee /etc/wireguard/$client/$device/private-key.txt | wg pubkey > /etc/wireguard/$client/$device/public-key.txt

sprk=`cat /etc/wireguard/server/private-key.txt`
spuk=`cat /etc/wireguard/server/public-key.txt`
cprk=`cat /etc/wireguard/clients/$client/$device/private-key.txt`
cpuk=`cat /etc/wireguard/clients/$client/$device/public-key.txt`

lip=$((`cat /etc/wireguard/server/last-used-ip.txt` + 1))
dns=`cat /etc/wireguard/server/dns.txt`
socket=`cat /etc/wireguard/server/socket.txt`

echo "
# ===== auto-generated for $client $device =====
[Peer]
PublicKey = $cpuk
AllowedIPs = 10.0.0.$lip/32
PersistentkeepAlive = 20

" >> /etc/wireguard/wg0.conf

echo "[Interface]
PrivateKey = $cprk
Address = 10.0.0.$lip/32
DNS = $dns

[Peer]
PublicKey = $spuk
Endpoint = $socket
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20" > /etc/wireguard/clients/$client/$device/$client-$device.conf

echo $lip > /etc/wireguard/server/last-used-ip.txt

systemctl restart wg-quick@wg0
#systemctl status wg-quick@wg0

qrencode -t ansiutf8 < /etc/wireguard/clients/$client/$device/$client-$device.conf
cat /etc/wireguard/clients/$client/$device/$client-$device.conf

#rm -rf clients/
