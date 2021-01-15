#require: og-payment.addr og-payment.skey stake2.skey

#AMOUNT to move from old payment address to new one
AMOUNT=40000000
NETWORK="--mainnet"
#NETWORK="--testnet-magic 1097911063"
#ERA="--mary-era"
ERA="--allegra-era"

cardano-cli query utxo \
$ERA \
--address $(cat og-payment.addr) \
$NETWORK

read -p "Please enter TxHash#TxId (og-payment.addr): " TX
read -p "Please enter Balance (Lovelace) of $TX (og-payment.addr): " BALANCE

## prepare tx

cardano-cli transaction build-raw \
$ERA \
--tx-in $TX \
--tx-out $(cat og-payment.addr)+0 \
--tx-out $(cat payment.addr)+$AMOUNT \
--ttl 0 \
--fee 0 \
--out-file tx.raw \

## calculate fee

FEE=$(cardano-cli transaction calculate-min-fee \
--tx-body-file tx.raw \
--tx-in-count 1 \
--tx-out-count 2 \
--witness-count 1 \
--byron-witness-count 0 \
$NETWORK \
--protocol-params-file protocol.json | tr -d " Lovelace")
FEE=$( expr $FEE + 1500 )
echo "Fee = $FEE"

### Calculate the change to send back to payment address after including the deposit

SENDBACK=$( expr $BALANCE - $FEE - $AMOUNT )
echo "SendBack = $SENDBACK"

### TTl

TTL=$(cardano-cli query tip $NETWORK | tail -n2 | head -n1 | tr -d "\" slotNo:")
TTL=$( expr $TTL + 400 )
echo "TTL = $TTL"

## build tx

cardano-cli transaction build-raw \
$ERA \
--tx-in $TX \
--tx-out $(cat og-payment.addr)+$SENDBACK \
--tx-out $(cat payment.addr)+$AMOUNT \
--ttl $TTL \
--fee $FEE \
--out-file tx.raw \

## Sign tx

cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file og-payment.skey \
$NETWORK \
--out-file tx.signed

## submit tx

cardano-cli transaction submit \
--tx-file tx.signed \
$NETWORK
