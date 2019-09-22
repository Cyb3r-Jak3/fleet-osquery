# Fleet & Osquery Setup

This repo contains scripts that allow you to setup [fleet](https://github.com/kolide/fleet) and [osquery](https://github.com/osquery/osquery) with minimal interaction.

## Fleet

### Installation

```Bash
curl https://raw.githubusercontent.com/jwhite1st/fleet-osquery/master/fleet/setup.sh -o setup.sh
chmod +x setup.sh
./setup.sh
```

### Options

Theses are the currently supported command line options:

- ```--full```
  - Setups fleet with an email and random password.
- ```--default```
  - Generates an ssl key and cert for fleet.local
- ```--email <email>```
  - Allows you to specify the email that will be created as the admin. You do not need to be able to access it i.e. ```admin@localhost.com```.
  - It does need to have a domain.

## Service Customization

You can customize the service file to your needs. Download it to the same place where the setup script is and it will be used instead of pre-configured one.

## OSQuery

### Installation

```bash
curl https://raw.githubusercontent.com/jwhite1st/fleet-osquery/master/osquery/setup.sh -o setup.sh
chmod +x setup.sh
./setup.sh
```
