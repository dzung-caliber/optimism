#!/bin/sh
set -exu

GETH_DATA_DIR=/db
GETH_CHAINDATA_DIR="$GETH_DATA_DIR/reth/chaindata"
GENESIS_FILE_PATH="${GENESIS_FILE_PATH:-/genesis.json}"
CHAIN_ID=$(cat "$GENESIS_FILE_PATH" | jq -r .config.chainId)
RPC_PORT="${RPC_PORT:-8545}"
WS_PORT="${WS_PORT:-8546}"

if [ ! -d "$GETH_CHAINDATA_DIR" ]; then
	echo "$GETH_CHAINDATA_DIR missing, running init"
	echo "Initializing genesis."
	/usr/local/bin/op-reth init \
		--datadir="$GETH_DATA_DIR" \
		--chain="$GENESIS_FILE_PATH"
else
	echo "$GETH_CHAINDATA_DIR exists."
fi

# Warning: Archive mode is required, otherwise old trie nodes will be
# pruned within minutes of starting the devnet.
# --dev \
# --rollup.compute-pending-block \
# --rollup.enable-genesis-walkback \

exec /usr/local/bin/op-reth node \
	--datadir="$GETH_DATA_DIR" \
	--http \
	--http.corsdomain="*" \
	--http.addr=0.0.0.0 \
	--http.port="$RPC_PORT" \
	--http.api=web3,debug,eth,txpool,net,admin \
	--ws \
	--ws.addr=0.0.0.0 \
	--ws.port="$WS_PORT" \
	--ws.origins="*" \
	--ws.api=debug,eth,txpool,net \
	--authrpc.addr="0.0.0.0" \
	--authrpc.port="8551" \
	--authrpc.jwtsecret=/config/jwt-secret.txt \
  --chain="$GENESIS_FILE_PATH" \
	"$@"
