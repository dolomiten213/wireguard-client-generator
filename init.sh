cd /etc
mkdir wireguard
cd wireguard

wget https://github.com/dolomiten213/wireguard-client-generator/blob/main/wireguard-client-gen.sh

apt install -y wireguard
mkdir server
wg genkey | tee server/private-key.txt | wg pubkey | tee server/public-key.txt

echo "
[Interface]
PrivateKey = `cat server/private-key.txt`
Address = 10.0.0.1/24
ListenPort = 51830
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

" > wg0.conf

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service
