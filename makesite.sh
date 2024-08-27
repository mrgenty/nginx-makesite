#!/bin/bash

show_welcome() {
    cat << 'EOF'
 .----------------.  .----------------.  .-----------------. .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |    ______    | || |  _________   | || | ____  _____  | || |  _________   | || |  ____  ____  | |
| |  .' ___  |   | || | |_   ___  |  | || ||_   \|_   _| | || | |  _   _  |  | || | |_  _||_  _| | |
| | / .'   \_|   | || |   | |_  \_|  | || |  |   \ | |   | || | |_/ | | \_|  | || |   \ \  / /   | |
| | | |    ____  | || |   |  _|  _   | || |  | |\ \| |   | || |     | |      | || |    \ \/ /    | |
| | \ `.___]  _| | || |  _| |___/ |  | || | _| |_\   |_  | || |    _| |_     | || |    _|  |_    | |
| |  `._____.'   | || | |_________|  | || ||_____|\____| | || |   |_____|    | || |   |______|   | |
| |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 
EOF
    echo ""
    echo "Welcome to the Nginx Auto Configuration Script!"
    echo "Benvenuto nello script di configurazione automatica di Nginx!"
    echo ""
}


ask_question() {
    local prompt="$1"
    local default="$2"
    local result=""

    read -p "$prompt [$default]: " result
    if [ -z "$result" ]; then
        echo "$default"
    else
        echo "$result"
    fi
}

select_language() {
    echo "Please select a language / Seleziona una lingua:"
    echo "1) English"
    echo "2) Italiano"
    read -p "Choice / Scelta [1/2]: " lang_choice

    case $lang_choice in
        1)
            LANGUAGE="EN"
            ;;
        2)
            LANGUAGE="IT"
            ;;
        *)
            echo "Invalid choice / Scelta non valida. Defaulting to English / Predefinito in inglese."
            LANGUAGE="EN"
            ;;
    esac
}

show_welcome

select_language

if [ "$LANGUAGE" == "EN" ]; then
    CERTBOT_NOT_FOUND="Error: certbot is not installed."
    CERTBOT_INSTALL_INSTRUCTIONS="To install certbot, run the following commands:"
    DOMAIN_PROMPT="Enter the server name (e.g., example.com)"
    SSL_PROMPT="Do you want to enable SSL? (y/n)"
    PORT_PROMPT="Enter the listening port"
    DIR_CREATED="Directory created"
    SUCCESS_MESSAGE="Configuration for"
    RELOADED_MESSAGE="created successfully and Nginx reloaded."
else
    CERTBOT_NOT_FOUND="Errore: certbot non è installato."
    CERTBOT_INSTALL_INSTRUCTIONS="Per installare certbot, esegui i seguenti comandi:"
    DOMAIN_PROMPT="Inserisci il nome del server (es: example.com)"
    SSL_PROMPT="Vuoi abilitare SSL? (s/n)"
    PORT_PROMPT="Inserisci la porta di ascolto"
    DIR_CREATED="Creata directory"
    SUCCESS_MESSAGE="Configurazione per"
    RELOADED_MESSAGE="creata con successo e Nginx ricaricato."
fi

if ! command -v certbot &> /dev/null
then
    echo "$CERTBOT_NOT_FOUND"
    echo "$CERTBOT_INSTALL_INSTRUCTIONS"
    if [ "$LANGUAGE" == "EN" ]; then
        echo "  sudo apt update"
        echo "  sudo apt install certbot python3-certbot-nginx"
    else
        echo "  sudo apt update"
        echo "  sudo apt install certbot python3-certbot-nginx"
    fi
    exit 1
fi

server_name=$(ask_question "$DOMAIN_PROMPT" "example.com")

root_directory="/var/www/$server_name"

enable_ssl=$(ask_question "$SSL_PROMPT" "n")

if [ ! -d "$root_directory" ]; then
    mkdir -p "$root_directory"
    echo "$DIR_CREATED $root_directory"
fi

config_file="/etc/nginx/sites-available/$server_name"

if [ "$enable_ssl" == "s" ] || [ "$enable_ssl" == "y" ]; then

    echo "server {" > $config_file
    echo "    listen 80;" >> $config_file
    echo "    server_name $server_name;" >> $config_file
    echo "    return 301 https://\$host\$request_uri;" >> $config_file
    echo "}" >> $config_file

    echo "server {" >> $config_file
    echo "    listen 443 ssl;" >> $config_file
    echo "    server_name $server_name;" >> $config_file
    echo "    ssl_certificate /etc/nginx/ssl/$server_name.crt;" >> $config_file
    echo "    ssl_certificate_key /etc/nginx/ssl/$server_name.key;" >> $config_file
    echo "    root $root_directory;" >> $config_file
    echo "    index index.html index.htm;" >> $config_file
    echo "    location / {" >> $config_file
    echo "        try_files \$uri \$uri/ =404;" >> $config_file
    echo "    }" >> $config_file
    echo "    error_page 404 /404.html;" >> $config_file
    echo "    error_page 500 502 503 504 /50x.html;" >> $config_file
    echo "    location = /50x.html {" >> $config_file
    echo "        root /usr/share/nginx/html;" >> $config_file
    echo "    }" >> $config_file
    echo "}" >> $config_file
else

    echo "server {" > $config_file
    echo "    listen 80;" >> $config_file
    echo "    server_name $server_name;" >> $config_file
    echo "    root $root_directory;" >> $config_file
    echo "    index index.html index.htm;" >> $config_file
    echo "    location / {" >> $config_file
    echo "        try_files \$uri \$uri/ =404;" >> $config_file
    echo "    }" >> $config_file
    echo "    error_page 404 /404.html;" >> $config_file
    echo "    error_page 500 502 503 504 /50x.html;" >> $config_file
    echo "    location = /50x.html {" >> $config_file
    echo "        root /usr/share/nginx/html;" >> $config_file
    echo "    }" >> $config_file
    echo "}" >> $config_file
fi

ln -s $config_file /etc/nginx/sites-enabled/

nginx -t && systemctl reload nginx

if [ "$enable_ssl" == "s" ] || [ "$enable_ssl" == "y" ]; then
    sudo certbot --nginx -d $server_name -d www.$server_name

    nginx -t && systemctl reload nginx
fi

echo "$SUCCESS_MESSAGE $server_name $RELOADED_MESSAGE"
