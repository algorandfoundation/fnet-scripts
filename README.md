# Fnet scripts

## Fnet setup

Set up algorand, preferably via apt repo & systemd

Stop algorand: `sudo systemctl stop algorand`

Run configure: `./configure.sh`

Start: `sudo systemctl start algorand`

Check genesis ID from goal node `goal node status`

`update.sh` can be used to automate resetting your node along with the neetwork.

**⚠️ IF you are not using systemd, you need to adapt `update.sh` to stop and start your node when the network resets**

## Table of Contents

### common.sh

Configures some common variables. Supports $ALGORAND_DATA.

Use this to override values if necessary

### configure.sh

**Needs to be run as root**

1) DELETES network data directory, e.g. /var/lib/algorand/fnet-v1
1) configures config.json with DNS Bootstrap ID
1) fetches and places genesis.json

### update.sh

**Needs to be run as root**

1) Compares local genesis.json with the latest one from an fnet relay. If they are the same, exit
2) Otherwise, stops algod (assumes systemd approach, `sudo systemctl stop algorand`)
3) configures genesis and wipes existing data via `configure.sh` (see above)
4) starts algod again (using systemd)

**⚠️ IF you are not using systemd, you need to adapt this script to stop and start your node properly.**

## Automating reset

You can run the `update.sh` script via cron in order to automate the node reset.

**Important: Use the root account's crontab**

`sudo crontab -e`

Add a line like this to the end. Make sure to change `/path/to/update.sh/` with your actual path to the file.

```
*/10 * * * * /path/to/update.sh
```

`*/10 * * * *` means "run this every 10 minutes". You can customize this interval using a tool [like this](https://crontab.guru)

## Expected console output 

### ./configure.sh

```
Using data dir: /var/lib/algorand
Deleted /var/lib/algorand/fnet-v1
Resolved 3 relays
Got genesis, 225 lines
Wrote /var/lib/algorand/genesis.json
Configure: OK
```

### ./update.sh

#### No changes (local is running latest)

```
Using data dir: /var/lib/algorand
Resolved 3 relays
Got genesis, 225 lines
Local genesis is up to date b5331ddfd72b7456d35a2868f28d9331 = b5331ddfd72b7456d35a2868f28d9331
Nothing to do
```

#### Genesis has changed upstream (local will be reset)

```
Using data dir: /var/lib/algorand
Resolved 3 relays
Got genesis, 225 lines
Local genesis was 0065cc089647eab78cdf92f066481983, remote was b5331ddfd72b7456d35a2868f28d9331
New genesis, nuke + restart
Stopping algod
Reconfiguring
Using data dir: /var/lib/algorand
Deleted /var/lib/algorand/fnet-v1
Resolved 3 relays
Got genesis, 225 lines
Wrote /var/lib/algorand/genesis.json
Configure: OK
Starting algod
Restarted
```
