FROM ubuntu:xenial
MAINTAINER Baurzhan Taishinov <baurzhan@gmail.com>

WORKDIR /src
ADD config.xml /etc/webrtc2sip/config.xml
RUN apt-get update && apt-get install -y git libssl-dev build-essential \
    libtool autoconf libogg-dev pkg-config libspeex-dev libspeexdsp-dev wget libsrtp-dev libxml2-dev
RUN cd /usr/share/dict \
    && wget http://sourceforge.net/projects/souptonuts/files/souptonuts/dictionary/linuxwords.1.tar.gz \
    && tar zxvf linuxwords.1.tar.gz && rm linuxwords.1.tar.gz \
    && mv linuxwords.1/linux.words ./words && rm -r linuxwords.1
RUN wget http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz \
    && tar -xvzf opus-1.0.2.tar.gz && cd opus-1.0.2 && ./configure --with-pic --enable-float-approx && make && make install
RUN git clone https://github.com/DoubangoTelecom/doubango.git
RUN cd doubango && ./autogen.sh \
    && ./configure --with-ssl --with-srtp --with-speexdsp --prefix=/usr/local \
    && make && make install
RUN git clone https://github.com/DoubangoTelecom/webrtc2sip.git
RUN cd webrtc2sip && ./autogen.sh \
    && ./configure CFLAGS='-lpthread' LDFLAGS='-ldl' LIBS='-ldl' \
    && make && make install
RUN rm opus-1.0.2.tar.gz && rm -r opus-1.0.2 && rm -r doubango && rm -r webrtc2sip
CMD webrtc2sip --config=/etc/webrtc2sip/config.xml
