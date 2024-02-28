# MiMalloc Container

A supplemental container image with pre-built [MiMalloc][mimalloc] shared libraries.

[mimalloc]: https://github.com/microsoft/mimalloc

## Motivation

Alpine Linux is great for container images because of how compact it is. But it’s also
known for its slow memory allocator ([malloc-ng][malloc-ng]).

So, if you need a containerized application that relies on a system allocator and shared
libraries, and there is no way to compile it statically, an Alpine-based image is not a
viable option probably.

Yet, there is a way—to [override][dynamic-overrride] a memory allocator. And `mimalloc`
is usually a safe all-rounder. However, an intermediate building stage image is not
always convenient if you can have a pre-compiled one in reach.

And here it is. Mostly, it’s for my personal needs. But if you find it useful as well,
give it a try.

[malloc-ng]: https://github.com/richfelker/mallocng-draft
[dynamic-overrride]: https://github.com/microsoft/mimalloc#dynamic-override

## Usage

The container image is available as [`docker.io/aeron/mimalloc`][docker] and
[`ghcr.io/Aeron/mimalloc`][github]. You can use both interchangeably.

```sh
docker pull docker.io/aeron/mimalloc
# …or…
docker pull ghcr.io/aeron/mimalloc
```

The image contains both library flavors: faster `libmimalloc.so` and hardened
`libmimalloc-secure.so`; Both are in the `/usr/lib` directory.

[docker]: https://hub.docker.com/r/aeron/mimalloc
[github]: https://github.com/Aeron/mimalloc-container/pkgs/container/mimalloc

### Multi-stage Image

The simplest and precise way is to use `--from` option of the `COPY` directive, like so:

```Dockerfile
FROM docker.io/library/alpine:latest

COPY --from=docker.io/aeron/mimalloc:latest /usr/lib/libmimalloc.so /lib/.
# …or…
COPY --from=docker.io/aeron/mimalloc:latest /usr/lib/libmimalloc-secure.so /lib/.

ENV LD_PRELOAD=/lib/libmimalloc.so
# …or…
ENV LD_PRELOAD=/lib/libmimalloc-secure.so

ENV MIMALLOC_ALLOW_LARGE_OS_PAGES=1
```

It will copy the shared library flavor you prefer in a suitable destination. And you
need to explicitly set the `LD_PRELOAD` and other variables (like
`MIMALLOC_ALLOW_LARGE_OS_PAGES`) if you need them.

## Acknowledgment

The [MiMalloc][mimalloc] is an open-source project made by
[Microsoft Corporation][microsoft], [Daan Leijen][daanx], and its contributors,
available under [MIT license][mit-license].

[microsoft]: https://github.com/microsoft
[daanx]: https://github.com/daanx
[mit-license]: https://opensource.org/license/MIT
