# Fleet Installation Script

This is a script that install [fleet](https://github.com/kolide/fleet)

## Options

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
