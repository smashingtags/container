FROM ghcr.io/smashingtags/docker-ubuntu-noble:latest

ARG GUAC_VER="1.4.0"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    fonts-dejavu-core \
    fonts-dejavu-extra \
    freerdp2-dev \
    ghostscript \
    imagemagick-6.q16 \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libcairo2-dev \
    libfreerdp-client2-2 \
    libjpeg-dev \
    libjpeg-turbo8-dev \
    libossp-uuid-dev \
    libpango1.0-dev \
    libpng-dev \
    libpulse-dev \
    libssh2-1-dev \
    libssl-dev \
    libswscale-dev \
    libtelnet-dev \
    libtool-bin \
    libvncserver-dev \
    libvorbis-dev \
    libwebp-dev \
    libwebsockets-dev \
    make \
    openssh-client \
    xvfb && \
  echo "**** install guacamole server ****" && \
  mkdir -p /buildout && \
  cd /buildout && \
  curl -L -o guacamole-server.tar.gz \
    "https://archive.apache.org/dist/guacamole/${GUAC_VER}/source/guacamole-server-${GUAC_VER}.tar.gz" && \
  tar -xzf guacamole-server.tar.gz && \
  cd guacamole-server-${GUAC_VER} && \
  ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --with-init-dir=/etc/init.d \
    --without-SUPPORT && \
  make -j$(nproc) && \
  make install && \
  ldconfig && \
  echo "**** cleanup ****" && \
  apt-get remove -y \
    autoconf \
    automake \
    build-essential \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libcairo2-dev \
    libjpeg-dev \
    libjpeg-turbo8-dev \
    libossp-uuid-dev \
    libpango1.0-dev \
    libpng-dev \
    libpulse-dev \
    libssh2-1-dev \
    libssl-dev \
    libswscale-dev \
    libtelnet-dev \
    libtool-bin \
    libvncserver-dev \
    libvorbis-dev \
    libwebp-dev \
    libwebsockets-dev \
    make && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf \
    /buildout \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY root/ /

EXPOSE 8080

VOLUME /config
