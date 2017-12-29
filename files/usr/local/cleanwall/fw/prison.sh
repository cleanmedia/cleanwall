#!/bin/bash
# 08.07.2017 CC BY-SA 4.0 license, Renato Mercurio, Cleanmedia

# variables:
PATH='/sbin:/bin:/usr/bin'
FWPATH=/usr/local/cleanwall/fw
source ${FWPATH}/vars.v4.load

ACTION=$1
MAC=$2


## INTERNET WEB PRISON FOR MAC
##############################

start_prison()
{
  iptables -t nat -A PREROUTING -s $LAN ! -d $LAN -p tcp --dport 80 -m mac --mac-source $MAC -j DNAT --to $SPIP 
  iptables -t nat -A PREROUTING -s $LAN ! -d $LAN -p tcp --dport 443 -m mac --mac-source $MAC -j DNAT --to $SPIP
}

stop_prison()
{
  iptables -t nat -D PREROUTING -s $LAN ! -d $LAN -p tcp --dport 80 -m mac --mac-source $MAC -j DNAT --to $SPIP
  iptables -t nat -D PREROUTING -s $LAN ! -d $LAN -p tcp --dport 443 -m mac --mac-source $MAC -j DNAT --to $SPIP
}


case "$ACTION" in
  start)
        start_prison
        ;;
  stop)
        stop_prison
        ;;
  default)
	;;
esac

