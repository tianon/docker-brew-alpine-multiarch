FROM scratch
ADD alpine-minirootfs-3.6.2-ppc64le.tar.gz /

# ensure UTC instead of the default GMT
RUN [ ! -e /etc/localtime ] && apk add --no-cache --virtual .tz-utc tzdata && cp -vL /usr/share/zoneinfo/UTC /etc/localtime && apk del .tz-utc

CMD ["sh"]
