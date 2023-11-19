FROM debian:trixie

LABEL key="Maintainer" value="Dirk Havemann"
LABEL key="Version" value="0.1"
LABEL key="Description" value="Docker container for Avahi and Netatalk"

ENV PATH="/container/scripts:${PATH}"

RUN apt update && apt install -y --no-install-recommends \
    avahi-daemon \
    avahi-utils \
    netatalk \
    runit \
    bash \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/#enable-dbus=.*/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf \
    && rm -vf /etc/avahi/services/*

RUN sed -i 's/\[Global\]/[Global]\n  log file = \/dev\/stdout/g' /etc/netatalk/afp.conf \
    && echo "" >> /etc/netatalk/afp.conf \
    && mkdir -p /external/avahi \
    && touch /external/avahi/not-mounted

VOLUME ["/shares"]
EXPOSE 548

COPY . /container/

RUN cat /etc/netatalk/afp.conf

HEALTHCHECK CMD ["/container/scripts/docker-healthcheck.sh"]
ENTRYPOINT ["/container/scripts/entrypoint.sh"]

CMD [ "runsvdir","-P", "/container/config/runit" ]
