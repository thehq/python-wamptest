FROM thehq/crossbar:0.11.1
MAINTAINER Eric Chapman <eric@thehq.io>

COPY .crossbar/ /app/.crossbar/
COPY src/ /app/src/

ENTRYPOINT cd /app/ && crossbar start
CMD ["--config", "/app/.crossbar/config.json"]