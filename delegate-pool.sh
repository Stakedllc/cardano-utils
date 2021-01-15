NETWORK="--mainnet"
#NETWORK="--testnet-magic 1097911063"
#ERA="--mary-era"
ERA="--allegra-era"
### pool id can be get from cardanoscan.io --> "Pool Id"
POOL_ID="b91e740582b7166b2238c19dbb081de4cb86be0b27ead58401510c05"

###### DELEGATION CERT

cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --stake-pool-id "$POOL_ID" \
    --out-file delegation.cert

read -p "Please enter TxHash#TxId: " TX
read -p "Please enter Balance (Lovelace) of $TX: " BALANCE

## prepare tx

cardano-cli transaction build-raw \
$ERA \
--tx-in $TX \
--tx-out $(cat payment.addr)+0 \
--ttl 0 \
--fee 0 \
--out-file tx.raw \
--certificate-file delegation.cert

## calculate fee

FEE=$(cardano-cli transaction calculate-min-fee \
--tx-body-file tx.raw \
--tx-in-count 1 \
--tx-out-count 1 \
--witness-count 1 \
--byron-witness-count 0 \
$NETWORK \
--protocol-params-file protocol.json | tr -d " Lovelace")
FEE=$( expr $FEE + 1500 )
echo "Fee = $FEE"

### Calculate the change to send back to payment address after including the deposit

SENDBACK=$( expr $BALANCE - $FEE )
echo "SendBack = $SENDBACK"

### TTl

TTL=$(cardano-cli query tip $NETWORK | tail -n2 | head -n1 | tr -d "\" slotNo:")
TTL=$( expr $TTL + 400 )
echo "TTL = $TTL"

## build tx

cardano-cli transaction build-raw \
$ERA \
--tx-in $TX \
--tx-out $(cat payment.addr)+$SENDBACK \
--ttl $TTL \
--fee $FEE \
--out-file tx.raw \
--certificate-file delegation.cert

## Sign tx

cardano-cli transaction sign \
--tx-body-file tx.raw \
--signing-key-file payment.skey \
--signing-key-file stake.skey \
$NETWORK \
--out-file tx.signed

## submit tx

cardano-cli transaction submit \
--tx-file tx.signed \
$NETWORK
