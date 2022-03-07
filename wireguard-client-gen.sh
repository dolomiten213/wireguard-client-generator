if  [ ! -d clients ]; then mkdir clients
fi
read -p "Client name: " client
read -p "Device name: " device

cd clients
if [ ! -d $client ]; then mkdir $client
fi
cd $client
if [ ! -d $device ]; then mkdir $device
        else
                echo already have this client with this device
                exit
fi
cd $device
wg genkey | tee private-key.txt | wg pubkey > public-key.txt
cd ..
cd ..
cd ..

sprk=`cat server/private-key.txt`
spuk=`cat server/public-key.txt`
cprk=`cat clients/$client/$device/private-key.txt`
cpuk=`cat clients/$client/$device/public-key.txt`

lip=$((`cat server/last-used-ip.txt` + 1))
dns=`cat server/dns.txt`
socket=`cat server/socket.txt`

echo "
# ===== auto-generated for $client $device =====
[Peer]
PublicKey = $cpuk
AllowedIPs = 10.0.0.$lip/32
PersistentkeepAlive = 20

" >> wg0.conf

echo "[Interface]
PrivateKey = $cprk
Address = 10.0.0.$lip/32
DNS = $dns

[Peer]
PublicKey = $spuk
Endpoint = $socket
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20" > clients/$client/$device/$client-$device.conf

echo $lip > server/last-used-ip.txt

systemctl restart wg-quick@wg0
#systemctl status wg-quick@wg0

qrencode -t ansiutf8 < clients/$client/$device/$client-$device.conf
cat clients/$client/$device/$client-$device.conf

#rm -rf clients/
