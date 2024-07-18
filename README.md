# Fnet scripts

## Fnet setup

Set up algorand, preferably via apt repo & systemd

Stop algorand: `sudo systemctl stop algorand`

Run configure: `./configure.sh`

Start: `sudo systemctl start algorand`

Check genesis ID from goal node `goal node status`

**⚠️ IF you are not using systemd, you need to adapt update.sh to stop and start your node when the network resets**

## Table of Contents

### common.sh

Configures some common variables. Supports $ALGORAND_DATA.

Use this to override values if necessary

### configure.sh

1) DELETES network data directory, e.g. /var/lib/algorand/fnet-v1
1) configures config.json with DNS Bootstrap ID
1) fetches and places genesis.json

### update.sh

1) Compares local genesis.json with the latest one from an fnet relay. If they are the same, exit
2) Otherwise, stops algod (assumes systemd approach, `sudo systemctl stop algorand`)
3) configures genesis and wipes existing data via configure.sh (see above)
4) starts algod again (using systemd)

**⚠️ IF you are not using systemd, you need to adapt this o stop and start your node when the network resets**
