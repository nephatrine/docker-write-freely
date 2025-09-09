# SPDX-FileCopyrightText: 2023-2025 Daniel Wolf <nephatrine@gmail.com>
# SPDX-License-Identifier: ISC

# hadolint global ignore=DL3018

# hadolint ignore=DL3007
FROM code.nephatrine.net/nephnet/nxb-golang:latest AS builder

ARG WRITEFREELY_VERSION=v0.16.0
RUN git -C /root clone -b "$WRITEFREELY_VERSION" --single-branch --depth=1 https://github.com/writefreely/writefreely.git \
 && sed -i 's/sudo //g' /root/writefreely/less/install-less.sh

ARG NODE_OPTIONS=--openssl-legacy-provider
WORKDIR /root/writefreely
RUN make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) build \
 && cmd/writefreely/writefreely config generate \
 && less/install-less.sh \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) ui

# hadolint ignore=DL3007
FROM code.nephatrine.net/nephnet/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN apk add --no-cache sqlite && rm -rf /tmp/* /var/tmp/*

ENV WRITEFREELY_VERSION=1600
COPY --from=builder /root/writefreely/cmd/writefreely/writefreely /usr/bin/
COPY --from=builder /root/writefreely/config.ini /etc/writefreely.ini.sample
COPY --from=builder /root/writefreely/static/ /var/www/writefreely/static/
COPY --from=builder /root/writefreely/pages/ /var/www/writefreely/pages/
COPY --from=builder /root/writefreely/templates/ /var/www/writefreely/templates/
COPY override /

EXPOSE 70/tcp 8080/tcp
