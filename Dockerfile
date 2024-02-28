ARG ALPINE_VERSION=3.19

### Builder stage ###
FROM docker.io/library/alpine:${ALPINE_VERSION} as builder

RUN apk add --update --no-cache \
    build-base \
    cmake \
    mold

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