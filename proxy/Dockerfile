FROM ubuntu:26.04
RUN apt-get update \
 && apt-get install -y --no-install-recommends squid \
 && rm -rf /var/lib/apt/lists/*
COPY squid.conf /etc/squid/squid.conf
EXPOSE 3128
# Remove stale PID file before starting to avoid exit code 1 on subsequent starts.
# Squid creates /var/run/squid.pid when running. If the container is stopped
# and restarted, this stale file causes squid to refuse starting.
ENTRYPOINT ["sh", "-c", "rm -f /var/run/squid.pid && exec squid -N -d 1 -f /etc/squid/squid.conf"]
