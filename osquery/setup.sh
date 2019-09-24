#!/bin/bash
# shellcheck disable=SC2086

while test $# -gt 0; do
	case "$1" in
	"--full" | "-f")
	echo "Setting up osquery to use fleet";
	full="true";
	shift;;
	"--server")
	shift;
	server="$1";
	shift;;
	"--secret")
	shift;
	secret="$1";
	;;
  esac
done


echo "Installing tools needed"
yum install -y yum-utils > /dev/null

curl -L https://pkg.osquery.io/rpm/GPG -o /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery > /dev/null
yum-config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo > /dev/null
yum-config-manager --enable osquery-s3-rpm > /dev/null
echo "Installing osquery"
yum install -y osquery > /dev/null

if [[ "$full" = "true" ]]; then

	if [[ -z $server ]]; then
		read -pr "Please enter the hostname/ip of your fleet server. (Include port): " server 
	fi

	if [[ -z $secret ]]; then
	read -pr "Please enter the encroll secret from your server:" secret
	fi

	echo "$secret" > /var/osquery/enroll_secret

	openssl s_client -showcerts -connect $server </dev/null 2>/dev/null|openssl x509 -outform PEM > /var/osquery/server.pem
	sed -i -e "s/oldip\b/$server/g" /etc/systemd/system/fleetconnect.service

	if [[ -e ./fleetconnect.service ]]; then
		echo "Using local service file"
		cp --force fleet.service /etc/systemd/system/fleetconnect.service
	else
		echo "Getting preconfigured service file"
		curl -s https://raw.githubusercontent.com/jwhite1st/fleet-osquery/master/osquery/fleetconnect.service -o /etc/systemd/system/fleetconnect.service > /dev/null
	fi
	systemctl daemon-reload
	systemctl start fleetconnect.service
	systemctl enable fleetconnect.service

fi


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