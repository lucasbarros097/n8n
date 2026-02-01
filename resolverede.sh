# 1. Derruba a interface que está roubando o tráfego
sudo ip link set br-5d5245c89c3d down

# 2. Remove o IP dela para não haver conflito com seu roteador real
sudo ip addr del 192.168.15.1/24 dev br-5d5245c89c3d

# 3. Limpa o cache de vizinhança (ARP)
sudo ip neigh flush all
