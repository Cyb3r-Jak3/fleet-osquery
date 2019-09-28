#!/bin/bash
# shellcheck disable=SC2086

# Gets the arguments
while test $# -gt 0; do
	case "$1" in
		"--full" | "-f")
		echo "Setting up fleet";
		full="true";
		shift;;
		"--default" | "-d")
      	echo "Setting cert with default";
      	cert="true";
      	shift;;
		"--email")
		shift;
		email="$1";
		shift;;
		"--debug")
		debug="true";
		shift;;
  esac
done

# If the email is not set then it will be set.
if [[ -z $email ]]
then
	email="fleet@localhost.com"
fi
# A functions to random password
function password_gen() {
	local pass
	pass=$(head /dev/urandom | tr -dc 'A-Za-z0-9~!@#$%^&*' | head -c$1)
	echo "$pass"
}
# Install packages needed
yum install -y wget unzip > /dev/null

#Gets and copies the fleet binary
echo "Getting fleet binaries"
wget -q https://github.com/kolide/fleet/releases/latest/download/fleet.zip 
unzip fleet.zip 'linux/*' -d fleet > /dev/null
cp fleet/linux/fleet* /usr/bin/ > /dev/null

# Gets an installs MySQL

echo "Getting MySQL"
wget -q https://repo.mysql.com/mysql57-community-release-el7.rpm 
rpm -i mysql57-community-release-el7.rpm &> /dev/null
echo "Updating Packages. This can take time"
yum update -y &> /dev/null
echo "Installing MySQL"
yum install -y mysql-server &> /dev/null
echo "Starting and configuring MySQL"
systemctl start mysqld 
random_password=$(password_gen 30)
#Sets up mysql
function SQLInstall() {
temp_pass=$(awk '/A temporary password is generated for/ {a=$0} END{ print a }' /var/log/mysqld.log | awk '{print $(NF)}')
if ! mysqladmin -u root --password=${temp_pass} password $random_password
then
	echo "Failed to create mysql with password: $random_password"
	exit
fi
echo "CREATE DATABASE kolide;" | mysql -u root -p$random_password
systemctl enable mysqld
}
SQLInstall
#Installs redis
echo "Getting redis"
rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm &> /dev/null
echo "Installing redis"
yum install -y redis &> /dev/null
systemctl enable redis &> /dev/null
systemctl start redis

#Prepares the database
/usr/bin/fleet prepare db --mysql_address=127.0.0.1:3306 --mysql_database=kolide --mysql_username=root --mysql_password=$random_password

# Generates certificates
if [[ "$cert" = "true" ]]
then
	echo "Creating Certificate"
	openssl req -nodes -newkey rsa:4096 -keyout /tmp/server.key -out /tmp/server.csr -subj "/C=US/ST=Vermont/L=Burlington/O=Fleet Test/OU=Fleet/CN=fleet.local" > /dev/null
else
	openssl genrsa -out /tmp/server.key 4096
  	openssl req -new -key /tmp/server.key -out /tmp/server.csr
fi
openssl x509 -req -days 366 -in /tmp/server.csr -signkey /tmp/server.key -out /tmp/server.cert

#Gets Fleet service file
if [[ -e ./fleet.service ]]
then
	echo "Using local file"
	cp --force fleet.service /etc/systemd/system/fleet.service
else
	echo 'Getting prebuilt service file'
	curl -s https://raw.githubusercontent.com/jwhite1st/fleet-osquery/master/fleet/fleet.service -o /etc/systemd/system/fleet.service > /dev/null
fi
# Generates random string for auth_jwt_key
random_string=$(password_gen 20)

#Changes the BAD string the the randomstring
sed -i -e "s/BADSTRING\b/$random_string/g" /etc/systemd/system/fleet.service

#Changes database password
sed -i -e "s/DBPASSWORD\b/$random_password/g" /etc/systemd/system/fleet.service

#Starts and enables fleet
systemctl daemon-reload
systemctl start fleet.service
systemctl enable fleet.service

echo "Adding firewall rules"
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload > /dev/null

if [[ "$full" = "true" ]]
then
	echo "Setting up Fleet"
	fleet_password=$(password_gen 15)
	fleetctl config set --address https://localhost:8080 --tls-skip-verify
	echo "fleetctl setup --email $email --password $fleet_password"
  	fleetctl setup --email $email --password $fleet_password
	fleetctl login --email $email --password $fleet_password
  	enroll_secret=$(fleetctl get enroll-secret)
fi

if [[ "$debug" != "true" ]]; then
clear
fi

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
echo -e "Your SQL root password is \e[92m$random_password\e[0m"

if [ "$full" = "true" ]
then
	echo -e "Your fleet login is https://localhost:8080 email: \e[95m$email\e[0m password: \e[31m$fleet_password\e[0m"
	echo -e "Your enroll secret is \e[36m$enroll_secret\e[0m"
else
	echo -e "Please login to fleet and set it up. Fleet Location: \e[31mhttps://localhost:8080\e[0m"
fi
