FROM alpine
RUN apk --no-cache add \
    curl \
    jq \
    bash

COPY run_docker.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]