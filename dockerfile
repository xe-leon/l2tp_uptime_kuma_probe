FROM ubergarm/l2tp-ipsec-vpn-client:latest

LABEL version="1.0"

RUN apk update
RUN apk upgrade
RUN apk add curl
RUN apk add bc

ENV VPN_ESP='aes128-sha1'
ENV VPN_IKE='aes128-sha1;modp1024'
ENV VPN_MTU='1400'
ENV VPN_MRU='1400'
ENV PROTO='http'
#ENV REPORT_IP=''
#ENV MONITOR_ID=''
ENV HEARTBEAT_INTERVAL='5'
#ENV HEARTBEAT_IP=''

COPY ./startup.sh .
RUN chmod +x ./startup.sh

COPY ./check.sh /check.sh
RUN chmod +x /check.sh

CMD ["/startup.sh"]
