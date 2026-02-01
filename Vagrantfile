Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.hostname = "n8n-server"

  # Interface de rede pública (Bridge) conectada ao seu Wi-Fi
  config.vm.network "public_network", ip: "192.168.15.48", bridge: "wlp4s0"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "n8n-server"
    vb.memory = "8192"
    vb.cpus = 4
    # Resolve problemas de DNS repassando a query para o host
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provision "shell", inline: <<-SHELL
    export DEBIAN_FRONTEND=noninteractive

    # 1. Desabilita IPv6 (evita lentidão e erros de rede)
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1

    # 2. Configura DNS ultra-estável
    echo -e "nameserver 1.1.1.1\nnameserver 8.8.8.8" > /etc/resolv.conf

    # 3. CORREÇÃO DE ROTA (Evita o Timeout do Docker)
    # Garante que a saída padrão seja o NAT do VirtualBox durante o setup
    ip route del default || true
    ip route add default via 10.0.2.2 dev eth0 || true

    # 4. Instalação do Docker e Compose
    echo "Instalando Docker..."
    apt-get update -y
    apt-get install -y docker.io docker-compose-v2
    systemctl start docker
    chmod 666 /var/run/docker.sock

    # 5. Configuração do n8n na porta 81
    mkdir -p /home/vagrant/n8n-deploy
    cat <<EOF > /home/vagrant/n8n-deploy/docker-compose.yml
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n-server
    restart: always
    ports:
      - "81:5678"
    environment:
      - N8N_PORT=5678
      - N8N_SECURE_COOKIE=false
      - WEBHOOK_URL=http://192.168.15.48:81/
    volumes:
      - n8n_data:/home/node/.n8n
volumes:
  n8n_data:
EOF

    # 6. Pull e Up com Retry
    cd /home/vagrant/n8n-deploy
    echo "Baixando imagem do n8n..."
    until docker compose pull; do
      echo "Tentativa de download falhou, tentando novamente em 5 segundos..."
      sleep 5
    done

    docker compose up -d

    # 7. Garante que a rede local (.15.0) saiba onde encontrar a VM
    ip route add 192.168.15.0/24 dev eth1 || true

    echo "------------------------------------------------------"
    echo "Sucesso! Acesse: http://192.168.15.48:81"
    echo "------------------------------------------------------"
  SHELL
end
