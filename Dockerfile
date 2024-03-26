ARG ALPINE_VERSION=edge

### Builder stage ###
FROM docker.io/library/alpine:${ALPINE_VERSION} as builder

RUN apk add --update --no-cache \
    cmake \
    g++ \
    gcc \
    make \
    mold \
    musl-dev \
    openssl-dev

WORKDIR /usr/src

ARG MIMALLOC_VERSION=2.1.2
ADD https://github.com/microsoft/mimalloc.git#v${MIMALLOC_VERSION} mimalloc

WORKDIR /usr/src/mimalloc/build

RUN cmake -DMI_SECURE=ON .. && \
    mold -run make -j $(nproc)
RUN cmake -DMI_SECURE=OFF .. && \
    mold -run make -j $(nproc)

### Runtime stage ###
FROM scratch

COPY --from=builder /usr/src/mimalloc/build/*.so /usr/lib/.
