## A sample script to use eventsfilter

**Step 1 :** Make sure you have *eventfilter* code is available and generated executable out of it.

**Step 2 :** replace **e2e_cli/scripts/script.sh** with the **script.sh** in this repo , similarly **e2e_cli/generateArtifacts.sh** with **generateArtifacts.sh**

**Step 3 :** run e2e_cli sample for channel creation and sending transactions

**Step 4 :** run the testevents.sh

```
Usage:
     testevents.sh [-p <peer#>] [-o <org#>] [-c <channel name>] [-t <tls>] [-m <mutual tls>] [-f <filtered events>] [-q <quiet>] [-s <seek block>]
     testevents.sh -h|? (print this message)
    -p peer number, defaults to 0
    -o organization number, defaults to 1
    -c <channel name>, defaults to "mychannel"
    -t enable TLS, defaults to false
    -m enable mutual TLS, defaults to false
    -q silence the block information, defaults to false
    -f enable block filtering, defaults to false
    -s <seek number> - possible options <-2|-1|0|(1..N)>
    -n number of clients, defaults to 1

ex:
   ./testevents.sh
   ./testevents.sh -t -m -f ## Tls/mTls enabled and filtered events
```


**A sample, execution and its output**

```
./testevents.sh -t -m -f -s 3
```

```
Tls=true

Mutual TLS=true

Filtered=true

Seek=3

 Cleanup the logs
CORE_PEER_MSPCONFIGPATH=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp

CORE_PEER_LOCALMSPID=Org1MSP
2018-01-25 16:22:27.267 EST [eventsclient] readEventsStream -> INFO 001 Received filtered block:
{
	"channel_id": "mychannel",
	"filtered_transactions": [
		{
			"transaction_actions": {},
			"tx_validation_code": "VALID",
			"txid": "076733f1ac1f8bddaa89df5592bb747dcc4fdc870f5a10a522f657d95b6bfa6b",
			"type": "ENDORSER_TRANSACTION"
		}
	],
	"number": "3"
}
2018-01-25 16:22:27.268 EST [eventsclient] readEventsStream -> INFO 002 Got status  &{SUCCESS}
```
