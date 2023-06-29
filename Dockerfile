FROM nephatrine/nxbuilder:golang AS builder1

ARG WRITEFREELY_VERSION=v0.13.2
RUN git -C /root clone -b "$WRITEFREELY_VERSION" --single-branch --depth=1 https://github.com/writefreely/writefreely.git

RUN echo "====== COMPILE WRITEFREELY ======" \
 && cd /root/writefreely \
 && go get -u github.com/jteeuwen/go-bindata/go-bindata \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) ./tmp/go-bindata \
 && cp ./tmp/go-bindata /go/bin/ \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) build \
 && cmd/writefreely/writefreely config generate

FROM nephatrine/nxbuilder:alpine AS builder2

ARG WRITEFREELY_VERSION=v0.13.2
COPY --from=builder1 /root/writefreely/ /root/writefreely/

ARG NODE_OPTIONS=--openssl-legacy-provider
RUN echo "====== COMPILE WRITEFREELY ======" \
 && cd /root/writefreely \
 && sed -i 's/sudo //g' less/install-less.sh && less/install-less.sh \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) ui

FROM nephatrine/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache sqlite

ENV WRITEFREELY_VERSION=1302
COPY --from=builder2 /root/writefreely/cmd/writefreely/writefreely /usr/bin/
COPY --from=builder2 /root/writefreely/config.ini /etc/writefreely.ini.sample
COPY --from=builder2 /root/writefreely/static/ /var/www/writefreely/static/
COPY --from=builder2 /root/writefreely/pages/ /var/www/writefreely/default-pages/
COPY --from=builder2 /root/writefreely/templates/ /var/www/writefreely/default-templates/
COPY override /

EXPOSE 70/tcp 8080/tcp
