#!/bin/bash

# Startup script to initialize and boot a reth instance.
#
# This script assumes the following files:
#  - `reth` binary is located in the filesystem root
#  - `genesis.json` file is located in the filesystem root (mandatory)
#  - `chain.rlp` file is located in the filesystem root (optional)
#  - `blocks` folder is located in the filesystem root (optional)
#
# This script can be configured using the following environment variables:
#
#  - HIVE_BOOTNODE             enode URL of the remote bootstrap node
#  - HIVE_NETWORK_ID           network ID number to use for the eth protocol
#  - HIVE_FORK_HOMESTEAD       block number of the homestead transition
#  - HIVE_FORK_DAO_BLOCK       block number of the DAO hard-fork transition
#  - HIVE_FORK_TANGERINE       block number of TangerineWhistle
#  - HIVE_FORK_SPURIOUS        block number of SpuriousDragon
#  - HIVE_FORK_BYZANTIUM       block number for Byzantium transition
#  - HIVE_FORK_CONSTANTINOPLE  block number for Constantinople transition
#  - HIVE_FORK_PETERSBURG      block number for ConstantinopleFix/Petersburg transition
#  - HIVE_FORK_ISTANBUL        block number for Istanbul transition
#  - HIVE_FORK_MUIR_GLACIER    block number for MuirGlacier transition
#  - HIVE_SHANGHAI_TIMESTAMP   timestamp for Shanghai transition
#  - HIVE_CANCUN_TIMESTAMP     timestamp for Cancun transition
#  - HIVE_LOGLEVEL             client log level
#
# These flags are NOT supported by reth
#
#  - HIVE_GRAPHQL_ENABLED      turns on GraphQL server
#  - HIVE_CLIQUE_PRIVATEKEY    private key for clique mining
#  - HIVE_NODETYPE             sync and pruning selector (archive, full, light)
#  - HIVE_MINER                address to credit with mining rewards
#  - HIVE_MINER_EXTRA          extra-data field to set for newly minted blocks

# Immediately abort the script on any error encountered
set -ex

case "$HIVE_LOGLEVEL" in
    0|1) FLAGS="$FLAGS -v" ;;
    2)   FLAGS="$FLAGS -vv" ;;
    3)   FLAGS="$FLAGS -vvv" ;;
    4)   FLAGS="$FLAGS -vvvv" ;;
    5)   FLAGS="$FLAGS -vvvvv" ;;
esac

# Create the data directory.
DATADIR="/reth-hive-datadir"
mkdir $DATADIR
FLAGS="$FLAGS --datadir $DATADIR"

# TODO If a specific network ID is requested, use that
#if [ "$HIVE_NETWORK_ID" != "" ]; then
#    FLAGS="$FLAGS --networkid $HIVE_NETWORK_ID"
#else
#    FLAGS="$FLAGS --networkid 1337"
#fi

# Configure the chain.
mv /genesis.json /genesis-input.json
jq -f /mapper.jq /genesis-input.json > /genesis.json

# Dump genesis. 
if [ "$HIVE_LOGLEVEL" -lt 4 ]; then
    echo "Supplied genesis state (trimmed, use --sim.loglevel 4 or 5 for full output):"
    jq 'del(.alloc[] | select(.balance == "0x123450000000000000000"))' /genesis.json
else
    echo "Supplied genesis state:"
    cat /genesis.json
fi

echo "Command flags till now:"
echo $FLAGS