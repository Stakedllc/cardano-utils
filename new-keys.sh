NETWORK="--mainnet"
#NETWORK="--testnet-magic 1097911063"
#ERA="--mary-era"
ERA="--allegra-era"

## Payment Keys

cardano-cli address key-gen \
--verification-key-file payment.vkey \
--signing-key-file payment.skey

## Stake keys

cardano-cli stake-address key-gen \
--verification-key-file stake.vkey \
--signing-key-file stake.skey

## Payment address

cardano-cli address build \
--payment-verification-key-file payment.vkey \
--stake-verification-key-file stake.vkey \
--out-file payment.addr \
$NETWORK

echo
echo "YOUR payment address = $(cat payment.addr)"
echo

## Stake address

cardano-cli stake-address build \
--stake-verification-key-file stake.vkey \
--out-file stake.addr \
$NETWORK

echo
echo "YOUR stake address = $(cat stake.addr)"
echo

## Protocol params

cardano-cli query protocol-parameters \
$ERA \
$NETWORK \
--out-file protocol.json
