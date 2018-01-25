#!/bin/bash
#CORE_PEER_MSPCONFIGPATH=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp CORE_PEER_LOCALMSPID=Org1MSP ./eventsclient -channelID=mychannel -server=peer0.org1.example.com:7051 -tls=true -mTls=true -filtered=false -quiet=false -seek=-2 -clientKey=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.key -clientCert=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/client.crt -rootCert=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/ca.crt
#CORE_PEER_MSPCONFIGPATH=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp CORE_PEER_LOCALMSPID=Org2MSP ./eventsclient -channelID=mychannel -server=peer0.org2.example.com:7051 -tls=true -mTls=false -filtered=true -quiet=true -seek=-2 -clientKey=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/client.key -clientCert=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/client.crt -rootCert=/Users/ratnakar/workspace/go/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/ca.crt
# set -x
PEER=0
ORG=1
CHANNEL_NAME=mychannel
TLS=false
MUTUAL_TLS=false
FILTERED=false
VERBOSE=false
SEEK=-2
TOTAL_CLIENTS=1
PORT=7051
INC=1000

function usage () {
  #\?hfmqtp:o:c:s:
  echo "Usage: "
  echo "  testevents.sh [-p <peer#>] [-o <org#>] [-c <channel name>] [-t <tls>] [-m <mutual tls>] [-f <filtered events>] [-q <quiet>] [-s <seek block>]"
  echo "  testevents.sh -h|? (print this message)"
  echo "    -p peer number, defaults to 0"
  echo "    -o organization number, defaults to 1"
  echo "    -c <channel name>, defaults to \"mychannel\""
  echo "    -t enable TLS, defaults to false"
  echo "    -m enable mutual TLS, defaults to false"
  echo "    -q silence the block information, defaults to false"
  echo "    -f enable block filtering, defaults to false"
  echo "    -s <seek number> - possible options <-2|-1|0|(1..N)>"
  echo "    -n number of clients, defaults to 1"
  echo
  echo "ex:"
  echo "   ./testevents.sh" ## Tls/mTls disabled and unfiltered events"
  echo "   ./testevents.sh -t -m -f ## Tls/mTls enabled and filtered events"
}
while getopts "\?hfmqtp:o:c:s:n:" opt; do
  case $opt in
    p) PEER="$OPTARG"
       printf "\nPeer Number=$PEER\n"
      ;;
    o) ORG="$OPTARG"
      printf "\nOrganization number=$ORG\n"
      ;;
    c) CHANNEL_NAME="$OPTARG"
      printf "\nChannel Name=$CHANNEL_NAME\n"
      ;;
    m) MUTUAL_TLS=true
      printf "\nMutual TLS=$MUTUAL_TLS\n"
      ;;
    n) TOTAL_CLIENTS="$OPTARG"
      if [ $TOTAL_CLIENTS -lt 1 ]; then
        TOTAL_CLIENTS=1
        printf "\n==== Invalid Input, Defaulting Total Client to $TOTAL_CLIENTS ====\n"
      fi
      printf "\nTotal Client=$TOTAL_CLIENTS\n"
      ;;
    f) FILTERED=true
      printf "\nFiltered=$FILTERED\n"
      ;;
    q) VERBOSE=true
      printf "\nVerbose=$VERBOSE\n"
      ;;
    s) SEEK="$OPTARG"
      printf "\nSeek=$SEEK\n"
      ;;
    t) TLS=true
      printf "\nTls=$TLS\n"
      ;;
    \?|h) usage
      exit 1
      ;;
  esac
done


## remove old logs
printf "\n Cleanup the logs"
rm -rf log*.txt

MSPID="Org${ORG}MSP"
### read all variables
export CORE_PEER_MSPCONFIGPATH="${GOPATH}/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org${ORG}.example.com/peers/peer${PEER}.org${ORG}.example.com/msp"
export CORE_PEER_LOCALMSPID="${MSPID}"

if [ $ORG -eq 1 -a $PEER -ge 1 ]; then
  PORT=` expr $PORT + $PEER \* $INC `
elif [ $ORG -ge 2 ]
then
  PORT=` expr $PORT + \( $PEER + $ORG \) \* $INC `
fi

printf "\nCORE_PEER_MSPCONFIGPATH=$CORE_PEER_MSPCONFIGPATH\n"
printf "\nCORE_PEER_LOCALMSPID=$CORE_PEER_LOCALMSPID\n"

if [ ! -d $CORE_PEER_MSPCONFIGPATH ]; then
  printf "Make sure you set the right msp configpath"
fi

### Go to fabric/examples/eventstest folder
# cd $GOPATH/src/github.com/hyperledger/fabric-test/fabric/examples/events/eventsclient
cd $GOPATH/src/github.com/hyperledger/fabric/examples/events/eventsclient

if [ ! -f eventsclient ]; then
  go build
fi

#### start all the client(s)
if [ $TOTAL_CLIENTS -eq 1 ]; then
  ./eventsclient -channelID="${CHANNEL_NAME}" -server="peer${PEER}.org${ORG}.example.com:$PORT" -tls=$TLS -mTls=$MUTUAL_TLS -filtered=$FILTERED -quiet=$VERBOSE -seek=$SEEK -clientKey="${GOPATH}/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org${ORG}.example.com/users/Admin@org${ORG}.example.com/tls/client.key" -clientCert="${GOPATH}/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org${ORG}.example.com/users/Admin@org${ORG}.example.com/tls/client.crt" -rootCert="${GOPATH}/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org${ORG}.example.com/users/Admin@org${ORG}.example.com/tls/ca.crt"
else
  ### Build the logic to handle multiple clients
  for ((c=1;c<=$TOTAL_CLIENTS;c++))
  do
      ./eventsclient -channelID="${CHANNEL_NAME}" -server="peer${PEER}.org${ORG}.example.com:$PORT" -tls=$TLS -mTls=$MUTUAL_TLS -filtered=$FILTERED -quiet=$VERBOSE -seek=$SEEK -clientKey="${GOPATH}/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org${ORG}.example.com/users/Admin@org${ORG}.example.com/tls/client.key" -clientCert="${GOPATH}/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org${ORG}.example.com/users/Admin@org${ORG}.example.com/tls/client.crt" -rootCert="${GOPATH}/src/github.com/hyperledger/fabric/examples/e2e_cli/crypto-config/peerOrganizations/org${ORG}.example.com/users/Admin@org${ORG}.example.com/tls/ca.crt" >& log$c.txt &
  done
  #### Post process and validate the blocks
  # printf "\n\n Wait for 20 secs ..."
  # sleep 20
fi
