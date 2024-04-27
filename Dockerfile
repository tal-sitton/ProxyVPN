# need to use --privileged and --dns 1.1.1.1
# need to specify the PASTE_DEV_KEY and PASTE_USER_KEY as environment variables
FROM ubuntu

RUN apt-get update

RUN apt install privoxy curl openvpn psmisc -y

COPY ./privoxy-config /etc/privoxy/config

COPY ./vpn.sh /vpn.sh
RUN chmod +x /vpn.sh

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8118

CMD ["/entrypoint.sh"]

HEALTHCHECK --interval=10s --timeout=10s  --start-period=15s\
  CMD curl -x http://localhost:8118 -L https://wtfismyip.com/json