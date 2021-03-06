# Fleet

## Installation

```Bash
curl https://raw.githubusercontent.com/jwhite1st/fleet-osquery/master/fleet/setup.sh -o setup.sh
chmod +x setup.sh
./setup.sh
```

## Options

Theses are the currently supported command line options:

- ```--full``` or ```-f```
  - Setups fleet with an email and random password.
- ```--default``` or ```-d```
  - Generates an ssl key and cert for fleet.local
- ```--email <email>```
  - Allows you to specify the email that will be created as the admin. You do not need to be able to access it i.e. ```admin@localhost.com```.
  - It does need to have a domain.
- ```--debug``` or ```-v```
  - Shows more information about the scripts progress.
- ```--export``` or ```-e```
  - Exported all credentials to a credentials.txt

### Service Customization

You can customize the service file to your needs. Download it to the same place where the setup script is and it will be used instead of pre-configured one.
