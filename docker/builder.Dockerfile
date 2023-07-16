# syntax=docker/dockerfile:experimental
FROM ubuntu:20.04

ARG http_proxy
ARG https_proxy

# --- package install
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -qy \
      libgrpc++-dev \
      g++ \
      protobuf-compiler-grpc \
      make \
      pkg-config \
      python3 \
      python3-pip \
      curl \
      python3-distutils \
      libclang1-6.0 \
      doxygen \
      git

# --- python & grpc install
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 10
RUN pip install grpcio-tools prompt_toolkit clang jinja2 tabulate grpclib

# --- make meta & lib,inc install 
RUN --mount=type=bind,target=/root,rw cd /root \
  && make -C meta \
  && cp meta/libmetatai.so /usr/lib/aarch64-linux-gnu/ \
  && cp meta/tai*.h /usr/local/include/

# --- example basic & libtai install 
RUN --mount=type=bind,target=/root,rw cd /root \
  && make -C tools/framework/examples/basic \
  && cp tools/framework/examples/basic/libtai.so /usr/lib/aarch64-linux-gnu/libtai-basic.so
RUN cd /usr/lib/aarch64-linux-gnu && ln -s libtai-basic.so libtai.so

# --- make taish_server install
RUN --mount=type=bind,target=/root,rw cd /root \
  && make -C tools/taish \
  && cp tools/taish/taish_server /usr/local/bin/

#--- make taish install
RUN --mount=type=bind,target=/root,rw cd /root \
&& make -C tools/taish python \
&& cp tools/taish/dist/*.tar.gz /tmp/
