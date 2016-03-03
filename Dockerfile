FROM alpine:latest

MAINTAINER Trevor Hartman <trevorhartman@gmail.com>

ENV APP consul-template
ENV VERSION 0.13.0

ADD https://releases.hashicorp.com/${APP}/${VERSION}/${APP}_${VERSION}_linux_amd64.zip /tmp/
ADD https://releases.hashicorp.com/${APP}/${VERSION}/${APP}_${VERSION}_SHA256SUMS      /tmp/
ADD https://releases.hashicorp.com/${APP}/${VERSION}/${APP}_${VERSION}_SHA256SUMS.sig  /tmp/

WORKDIR /tmp/

RUN apk --update add --virtual verify gpgme \
 && gpg --keyserver pgp.mit.edu --recv-key 0x348FFC4C \
 && gpg --verify /tmp/${APP}_${VERSION}_SHA256SUMS.sig \
 && apk del verify \
 && cat ${APP}_${VERSION}_SHA256SUMS | grep linux_amd64 | sha256sum -c \
 && unzip ${APP}_${VERSION}_linux_amd64.zip \
 && mv ${APP} /usr/local/bin/ \
 && rm -rf /tmp/* \
 && rm -rf /var/cache/apk/*

WORKDIR /

# Store templates in /templates
# Render them to /config
VOLUME ["/templates", "/config"]

ENTRYPOINT ["/usr/local/bin/consul-template"]
