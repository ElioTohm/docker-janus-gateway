FROM debian:buster-slim 

ARG BUILD_SRC="/usr/local/src"
ARG JANUS_CONFIG_OPTIONS="\
        --prefix=/opt/janus \ 
        --disable-rabbitmq \
        --disable-mqtt \
        --enable-post-processing \
        --enable-openssl \
        --disable-unix-sockets \
        --disable-aes-gcm \
    "

RUN apt-get update -y \
    && apt-get upgrade -y

RUN apt-get install -y \
    build-essential \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libopus-dev \
    libogg-dev \
    libconfig-dev \
    libini-config-dev \
    libcollection-dev \
    pkg-config \
    gengetopt \
    libtool \
    autotools-dev \
    libavutil-dev \
    libavcodec-dev \
    libavformat-dev \
    automake \
    curl \
    make \
    git \
    graphviz \
    cmake \
    curl 

RUN curl -fSL https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz -o ${BUILD_SRC}/v2.2.0.tar.gz \
    && tar xzf ${BUILD_SRC}/v2.2.0.tar.gz -C ${BUILD_SRC} \
    && cd ${BUILD_SRC}/libsrtp-2.2.0 \
    && ./configure --prefix=/usr --enable-openssl \
    && make shared_library \
    && make install && make clean

RUN git clone https://github.com/sctplab/usrsctp ${BUILD_SRC}/usrsctp \
    && cd ${BUILD_SRC}/usrsctp \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make && make install && make clean

RUN git clone https://github.com/warmcat/libwebsockets.git ${BUILD_SRC}/libwebsockets \
    && cd ${BUILD_SRC}/libwebsockets \
    && git checkout v3.2-stable \
    && mkdir ${BUILD_SRC}/libwebsockets/build \
    && cd ${BUILD_SRC}/libwebsockets/build \
    && cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
    && make && make install && make clean

RUN apt-get install -y python3 python3-pip python3-setuptools python3-wheel ninja-build \
    && pip3 install meson \
    && git clone https://gitlab.freedesktop.org/libnice/libnice ${BUILD_SRC}/libnice \
	&& cd ${BUILD_SRC}/libnice \
	&& meson --prefix=/usr build && ninja -C build && ninja -C build install

RUN git clone https://github.com/meetecho/janus-gateway.git ${BUILD_SRC}/janus-gateway \
    && cd ${BUILD_SRC}/janus-gateway \
    && ./autogen.sh \
    && ./configure $JANUS_CONFIG_OPTIONS \
    && make && make CFLAGS='-std=c99' && make install && make clean

COPY conf/*.cfg /opt/janus/etc/janus/

RUN apt-get install nginx -y
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/certs /etc/nginx/certs

EXPOSE 80 443 7088 8088 8188 8089
CMD service nginx restart && /opt/janus/bin/janus --nat-1-1=${DOCKER_IP}