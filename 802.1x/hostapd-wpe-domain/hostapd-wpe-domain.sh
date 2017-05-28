#!/bin/bash

# Hostapd-wpe-domain automation script v.1
# Author: Viet Luu (Mr.V)
# www: Ring0labs.com
# Running hostapd-wpe-domain within docker's container

# echo "[!] Running Hostapd-wpe-domain automation v.1 script."

usage()
{
cat << EOF
usage: $0 options

Hostapd-wpe-domain automation script v.1 - Viet Luu

Usage: hostapd-wpe.sh <option(s)

OPTIONS:
   -h      Show this message
   -q      Quick run (Only run after full setup)
   -f      Full setup (Will prompt to setup certs, and full AP configurations)
EOF
}

QUICK=
FULL=
INTERFACE=
DRIVER=
SSID=
CHANNEL=
HW_MODE=
C_NAME=
StateOrProvinceName=
LocalityName=
OrganizationName=
EmailAddress=
CommonName=
LogName=
CURRENT_PATH="`pwd`"


runCheck()
{
    if [[ $DRIVER == 'Y' ]] || [[ $DRIVER == 'y' ]]
    then
	iwconfig $INTERFACE txpower 30
    else
    	nmcli n off
    	rfkill unblock all
    	ifconfig $INTERFACE up
    fi
    echo "[!] Hostapd-wpe automation script v.1 - Viet Luu"
    docker run --rm -t -i --name=hostapd-wpe-ap -v $(pwd):/conf --privileged --net="host" hostapd-wpe-domain hostapd-wpe conf/hostapd-wpe.conf | tee $CURRENT_PATH/logs/$LogName.log
}

while getopts “hqf” OPTION
do
    case $OPTION in
        h)
             usage
             exit 1
             ;;
        q)
             QUICK=true
             FULL=false
             ;;
        f)
             FULL=true
             QUICK=false
             ;;
        ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $QUICK ]] || [[ -z $FULL ]]
then
    usage
    exit 1
else
    if [[ $FULL == true ]]
    then
        echo -n '[?] Interface [ENTER]: '
        read INTERFACE
        echo -n '[?] rtl88xxau Driver (Y/N)'
	read DRIVER
        echo -n '[?] SSID [ENTER]: '
        read SSID
        echo -n '[?] CHANNEL [ENTER]: '
        read CHANNEL
        echo -n '[?] HW_MODE (a/b/g/n) [ENTER]: '
        read HW_MODE
        echo -n '[?] COUNTRY NAME [ENTER]: '
        read C_NAME
        echo -n '[?] StateOrProvinceName [ENTER]: '
        read StateOrProvinceName
        echo -n '[?] LocalityName [ENTER]: '
        read LocalityName
        echo -n '[?] OrganizationName [ENTER]: '
        read OrganizationName
        echo -n '[?] EmailAddress [ENTER]: '
        read EmailAddress
        echo -n '[?] CommonName [ENTER]: '
        read CommonName
        echo -n '[?] Log Name [ENTER]: '
        read LogName

        # Build hostapd-wpe.conf file

        sed -i "11s/interface.*/interface=$INTERFACE/" $CURRENT_PATH/hostapd-wpe.conf 
        sed -i "25s/ssid.*/ssid=$SSID/" $CURRENT_PATH/hostapd-wpe.conf 
        sed -i "27s/channel.*/channel=$CHANNEL/" $CURRENT_PATH/hostapd-wpe.conf 
        sed -i "26s/hw_mode.*/hw_mode=$HW_MODE/" $CURRENT_PATH/hostapd-wpe.conf 

        # Remove cert folder, if exists.

        if [ -d "$CURRENT_PATH/certs" ]; then
            rm -rf "$CURRENT_PATH/certs"
            cp -r "$CURRENT_PATH/backup/certs" .
        fi

        # Build certs

        sed -i "49s/countryName.*/countryName = $C_NAME/" $CURRENT_PATH/certs/ca.cnf 
        sed -i "50s/stateOrProvinceName.*/stateOrProvinceName = $StateOrProvinceName/" $CURRENT_PATH/certs/ca.cnf 
        sed -i "51s/localityName.*/localityName = $LocalityName/" $CURRENT_PATH/certs/ca.cnf 
        sed -i "52s/organizationName.*/organizationName = $OrganizationName/" $CURRENT_PATH/certs/ca.cnf 
        sed -i "53s/emailAddress.*/emailAddress = $EmailAddress/" $CURRENT_PATH/certs/ca.cnf 
        sed -i "54s/commonName.*/commonName = $CommonName/" $CURRENT_PATH/certs/ca.cnf 

        sed -i "48s/countryName.*/countryName = $C_NAME/" $CURRENT_PATH/certs/server.cnf 
        sed -i "49s/stateOrProvinceName.*/stateOrProvinceName = $StateOrProvinceName/" $CURRENT_PATH/certs/server.cnf 
        sed -i "50s/localityName.*/localityName = $LocalityName/" $CURRENT_PATH/certs/server.cnf 
        sed -i "51s/organizationName.*/organizationName = $OrganizationName/" $CURRENT_PATH/certs/server.cnf 
        sed -i "52s/emailAddress.*/emailAddress = $EmailAddress/" $CURRENT_PATH/certs/server.cnf 
        sed -i "53s/commonName.*/commonName = $CommonName/" $CURRENT_PATH/certs/server.cnf 

        echo "[!] Saving Log to $CURRENT_PATH/logs/$LogName.log"

        # Run bootstrap

        sh $CURRENT_PATH/certs/bootstrap 

        runCheck

    else
        runCheck
    fi
fi
    
