#!/bin/bash


## --------------------------------------------------
## ReymondRojasNúñez - IoTCostaRica -ISCORP2021
## ---------------------------------------------------

rand-str()
{
    # Return random alpha-numeric string of given LENGTH
    #
    # Usage: VALUE=$(rand-str $LENGTH)
    #    or: VALUE=$(rand-str)

    local DEFAULT_LENGTH=64
    local LENGTH=${1:-$DEFAULT_LENGTH}

    LC_CTYPE=C  tr -dc A-Za-z0-9 </dev/urandom | head -c $LENGTH
    # -dc: delete complementary set == delete all except given set
}


clear
msg="
    ___   ___
   |___   ___|       ___   ___          ___        ___
      / /           /__  ___/        //   ) )   //   ) )
     / /     ___      / /           //         //___/ /
    / /    //   ) )  / /           //         / ___ (
   / /    //   / /  / /           //         //   | |
__/ /___ ((___/ /  / /     _____ ((____/ /  //    | |

                                   ReymondRojasNúñez_2021                                                
"


tput setaf 128;
printf "$msg"
tput setaf 7;

printf "\n\n\nNecesitaremos algo de información para instalar esta Plataforma\n\n"
printf "Verás entre paréntesis la opción por defecto que se selecciona presionando enter.\n"
printf "De lo contrario podrás ingresar manualmente la opción solicitada.\n"
printf "No te preocupes, al final del cuestionario verás un resumen antes de confirmar.\n\n\n"


read -p "Presiona enter para continuar..."





## ______________________________
## TIME ZONE
printf "\n\n⏳ Necesitamos configurar la zona horaria\n"
while [[ -z "$TZ" ]]
do
  read -p "   System Time Zone $(tput setaf 128)(UTC)$(tput setaf 7): "  TZ
  TZ=${TZ:-UTC}
  echo "      Selected Time Zone ► ${TZ} ✅"
done


## ______________________________
## BASE DE DATOS 

#username
printf "\n\n👤 Necesitamos crear un nombre de usuario para la Base de Datos \n"
while [[ -z "$DATABASE_USERNAME" ]]
do
  read -p "   Database User Name (admin): "  DATABASE_USERNAME
  DATABASE_USERNAME=${DATABASE_USERNAME:-admin}
  echo "      Selected Database User Name ► ${DATABASE_USERNAME} ✅"
done

#password
random_str=$(rand-str 20)
printf "\n\n🔐 Necesitamos crear una clave segura para la Base de Datos \n"
while [[ -z "$DATABASE_PASSWORD" ]]
do
  read -p "   Database Password $(tput setaf 128)(${random_str})$(tput setaf 7): "  DATABASE_PASSWORD
  DATABASE_PASSWORD=${DATABASE_PASSWORD:-${random_str}}
  echo "      Selected Database Password ► ${DATABASE_PASSWORD} ✅"
done

#port
printf "\n\n🔌 Selecciona un puerto para la Base de Datos \n"
while [[ -z "$DATABASE_PORT" ]]
do
  read -p "   MariaDb Database Port $(tput setaf 128)(3306)$(tput setaf 7): "  DATABASE_PORT
  DATABASE_PORT=${DATABASE_PORT:-3306}
  echo "      Selected Database Port ► ${DATABASE_PORT} ✅"
done

#name
printf "\n\n🔌 Selecciona un nombre para la Base de Datos \n"
while [[ -z "$DATABASE_NAME" ]]
do
  read -p "   Database User Name (strapiDB):  "  DATABASE_NAME
  DATABASE_NAME=${DATABASE_NAME:-strapiDB}
  echo "      Selected Database Name ► ${DATABASE_NAME} ✅"
done

#rootpassword
printf "\n\n🔌 Selecciona un usuario Root para la Base de Datos \n"
while [[ -z "$ROOT_PASSWORD" ]]
do
  read -p "   Root Password (strapiroot):  "  ROOT_PASSWORD
  ROOT_PASSWORD=${ROOT_PASSWORD:-strapiroot}
  echo "      Selected Root Password ► ${ROOT_PASSWORD} ✅"
done



## ______________________________
## STRAPI

#Strapi Port
random_str=$(rand-str 20)
printf "\n\n🔐 Para la consola de administración, necesitaremos configurar lo siguiente: \n"
while [[ -z "$STRAPI_PORT" ]]
do
  read -p "   Puerto Admin Console (1337): "  STRAPI_PORT
  STRAPI_URL=${STRAPI_PORT:-1337}
  echo "      Selected Strapi Port ► ${STRAPI_PORT} ✅"
done



## ______________________________
## FRONT

#DOMAIN 
printf "\n\n🌐 Ingresa el dominio a donde se alojará este servicio. \n"
printf "   Si todavía no tienes uno, puedes ingresar la ip fija del VPS a donde lo estés instalando. \n"
printf "   Luego podrás cambiarlo desde las variables de entorno. \n"

while [[ -z "$DOMAIN" ]]
do
  read -p "   (No http, No www | ex.-> mydomain.com) Dominio: "  DOMAIN
  echo "         Selected Domain ► ${DOMAIN} ✅"
done



#IP 
printf "\n\n🌐 Ingresa la ip pública del VPS. \n"

while [[ -z "$IP" ]]
do
  read -p "   IP: "  IP
  echo "         Selected IP ► ${IP} ✅"
done




#SSL?
printf "\n\n🔐 El sistema está pensado para que un balanceador de cargas gestione los certificados SSL. \n"
printf "   Si la plataforma estará bajo SSL utilizando balanceador de cargas o proporcionando certificados, selecciona 'Con SSL'. \n"
printf "   Esto forzará la redirección SSL, además, el cliente web, se conectará al broker mqtt mediante websocket seguro. \n"
printf "   Si de momento vas a acceder a la plataforma usando una ip, o un dominio sin ssl... selecciona 'Sin SSL'. \n\n"



PS3='   SSL?: '
options=("Con SSL" "Sin SSL")
select opt in "${options[@]}"
do
    case $REPLY in
        "1")
            echo "         SSL? ► ${character} ✅"
            break
            ;;
        "2")
            echo "         SSL? ► ${character} ✅"
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done


SSL=$REPLY
WSPREFIX=""
SSLREDIRECT=""

if [[ $SSL -eq 1 ]]
  then
    SSL="https://"
    WSPREFIX="wss://"
    MQTT_HOST=$DOMAIN
    MQTT_PORT="8084"
    SSLREDIRECT="true"
  else
    SSL="http://"
    WSPREFIX="ws://"
    MQTT_PORT="8083"
    MQTT_HOST=$IP
    SSLREDIRECT="false"
fi

msg="
   __                                      
  /__\ ___  ___ _   _ _ __ ___   ___ _ __  
 / \/// _ \/ __| | | | '_ \` _ \ / _ \ '_ \ 
/ _  \  __/\__ \ |_| | | | | | |  __/ | | |
\/ \_/\___||___/\__,_|_| |_| |_|\___|_| |_|                                                                                                                           
"

tput setaf 128;
printf "$msg"
tput setaf 7;

printf "\n\n\n"
printf "   🟢 TIMEZONE: $(tput setaf 128)${TZ}$(tput setaf 7)\n"
printf "   🟢 DATABASE USER: $(tput setaf 128)${DATABASE_USERNAME}$(tput setaf 7)\n"
printf "   🟢 DATABASE PASS: $(tput setaf 128)${DATABASE_PASSWORD}$(tput setaf 7)\n"
printf "   🟢 DATABASE PORT: $(tput setaf 128)${DATABASE_PORT}$(tput setaf 7)\n"
printf "   🟢 DATABASE NAME: $(tput setaf 128)${DATABASE_NAME}$(tput setaf 7)\n"
printf "   🟢 DATABASE ROOT_PASS: $(tput setaf 128)${ROOT_PASSWORD}$(tput setaf 7)\n"
printf "   🟢 STRAPI PORT: $(tput setaf 128)${STRAPI_PORT}$(tput setaf 7)\n"
printf "   🟢 DOMAIN: $(tput setaf 128)${DOMAIN}$(tput setaf 7)\n"
printf "   🟢 IP: $(tput setaf 128)${IP}$(tput setaf 7)\n"
printf "   🟢 SSL?: $(tput setaf 128)${opt}$(tput setaf 7)\n"

printf "\n\n\n\n";
read -p "Presiona Enter para comenzar la instalación..."
sleep 2


sudo apt-get update
wget https://get.docker.com/
sudo mv index.html install_docker.sh
sudo chmod 777 install_docker.sh
sudo ./install_docker.sh
sudo rm install_docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo git clone https://github.com/ISProjectsIoTCR/ServicesWebRuralCR.git
sudo mv ServicesWebRuralCR webpage


cd webpage

## ______________________________
## INSALL INIT
filename='.env'


#SERVICES .ENV
sudo sh -c " echo 'environment=prod' >> $filename"
sudo sh -c " echo '' >> $filename"
sudo sh -c " echo '# TIMEZONE (all containers).' >> $filename"
sudo sh -c " echo 'TZ=${TZ}' >> $filename"
sudo sh -c " echo '' >> $filename"
sudo sh -c " echo '# MARIA_DB' >> $filename"
sudo sh -c " echo 'DATABASE_USERNAME=${DATABASE_USERNAME}' >> $filename"
sudo sh -c " echo 'DATABASE_PASSWORD=${DATABASE_PASSWORD}' >> $filename"
sudo sh -c " echo 'DATABASE_PORT=${DATABASE_PORT}' >> $filename"
sudo sh -c " echo 'DATABASE_NAME=${DATABASE_NAME}' >> $filename"
sudo sh -c " echo 'ROOT_PASSWORD=${ROOT_PASSWORD}' >> $filename"
sudo sh -c " echo '' >> $filename"
sudo sh -c " echo '# STRAPI' >> $filename"
sudo sh -c "echo 'STRAPI_URL=${SSL}${DOMAIN}:1337' >> $filename"
sudo sh -c " echo 'STRAPI_PORT=${STRAPI_PORT}' >> $filename"


sudo git clone https://github.com/ISProjectsIoTCR/APPWebRuralCR.git
sudo mv APPWebRuralCR  app

cd app

sudo sh -c "echo 'environment=prod' >> $filename"
sudo sh -c "echo '' >> $filename"

#A P I  - N O D E 
sudo sh -c "echo '#A P I  - N O D E ' >> $filename"
sudo sh -c "echo 'API_PORT=3003' >> $filename"
sudo sh -c "echo 'WEBHOOKS_HOST=node' >> $filename"
sudo sh -c "echo 'MQTT_NOTIFICATION_HOST=${IP}' >> $filename"
sudo sh -c "echo '' >> $filename"

# SCRAPI
sudo sh -c " echo '' >> $filename"
sudo sh -c " echo '# STRAPI' >> $filename"
sudo sh -c "echo 'STRAPI_URL=${SSL}${DOMAIN}:1337' >> $filename"
sudo sh -c " echo 'STRAPI_PORT=${STRAPI_PORT}' >> $filename"
sudo sh -c "echo '' >> $filename"




# F R O N T
sudo sh -c "echo '# F R O N T' >> $filename"
sudo sh -c "echo 'APP_PORT=4000' >> $filename"
sudo sh -c "echo 'AXIOS_BASE_URL=${SSL}${DOMAIN}:3003/api' >> $filename"

sudo sh -c "echo 'MQTT_PORT=${MQTT_PORT}' >> $filename"
sudo sh -c "echo 'MQTT_HOST=${DOMAIN}' >> $filename"
sudo sh -c "echo 'MQTT_PREFIX=${WSPREFIX}' >> $filename"


sudo sh -c " echo 'SSLREDIRECT=${SSLREDIRECT}' >> $filename"


cd ..

sudo docker-compose -f docker_node_install.yml up
sudo docker-compose -f docker_nuxt_build.yml up
sudo docker-compose -f docker_compose_production.yml up -d








