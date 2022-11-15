FROM alpine:latest

RUN apk update \
    && apk add bash krb5 \
    && rm -rf /var/cache/apk/*

WORKDIR /
COPY . .
RUN chmod +x rekinit.sh

ENTRYPOINT ["bash", "rekinit.sh"]
