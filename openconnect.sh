#!/bin/bash

if [ -z "$1" ]; then
    echo "$1 Configuration file must be supplied"    
    exit 22
fi

URL=`cat $1 | gawk -F "\"*,\"*" '{print $1}'`
USERNAME=`cat $1 | gawk -F "\"*,\"*" '{print $2}'`
PASSWORD=`cat $1 | gawk -F "\"*,\"*" '{print $3}'`
HOSTTOPING=`cat $1 | gawk -F "\"*,\"*" '{print $4}'`


OPENCONNECT_PID=""
HOSTREACHED=""
 
function checkOpenconnectProcess {
    ps -p $OPENCONNECT_PID &> /dev/null
    RUNNING=$?
    echo "checking vpn pid..."
}

function pingToCheckConnectivity {
    echo "pinging host..." 
    ping -c 5 $HOSTTOPING &> /dev/null
    HOSTREACHED=$?
}
 
function startOpenConnect {    
    echo "$PASSWORD" | openconnect -u $USERNAME --passwd-on-stdin $URL & OPENCONNECT_PID=$!    
}

echo "Connecting to VPN..."
startOpenConnect

 
while true
do
    sleep 20
    #echo "openconnect pid: $OPENCONNECT_PID"
    checkOpenconnectProcess
    if [ $RUNNING -ne 0 ]; then  
        echo "Reconnecting to VPN..."
        startOpenConnect 

    fi
    pingToCheckConnectivity
    if [ $HOSTREACHED -ne 0 ]; then  
        kill $OPENCONNECT_PID
        echo "Reconnecting to VPN..."
        startOpenConnect 
    fi
done
