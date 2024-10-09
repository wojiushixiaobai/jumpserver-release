FROM debian:bookworm-slim AS stage-1
ARG TARGETARCH

ARG DEPENDENCIES="                    \
        ca-certificates               \
        curl                          \
        wget"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && apt-get update \
    && apt-get -y install --no-install-recommends ${DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash

WORKDIR /opt

ARG CHECK_VERSION=v1.0.4
RUN set -e \
    && wget --quiet https://github.com/jumpserver-dev/healthcheck/releases/download/${CHECK_VERSION}/check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz \
    && tar -xf check-${CHECK_VERSION}-linux-${TARGETARCH}.tar.gz -C /usr/local/bin/ check \
    && chown root:root /usr/local/bin/check \
    && chmod 755 /usr/local/bin/check \
    && rm -f /opt/*.tar.gz

ARG VERSION=v4.2.0

COPY dist/lina-${VERSION}.tar.gz /opt
COPY dist/luna-${VERSION}.tar.gz /opt

RUN set -e \
    && mkdir -p /opt/lina /opt/luna \
    && tar -xf lina-${VERSION}.tar.gz -C /opt/lina --strip-components=1 \
    && tar -xf luna-${VERSION}.tar.gz -C /opt/luna --strip-components=1 \
    && chown -R root:root /opt/lina /opt/luna \
    && rm -f /opt/*.tar.gz

RUN set -e \
    && mkdir -p /opt/download \
    && wget --quiet https://github.com/jumpserver-dev/jumpserver-release/releases/download/${VERSION}/web-${VERSION}.tar.gz \
    && tar -xf web-${VERSION}.tar.gz -C /opt/download --strip-components=1 \
    && chown -R root:root /opt/download \
    && rm -f /opt/*.tar.gz

COPY dockerfile/web/nginx.conf /etc/nginx/nginx.conf
COPY dockerfile/web/entrypoint.sh /docker-entrypoint.d/99-check-core-ready.sh

FROM nginx:1.25-bookworm
ENV LANG=en_US.UTF-8

ARG DEPENDENCIES="                    \
        ca-certificates               \
        logrotate"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -e \
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES}

COPY --from=stage-1 /opt /opt
COPY --from=stage-1 /usr/local/bin /usr/local/bin
COPY --from=stage-1 /etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=stage-1 /docker-entrypoint.d/99-check-core-ready.sh /docker-entrypoint.d/99-check-core-ready.sh

WORKDIR /opt

ARG VERSION=v4.2.0
ENV VERSION=${VERSION}

VOLUME /var/log/nginx
