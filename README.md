## Fabric 1.1.0-alpha feature eventfilter

**Pre-req**: Need the docker-images to run e2e_cli sample with or w/o TLS

**Step 1 : Generate the eventsclient executable**
*As of this writing cherry picked changes from here:
git fetch ssh://<insert LFID>@gerrit.hyperledger.org:29418/fabric refs/changes/19/16919/5 && git cherry-pick FETCH_HEAD*
```
cd fabric/examples/events/eventsclient
go build
```
You will see the executable **eventsclient** if there are no compilations errors.

**Step 2 : Run e2e_cli with the following command**
```
./network_setup.sh restart mychannel 100000
```

**Step 3 : establish connection from the client to the peer to obtain the blocks**

**NOTE**: 
*In order to allow the eventsclient sample to connect to peers on e2e_cli example with a TLS enabled, the easiest way would be to map **127.0.0.1** to the hostname of peer
that you are connecting to, such as **peer0.org1.example.com**. For example on
**\*nix** based systems this would be an entry in **/etc/hosts** file.*
```
CORE_PEER_MSPCONFIGPATH=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp CORE_PEER_LOCALMSPID=Org1MSP ./eventsclient -channelID=mychannel -server=peer0.org1.example.com:7051 -tls=true -mTls=true -filtered=true -quiet=false -seek=3 -clientKey=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.key -clientCert=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.crt -rootCert=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/ca.crt
```
The output would be some thing like following
```
2018-01-25 14:57:03.176 EST [eventsclient] readEventsStream -> INFO 001 Received filtered block:
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
2018-01-25 14:57:03.177 EST [eventsclient] readEventsStream -> INFO 002 Got status &{SUCCESS}
```

some other options :
```
./eventsclient -channelID=mychannel" -quiet=false -server 127.0.0.1:7051
./eventsclient -channelID=mychannel" -seek=<-2|-1|0|(1..N)>
./eventsclient -channelID="mychannel" -seek=2 \-filtered=false
```
**Note**:
1. Can run different tests by changing the e2e_cli sample 
--> Create multiple channels 
--> Donot join all the peers in the script and join at later point 
--> Send Invokes concurrently (for invalid transactions) etc.,
2. Generate multiple client to listen on multiple channels (Refer the scripts channel1 and channel2)
3. All these tests can re-run by setting the *-filtered* flag to false to retreive unfiltered blocks
```
ex:
./eventsclient -channelID mychannel -filtered=false
```
