Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.hostname = "n8n-server"

  # Interface de rede (Bridge)
  config.vm.network "public_network", ip: "192.168.15.48", bridge: "wlp4s0"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "n8n-server"
    vb.memory = "4096"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # Configuração do servidor e do serviço n8n
  config.vm.provision "shell", inline: <<-SHELL
    set -e # Faz o script parar imediatamente se houver erro

    # 1. Configuração de DNS estável
    echo "nameserver 1.1.1.1" > /etc/resolv.conf

    # 2. Instalação do Docker (Versão correta para Ubuntu 24.04)
    echo "Instalando Docker e Plugins..."
    apt-get update -y
    apt-get install -y docker.io docker-compose-v2
    
    # Garante que o serviço suba e o usuário tenha permissão
    systemctl enable --now docker
    usermod -aG docker vagrant

    # 3. Criação do diretório e do arquivo Compose
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

    # 4. Inicialização do n8n
    cd /home/vagrant/n8n-deploy
    echo "Baixando e iniciando n8n..."
    # Usamos 'docker compose' (sem hífen) que é o padrão da v2
    docker compose up -d

    echo "------------------------------------"
    echo " http://192.168.15.48:81 "
    echo "------------------------------------"
  SHELL
end
