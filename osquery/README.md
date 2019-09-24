# OSQuery

## Installation

```bash
curl https://raw.githubusercontent.com/jwhite1st/fleet-osquery/master/osquery/setup.sh -o setup.sh
chmod +x setup.sh
./setup.sh
```

By default, only OSquery is installed. If you want to use it with fleet then use ```--full``

## Options

- ```--full```
  - Setups up osquery and configures it to use a fleet instance.
- ```--server <ip:port>```
  - Can specify the server ip and port
- ```--secret <enroll secret>```
  - Can specify the enroll secret
