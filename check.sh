#!/bin/sh


GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

/usr/sbin/xl2tpd -p /var/run/xl2tpd.pid -c /etc/xl2tpd/xl2tpd.conf -C /var/run/xl2tpd/l2tp-control -D &
sleep 5
while true;
do
  echo -e "[${PURPLE}L2TP MONITOR${NC}] SETTING ${BLUE}IPSEC${NC} UP..."
  ipsec auto --up L2TP-PSK
  sleep 7

  echo -e "[${PURPLE}L2TP MONITOR${NC}] SETTING ${YELLOW}L2TP${NC} UP..."
  echo "c myVPN" > /var/run/xl2tpd/l2tp-control
  sleep 3

  ip r add ${HEARTBEAT_IP} via ${VPN_GATEWAY} dev ppp0
  echo -e "[${PURPLE}L2TP MONITOR${NC}] TRYING TO ${GREEN}PING${NC} MONITORED IP..."
  ping -c 1 $HEARTBEAT_IP | tail -1 | cut -d '/' -f 4 | xargs -I []  curl -k -s "http://$REPORT_IP/api/push/$MONITOR_ID?status=up&msg=OK&ping=[]"
  sleep 3

  echo -e "\n[${PURPLE}L2TP MONITOR${NC}] SETTING ${YELLOW}L2TP${NC} DOWN..."
  echo "d myvpn" > /var/run/xl2tpd/l2tp-control
  sleep 7

  echo -e "[${PURPLE}L2TP MONITOR${NC}] SETTING ${BLUE}IPSEC${NC} DOWN..."
  ipsec auto --asynchronous --down L2TP-PSK

  #total sleep during run: 20s
  echo -e "[${PURPLE}L2TP MONITOR${NC}] ${BLUE}sleeping${NC} $(echo "${HEARTBEAT_INTERVAL} * 60" | bc) s...";
  sleep $(echo "${HEARTBEAT_INTERVAL} * 60-20" | bc);
done;
