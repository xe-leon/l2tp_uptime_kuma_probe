#!/bin/sh

# template out all the config files using env vars
sed -i 's/right=.*/right='$VPN_SERVER_IPV4'/' /etc/ipsec.conf
echo ': PSK "'$VPN_PSK'"' > /etc/ipsec.secrets
sed -i 's/lns = .*/lns = '$VPN_SERVER_IPV4'/' /etc/xl2tpd/xl2tpd.conf
sed -i 's/name .*/name '$VPN_USERNAME'/' /etc/ppp/options.l2tpd.client
sed -i 's/password .*/password '$VPN_PASSWORD'/' /etc/ppp/options.l2tpd.client

sed -i 's/ike=.*/ike='$VPN_IKE'\n    esp='$VPN_ESP'/' /etc/ipsec.conf

#refuse-eap
#refuse-chap
#refuse-mschap
#require-pap

sed -i 's/require-mschap-v2.*/refuse-chap\nrefuse-mschap\nrequire-pap/' /etc/ppp/options.l2tpd.client

sed -i 's/mru 1410.*/mru '$VPN_MRU'/' /etc/ppp/options.l2tpd.client
sed -i 's/mtu 1410.*/mtu '$VPN_MTU'/' /etc/ppp/options.l2tpd.client

# startup ipsec tunnel
ipsec initnss
sleep 1
ipsec pluto --stderrlog --config /etc/ipsec.conf
sleep 5
exec sh -c ./check.sh