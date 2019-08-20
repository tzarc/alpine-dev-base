FROM alpine:edge
LABEL Maintainer="Nick Brassel <nick@tzarc.org>" \
      Description="Base image with updated GCC and Boost."

ENV BOOST_VERSION 1.71.0

RUN apk update \
    && apk --no-cache add sudo

RUN addgroup devel \
    && adduser -h /home/devel -s /bin/bash -G devel -D devel \
    && echo 'devel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/devel
USER devel:devel

RUN export BOOST_UNDERSCORES=$(echo $BOOST_VERSION | tr '.' '_') \
    && sudo apk update \
    && sudo apk --no-cache add linux-headers libc-dev gcc make g++ bash git cmake curl openssl-dev bzip2-dev zlib-dev zstd-dev xz-dev icu-dev python3-dev ninja \
    && mkdir /home/devel/boost-${BOOST_UNDERSCORES} \
    && curl -L https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_${BOOST_UNDERSCORES}.tar.gz > /home/devel/boost_${BOOST_UNDERSCORES}.tar.gz \
    && tar xf /home/devel/boost_${BOOST_UNDERSCORES}.tar.gz -C /home/devel/boost-${BOOST_UNDERSCORES} --strip-components=1 \
    && cd /home/devel/boost-${BOOST_UNDERSCORES} \
    && ./bootstrap.sh --prefix=/usr \
    && ./b2 -j$(nproc) variant=release link=static threading=multi runtime-link=static \
    && sudo ./b2 -j$(nproc) install variant=release link=static threading=multi runtime-link=static \
    && rm -rf /home/devel/*

CMD ["/bin/bash"]
