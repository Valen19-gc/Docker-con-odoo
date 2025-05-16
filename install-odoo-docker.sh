#!/bin/bash

# Variables de configuración
ODOO_VERSION="latest"
ODOO_PORT="8069"
LONGPOLLING_PORT="8072"
DB_HOST="192.168.33.11"
DB_PORT="5432"
DB_USER="odoo"
DB_PASSWORD="1234"
DB_NAME="postgres"  # Nombre de la base de datos predeterminada para la conexión inicial

# Instalar Docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Agregar usuario actual al grupo docker
sudo usermod -aG docker $USER

# Iniciar servicio Docker
sudo systemctl enable docker
sudo systemctl start docker

# Descargar imagen de Odoo
sudo docker pull odoo:$ODOO_VERSION

# Crear volumenes persistentes
mkdir -p ~/odoo/{addons,config,data}

# Crear archivo de configuración mínimo
echo "[options]
addons_path = /mnt/extra-addons
admin_passwd = admin
db_host = $DB_HOST
db_port = $DB_PORT
db_user = $DB_USER
db_password = $DB_PASSWORD
db_name = $DB_NAME
" > ~/odoo/config/odoo.conf

# Ejecutar contenedor Odoo
sudo docker run -d \
  --name odoo \
  -p $ODOO_PORT:8069 \
  -p $LONGPOLLING_PORT:8072 \
  -v ~/odoo/addons:/mnt/extra-addons \
  -v ~/odoo/config:/etc/odoo \
  -v ~/odoo/data:/var/lib/odoo \
  -e HOST=$DB_HOST \
  -e USER=$DB_USER \
  -e PASSWORD=$DB_PASSWORD \
  odoo:$ODOO_VERSION

echo "Instalación completada!"
echo "Odoo está disponible en: http://$(hostname -I | awk '{print $1}'):$ODOO_PORT"
echo "Usuario admin: admin (cambiar inmediatamente)"
echo "Asegúrate de que tu servidor PostgreSQL remoto permite conexiones desde esta IP: $(hostname -I | awk '{print $1}')"
