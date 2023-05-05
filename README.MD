# Description
This image lets you monitor your L2TP server and send data to Uptime Kuma.\
It based on Alpine with installed strongswan and xl2tpd.\
It doesn't keep tunnel up all the time. It tries to connect in a set period of time, ping the resource and then disconnects.\
[Image on Docker Hub](https://hub.docker.com/r/xeleon/l2tp_uptime_kuma_probe)

# Tags available
| Tag | Description |
| :---------------------- | :-------------------|
| latest | The latest version of basic alpine image (1-alpine tag) |
| 1-alpine | Should be appliable for most use cases |
| 1-usergate | Comes with proper settings for VPN_IKE and VPN_ESP that will work with default RA VPN profile in UserGate UTM |
| 1-nightly | Development builds for testing purposes |

# Environment variables
|  Variable | Description | Default value |
| ------------- |:-------------| -----:|
| VPN_SERVER_IPV4 | L2TP Server IP Address | No value, must provide |
| VPN_PSK                              | Your preshared key |   No value, must provide|
| VPN_USERNAME                | L2TP Usernane      |    No value, must provide|
| VPN_PASSWORD                | L2TP Password      |    No value, must provide |
| REPORT_IP                          | IP address or DNS of your Uptime Kuma instance | No value, must provide | 
| PROTO                                  | Specify either http or https should be used to connect to Uptime Kuma | http |
| MONITOR_ID                       | Monitor ID inside your Uptime Kuma. Can be gathered by creating Push Monitor*  |    No value, must provide|
| HEARTBEAT_INTERVAL    | Tunnel heartbeat interval in minutes (Should be equal to Uptime Kuma's Heartbeat Interval); Recommended value: not less than 5 minutes |    5 |
| HEARTBEAT_IP                   | IP address inside VPN network that will be used to ping and report latency to Uptime Kuma; Usually just a gateway host in VPN network |    No value, must provide |
| VPN_MRU                            | Tunnel MRU  | 1400 |
| VPN_MTU                            | Tunnel MTU  | 1400 |
| VPN_IKE                               | IKE settings |    aes128-sha1-modp2048 |
| VPN_ESP                             | ESP settings |    aes128-sha1 |


*Bolded text is what you need: http:\/\/172.0.0.1/api/push/**IjnBFp33cq**?status=...

# How to use
## Docker Run
Setup environment variables for your credentials and config:
``` 
export VPN_SERVER_IPV4='1.2.3.4'
export VPN_PSK='my pre shared key'
export VPN_USERNAME='myuser'
export VPN_PASSWORD='mypass'
export REPORT_IP='uptimekuma:3001'
export MONITOR_ID='1a3b5c7d9e'
export HEARTBEAT_IP='172.16.0.1'
```
Now run it (you can daemonize of course after debugging):
```
docker run --rm -it --privileged --net=host --name l2tp-monitor-2 \
-v /lib/modules:/lib/modules:ro \
-e VPN_SERVER_IPV4 \
-e VPN_PSK \
-e VPN_USERNAME \
-e VPN_PASSWORD \
-e REPORT_IP \
-e MONITOR_ID \
-e HEARTBEAT_IP \
xeleon/l2tp_uptime_kuma_probe:latest
```
## Docker Compose
```
version: '3.5'
  services:
    l2tp_monitor:
      image: xeleon/l2tp_uptime_kuma_probe:latest
      environment:
        - VPN_SERVER_IPV4='<IP>'
        - VPN_PSK='<PSK>'
        - VPN_USERNAME='<USER>'
        - VPN_PASSWORD='<PASS>'
        - REPORT_IP='uptime_kuma'
#        - PROTO='https'  #optional
        - MONITOR_ID='<UptimeKumaMonitorID>'
        - HEARTBEAT_INTERVAL='<IntervalInMinutes>'
        - HEARTBEAT_IP='<IPtoPing>'
#        - VPN_MRU='1400' #optional
#        - VPN_MTU='1400' #optional
#        - VPN_IKE='aes128-sha1-modp2048'  #optional
#        - VPN_ESP='aes128-sha1'  #optional
      volumes:
        - /lib/modules:/lib/modules:ro
      depends_on:
        - uptime_kuma
      restart: unless-stopped

    uptime_kuma:
      image: louislam/uptime-kuma:1
      volumes:
        - uptime-kuma:/app/data
      ports:
        - "3001:3001"
      restart: unless-stopped

  volumes:
    uptime-kuma:
```

# Screenshots
Uptime Kuma push sensor received pings from container
![Uptime Kuma push sensor received pings from container](https://i.imgur.com/eeyFsFD.png)

Uptime Kuma push sensor settings
![Uptime Kuma push sensor settings](https://imgur.com/RIarqbb.png)

## License
[GNU General Public License v3.0](https://github.com/xe-leon/l2tp_uptime_kuma_probe/blob/master/LICENSE)\
Based on [ubergarm/l2tp-ipsec-vpn-client](https://hub.docker.com/r/ubergarm/l2tp-ipsec-vpn-client)\
Works with [Uptime Kuma](https://hub.docker.com/r/louislam/uptime-kuma)\
Source code of dockerfile available on [GitHub](https://github.com/)
