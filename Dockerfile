FROM debian
FROM alpine:latest

WORKDIR /work
EXPOSE 53/udp

ENV DNSMASQ_SETTINGS_FILE "/etc/dnsmasq.conf"
ENV DNS_PRIMARY_SERVER "1.1.1.1"
ENV DNS_SECONDARY_SERVER "8.8.4.4"
ENV MAL_RESPONSE_SERVER "0.0.0.0"
ENV MAL_RESOLV_SERVER_v6 "::"
ENV CACHE_SIZE="7500"


COPY ./dnsmasq.conf ./dnsmasq_tmp.conf
COPY ./malware_adblock.sh ./malware_adblock.sh
COPY ./static ./static
RUN apk update && apk upgrade && \
    apk add bash dnsmasq && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /etc/default/ && \
    rm -rf /var/cache/apk/* && \
    sh ./malware_adblock.sh ${MAL_RESPONSE_SERVER} ${MAL_RESOLV_SERVER_v6} && \
    echo -e addn-hosts=/work/hostnames.txt >> ${DNSMASQ_SETTINGS_FILE} && \
    echo -e conf-file=/work/domains.txt >> ${DNSMASQ_SETTINGS_FILE} && \
    echo -e cache-size=${CACHE_SIZE} >> ${DNSMASQ_SETTINGS_FILE}  && \
    echo -e server=${DNS_PRIMARY_SERVER} >> ${DNSMASQ_SETTINGS_FILE} && \
    echo -e server=${DNS_SECONDARY_SERVER} >> ${DNSMASQ_SETTINGS_FILE} && \
    cat ./dnsmasq_tmp.conf >> ${DNSMASQ_SETTINGS_FILE}

CMD ["dnsmasq","--no-daemon"]