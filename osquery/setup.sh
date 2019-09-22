#!/bin/bash
echo "Install tools needed"
yum install -y yum-utils > /dev/null

curl -L https://pkg.osquery.io/rpm/GPG -o /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery > /dev/null
yum-config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo > /dev/null
yum-config-manager --enable osquery-s3-rpm > /dev/null
echo "Installing osquery"
yum install -y osquery > /dev/null


curl https://gitlab.com/jwhite1st/fleet-osquery/raw/master/osquery/fleetconnect.service -o /etc/systemd/system/fleetconnect.service > /dev/null


read -p "Please enter the hostname/ip of your fleet server. (Include port): " server 
read -p "Please enter the encroll secret from your server:" secret

openssl s_client -showcerts -connect $server </dev/null 2>/dev/null|openssl x509 -outform PEM > /var/osquery/server.pem
sed -i -e "s/oldip\b/$server/g" /etc/systemd/system/fleetconnect.service
echo "$secret" > /var/osquery/enroll_secret

echo 'Finishing Up'
systemctl daemon-reload
systemctl start fleetconnect.service
systemctl enable fleetconnect.service

clear
echo -e "
\e[92m
             _   _     _____                                __  
     /\     | | | |   |  __ \                            _  \ \ 
    /  \    | | | |   | |  | |   ___    _ __     ___    (_)  | |
   / /\ \   | | | |   | |  | |  / _ \  | '_ \   / _ \        | |
  / ____ \  | | | |   | |__| | | (_) | | | | | |  __/    _   | |
 /_/    \_\ |_| |_|   |_____/   \___/  |_| |_|  \___|   (_)  | |
                                                            /_/  
\e[0m
Created by \e[96mJacob White \e[0m                                                        
"