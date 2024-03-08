# SPDX-FileCopyrightText: 2023 - 2024 Daniel Wolf <nephatrine@gmail.com>
#
# SPDX-License-Identifier: ISC

FROM code.nephatrine.net/nephnet/nxb-golang:latest AS builder1

ARG WRITEFREELY_VERSION=v0.15.0
RUN git -C /root clone -b "$WRITEFREELY_VERSION" --single-branch --depth=1 https://github.com/writefreely/writefreely.git
RUN echo "====== COMPILE WRITEFREELY BACKEND ======" \
 && cd /root/writefreely \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) build \
 && cmd/writefreely/writefreely config generate

FROM code.nephatrine.net/nephnet/nxb-alpine:latest AS builder2

ARG WRITEFREELY_VERSION=v0.15.0
COPY --from=builder1 /root/writefreely/ /root/writefreely/

ARG NODE_OPTIONS=--openssl-legacy-provider
RUN echo "====== COMPILE WRITEFREELY FRONTEND ======" \
 && cd /root/writefreely \
 && sed -i 's/sudo //g' less/install-less.sh && less/install-less.sh \
 && make -j$(( $(getconf _NPROCESSORS_ONLN) / 2 + 1 )) ui

FROM code.nephatrine.net/nephnet/alpine-s6:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk add --no-cache sqlite

ENV WRITEFREELY_VERSION=1500
COPY --from=builder2 /root/writefreely/cmd/writefreely/writefreely /usr/bin/
COPY --from=builder2 /root/writefreely/config.ini /etc/writefreely.ini.sample
COPY --from=builder2 /root/writefreely/static/ /var/www/writefreely/static/
COPY --from=builder2 /root/writefreely/pages/ /var/www/writefreely/pages/
COPY --from=builder2 /root/writefreely/templates/ /var/www/writefreely/templates/
COPY override /

EXPOSE 70/tcp 8080/tcp
