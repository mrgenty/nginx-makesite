# Nginx Auto Configuration Script
This repository contains a bash script designed to automate the setup and configuration of a new website on an Nginx server. The script simplifies the process by guiding the user through several prompts to configure the server, automatically setting up the appropriate Nginx configuration files, and optionally enabling SSL using Certbot.

# Features
-Automated Nginx Configuration: Easily create Nginx configuration files for new websites, including setting up the document root and server blocks.
-SSL Support: Optionally enable SSL with Let's Encrypt using Certbot. The script handles the installation of certificates and configures Nginx for HTTPS.
-Dynamic Port Management: Automatically configures port 80 for non-SSL sites or redirects port 80 to 443 when SSL is enabled.
-Automatic Nginx Reload: The script automatically reloads Nginx after making changes, ensuring that your configurations are applied immediately.

# How to Use
-Clone this repository to your server.
-Make the script executable: chmod +x nginxmakesite.sh.
-Run the script with sudo ./nginxmakesite.sh and follow the prompts.

# Prerequisites
-An Ubuntu 24.04 server with Nginx installed.
-Certbot installed (sudo apt install certbot python3-certbot-nginx) if you plan to use SSL.
