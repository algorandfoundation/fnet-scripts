# Fnet algod management scripts

## Overview 

A set of scripts to configure and manage a local **Linux/X86_64** algod for [fnet](https://fnet.algorand.green/).

The Fnet network will be reset periodically. The scripts support automatically resetting the node to follow along with the new network.

The `on-network-reset.sh` script can also be utilized to bootstrap some user actions when a new instance of the network is created, such as keyreg online, create applications, fund other addresses, etc.

Note: A dockerized flavor of this repo is available [here](https://github.com/algorandfoundation/fnet-algod-docker/)

## Fnet algod setup

1) Prerequisite: Set up algod, e.g. via `apt install -y algorand`

2) Update start.sh and stop.sh if necessary: These assume that systemd is managing the node, and specifically the command `systemctl start algorand`. If this is not the case on your system, update these files.

3) Stop algod: `sudo ./stop.sh`

4) Run configure: `./configure.sh` - configure local binaries, genesis, config. See below.

5) Start algod: `sudo ./start.sh`

## Automatic Updates

`auto-update.sh` can be used to automate resetting your node along with the network. When this script detects an upstream genesis file change, it will reset the local node data and invoke `on-network-reset.sh`.

If you want to enable automatic updating of the binary and genesis, you should register the `auto-update.sh` script via cron in order to automate the process:

**Important: Use the root account's crontab**

`sudo crontab -e`

Add a line like this to the end. Make sure to change `/path/to/update.sh/` with the correct path to the script.

```
*/10 * * * * /path/to/auto-update.sh
```

`*/10 * * * *` means "run this every 10 minutes". You can customize this interval using a tool [like this](https://crontab.guru)

**⚠️ IF you are not using systemd, you need to adapt `stop.sh` and `start.sh` to stop and start your node when the network resets**

## Table of Contents

### configure.sh

**Needs to be run as root**

1) DELETES network data directory, e.g. /var/lib/algorand/fnet-v1
2) configures config.json with DNS Bootstrap ID
3) fetches and places genesis.json
4) fetches latest fnet nightly binaries (`algod`, `goal`) and replaces them in $PATH.

⚠️  **By default this will overwrite your globally installed algod & goal binaries to the nightly versions expected by fnet**. It is not recommended to run any other algorand nodes on the same machine.

### auto-update.sh

**Needs to be run as root**

1) Compares local `genesis.json` with the latest one from an fnet relay. If they are the same, exit
2) Stops algod
3) Updates genesis and binaries via `configure.sh` (see above)
4) starts algod again (using systemd)
5) runs `on-network-reset.sh` (you can place any network bootstrap commands you want here.)

### common.sh

Configures some common variables. Supports $ALGORAND_DATA.

Use this to override values if necessary

## Utilities

Utilities you can use to manage your node or automate the user bootstrap script.

`./utils/catchup.sh` Starts fast catchup, relies on nodely API to get catchpoint

`./utils/get_balance.sh $account` Gets microALGO balance of account `$account` through local node

`./utils/get_genesis.sh` Fetches latest genesis file from a relay

`./utils/is_node_running.sh` Exits successfully if node is running and ready

`./utils/is_node_syncing.sh` Exits successfully if node is syncing

`update_binary.sh` If required, update `algod` and `goal` binaries from `fnet.algorand.green`. Validates SHA256SUMS.

`./utils/wait_for_balance.sh $account $amount` Waits until account `$account` has a balance of at least `$amount`

`./utils/wait_node_start.sh` Waits briefly for the node to start.

`./utils/wait_sync.sh $timeout` Waits for node to sync, optionally with timeout of `$timeout` seconds
