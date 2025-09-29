#!/bin/bash

# Script de instalación para TheCookFlow en VPS
# Ejecutar como: bash install-vps.sh

echo "🚀 Instalando TheCookFlow en VPS..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_message() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar si se ejecuta como root
if [ "$EUID" -eq 0 ]; then
    print_error "No ejecutes este script como root. Usa tu usuario normal."
    exit 1
fi

# Actualizar sistema
print_message "Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar Node.js 18
print_message "Instalando Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar instalación
node_version=$(node --version)
npm_version=$(npm --version)
print_message "Node.js versión: $node_version"
print_message "npm versión: $npm_version"

# Instalar PostgreSQL
print_message "Instalando PostgreSQL..."
sudo apt install postgresql postgresql-contrib -y

# Instalar Nginx
print_message "Instalando Nginx..."
sudo apt install nginx -y

# Instalar PM2
print_message "Instalando PM2..."
sudo npm install -g pm2

# Crear directorio de la aplicación
print_message "Creando directorio de aplicación..."
sudo mkdir -p /var/www/thecookflow
sudo chown -R $USER:$USER /var/www/thecookflow

# Verificar si existe el archivo comprimido
if [ ! -f "$HOME/thecookflow-app.tar.gz" ]; then
    print_warning "No se encontró thecookflow-app.tar.gz en $HOME"
    print_warning "Asegúrate de subirlo primero con scp o FileZilla"
    exit 1
fi

# Descomprimir aplicación
print_message "Descomprimiendo aplicación..."
cd /var/www/thecookflow
tar -xzf ~/thecookflow-app.tar.gz

# Instalar dependencias
print_message "Instalando dependencias..."
npm install

# Crear archivo .env desde template
print_message "Creando archivo .env..."
if [ -f ".env.production.template" ]; then
    cp .env.production.template .env
    print_warning "Archivo .env creado desde template. DEBES EDITARLO con tus valores reales:"
    print_warning "nano /var/www/thecookflow/.env"
else
    print_error "No se encontró .env.production.template"
fi

# Configurar PostgreSQL
print_message "Configurando PostgreSQL..."
sudo -u postgres psql << EOF
CREATE DATABASE thecookflow;
CREATE USER thecookflow_user WITH PASSWORD 'cambiar_password_123';
GRANT ALL PRIVILEGES ON DATABASE thecookflow TO thecookflow_user;
ALTER USER thecookflow_user CREATEDB;
\q
EOF

print_warning "Base de datos creada con password temporal: cambiar_password_123"
print_warning "Cambia este password en PostgreSQL y actualiza .env"

# Crear configuración de PM2
print_message "Creando configuración PM2..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'thecookflow',
    script: 'server/index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    log_file: './logs/combined.log',
    time: true
  }]
};
EOF

# Crear directorio de logs
mkdir -p logs

# Crear configuración de Nginx
print_message "Creando configuración Nginx..."
DOMAIN="thecookflow.com"
print_message "Configurando para dominio: $DOMAIN"

sudo tee /etc/nginx/sites-available/thecookflow > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 86400;
    }

    # Archivos estáticos
    location /assets/ {
        alias /var/www/thecookflow/dist/assets/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Habilitar sitio
sudo ln -sf /etc/nginx/sites-available/thecookflow /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Verificar configuración Nginx
sudo nginx -t

if [ $? -eq 0 ]; then
    print_message "Configuración Nginx válida"
    sudo systemctl restart nginx
    sudo systemctl enable nginx
else
    print_error "Error en configuración Nginx"
    exit 1
fi

# Configurar firewall
print_message "Configurando firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Instalar Certbot
print_message "Instalando Certbot para SSL..."
sudo apt install certbot python3-certbot-nginx -y

print_message "🎉 Instalación completada!"
print_warning ""
print_warning "PASOS SIGUIENTES OBLIGATORIOS:"
print_warning "1. Editar variables de entorno: nano /var/www/thecookflow/.env"
print_warning "2. Cambiar password de PostgreSQL"
print_warning "3. Construir la aplicación: npm run build"
print_warning "4. Iniciar con PM2: pm2 start ecosystem.config.js"
print_warning "5. Configurar SSL: sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN"
print_warning ""
print_message "Para verificar el estado:"
print_message "- pm2 status"
print_message "- sudo systemctl status nginx"
print_message "- pm2 logs thecookflow"