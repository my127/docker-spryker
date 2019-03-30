ARG VERSION=7.3
FROM my127/php:${VERSION}-fpm-stretch-console

# System: additional packages
# ----------------------------
RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && mkdir -p /usr/share/man/man1 \
 && mkdir -p /usr/share/man/man7 \
 && apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
  # package dependencies \
    postgresql-client \
  # clean \
 && apt-get auto-remove -qq -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# PHP: additional extensions
# --------------------------
RUN cd /root/installer; ./enable.sh \
  bcmath \
  curl \
  gd \
  gmp \
  intl \
  json \
  pdo_pgsql \
  pgsql \
  readline \
  redis \
  soap

 # Tool: redis-cli
# ---------------
# we copy instead of using redis-cli or redis-tools due to inconsistent versions
COPY --from=redis:5.0 /usr/local/bin/redis-cli /usr/local/bin/redis-cli
