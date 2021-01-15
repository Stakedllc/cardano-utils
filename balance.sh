NETWORK="--mainnet"
#NETWORK="--testnet-magic 1097911063"
#ERA="--mary-era"
ERA="--allegra-era"

### payment addr

echo
echo "YOUR payment address = $(cat payment.addr)"
echo

## Balance
echo
echo "Balance"
echo

cardano-cli query utxo \
$ERA \
--address $(cat payment.addr) \
$NETWORK

## Protocol params
echo
echo "Protocol settings"
echo

cat protocol.json