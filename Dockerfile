FROM --platform=linux/amd64 golang:1.23.5-bookworm AS base

# Install build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip

WORKDIR /tmp

# https://github.com/protocolbuffers/protobuf
# renovate: datasource=github-releases depName=protoc packageName=protocolbuffers/protobuf
ARG PROTOBUF_VERSION=29.3
RUN curl -sSL "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip" -o protoc.zip && \
    unzip protoc.zip -d protoc/ && \
    chmod +x ./protoc/bin/protoc

# https://github.com/protocolbuffers/protobuf-javascript
# renovate: datasource=github-releases depName=protobuf-javascript packageName=protocolbuffers/protobuf-javascript
ARG PROTOBUF_JAVASCRIPT_VERSION=3.21.4
RUN curl -sSL "https://github.com/protocolbuffers/protobuf-javascript/releases/download/v${PROTOBUF_JAVASCRIPT_VERSION}/protobuf-javascript-${PROTOBUF_JAVASCRIPT_VERSION}-linux-x86_64.zip" \
    -o protoc-gen-js.zip && \
    unzip protoc-gen-js.zip -d protoc-gen-js/ && \
    chmod +x protoc-gen-js/bin/protoc-gen-js

# https://github.com/grpc/grpc-web
WORKDIR /tmp
# renovate: datasource=github-releases depName=grpc-web packageName=grpc/grpc-web
ARG GRPC_WEB_VERSION=1.5.0
RUN curl -sSL "https://github.com/grpc/grpc-web/releases/download/${GRPC_WEB_VERSION}/protoc-gen-grpc-web-${GRPC_WEB_VERSION}-linux-x86_64" -o /usr/local/bin/protoc-gen-web-grpc && \
    chmod +x /usr/local/bin/protoc-gen-web-grpc

# https://pkg.go.dev/google.golang.org/protobuf/cmd/protoc-gen-go
# renovate: datasource=go depName=protoc-gen-go packageName=google.golang.org/protobuf/cmd/protoc-gen-go
ARG PROTOBUF_GO_VERSION=1.36.3
RUN GOBIN=/usr/local/bin go install google.golang.org/protobuf/cmd/protoc-gen-go@v${PROTOBUF_GO_VERSION}

# https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc
# renovate: datasource=go depName=protoc-gen-go packageName=google.golang.org/grpc/cmd/protoc-gen-go-grpc
ARG GRPC_GO_VERSION=1.5.1
RUN GOBIN=/usr/local/bin go install "google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${GRPC_GO_VERSION}"

# https://github.com/bufbuild/buf
# renovate: datasource=go depName=buf packageName=github.com/bufbuild/buf/cmd/buf
ARG BUF_VERSION=1.50.0
RUN GOBIN=/usr/local/bin go install \
    github.com/bufbuild/buf/cmd/buf@v${BUF_VERSION} \
    github.com/bufbuild/buf/cmd/protoc-gen-buf-breaking@v${BUF_VERSION} \
    github.com/bufbuild/buf/cmd/protoc-gen-buf-lint@v${BUF_VERSION}

# renovate: datasource=github-releases depName=protoc_gen_connect_go packageName=connectrpc/connect-go
ARG PROTOC_GEN_CONNECT_GO_VERSION=1.18.1
RUN GOBIN=/usr/local/bin go install \
    connectrpc.com/connect/cmd/protoc-gen-connect-go@v${PROTOC_GEN_CONNECT_GO_VERSION}

WORKDIR /


##########
##########
FROM debian:bookworm-slim AS protoc

# Install build dependencies
RUN apt-get update && apt-get install -y \
    # dependencies for grpc compile
    build-essential autoconf libtool pkg-config clang libc++-dev \
    # dependencies for grpc-java compile
    openjdk-17-jre \
    git \
    curl

WORKDIR /tmp

ARG bazel=/tmp/grpc/tools/bazel
# https://github.com/grpc/grpc
# renovate: datasource=github-releases depName=grpc/grpc packageName=grpc/grpc
ARG GRPC_VERSION=1.69.0
RUN git clone --depth 1 --shallow-submodules -b v${GRPC_VERSION} --recursive https://github.com/grpc/grpc
WORKDIR /tmp/grpc
RUN $bazel build //src/compiler:all

# https://github.com/grpc/grpc-java
WORKDIR /tmp

# renovate: datasource=github-releases depName=grpc-java packageName=grpc/grpc-java
ARG GRPC_JAVA_VERSION=1.69.1
RUN git clone --depth 1 --shallow-submodules -b v${GRPC_JAVA_VERSION} --recursive https://github.com/grpc/grpc-java
WORKDIR /tmp/grpc-java
RUN $bazel build //compiler:grpc_java_plugin

WORKDIR /


##########
##########
FROM node:22-bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y git

# https://www.npmjs.com/package/grpc-tools
# renovate: datasource=npm depName=grpc-tools packageName=grpc-tools
ARG GRPC_NODE_TOOLS_VERSION=1.12.4
# https://www.npmjs.com/package/@bufbuild/protoplugin
# renovate: datasource=npm depName=buf-protoplugin packageName=@bufbuild/protoplugin
ARG PROTOBUF_PROTOPLUGIN_VERSION=2.2.3
# https://www.npmjs.com/package/@bufbuild/protoc-gen-es
# renovate: datasource=npm depName=protobuf-gen-es packageName=@bufbuild/protoc-gen-es
ARG PROTOBUF_ES_VERSION=2.2.3
RUN npm i -g \
    grpc-tools@${GRPC_NODE_TOOLS_VERSION} \
    @bufbuild/protoplugin@${PROTOBUF_PROTOPLUGIN_VERSION} \
    @bufbuild/protoc-gen-es@${PROTOBUF_ES_VERSION}
RUN cp /usr/local/lib/node_modules/grpc-tools/bin/grpc_node_plugin /usr/local/bin/protoc-gen-node-grpc

# Copy protoc and well known proto files
COPY --from=base /tmp/protoc/bin/ /usr/local/bin/
COPY --from=base /tmp/protoc/include/google/protobuf/ /opt/include/google/protobuf/

# # Copy protoc-grpc default plugins
COPY --from=protoc /tmp/grpc/bazel-bin/src/compiler/grpc_php_plugin /usr/local/bin/protoc-gen-php-grpc
COPY --from=protoc /tmp/grpc/bazel-bin/src/compiler/grpc_python_plugin /usr/local/bin/protoc-gen-python-grpc
COPY --from=protoc /tmp/grpc/bazel-bin/src/compiler/grpc_cpp_plugin /usr/local/bin/protoc-gen-cpp-grpc
COPY --from=protoc /tmp/grpc/bazel-bin/src/compiler/grpc_ruby_plugin /usr/local/bin/protoc-gen-ruby-grpc
COPY --from=protoc /tmp/grpc/bazel-bin/src/compiler/grpc_csharp_plugin /usr/local/bin/protoc-gen-csharp-grpc
COPY --from=protoc /tmp/grpc/bazel-bin/src/compiler/grpc_objective_c_plugin /usr/local/bin/protoc-gen-objc-grpc

# # Copy protoc-grpc java plugin
COPY --from=protoc /tmp/grpc-java/bazel-bin/compiler/grpc_java_plugin /usr/local/bin/protoc-gen-java-grpc

# Copy protoc-grpc js plugin
COPY --from=base /tmp/protoc-gen-js/bin/protoc-gen-js /usr/local/bin/protoc-gen-js

# Copy protoc-grpc web plugin
COPY --from=base /usr/local/bin/protoc-gen-web-grpc /usr/local/bin/protoc-gen-web-grpc

# Copy protoc, protoc-grpc, protoc-gen-connect-go go plugins
COPY --from=base /usr/local/bin/protoc-gen-go /usr/local/bin/protoc-gen-go
COPY --from=base /usr/local/bin/protoc-gen-go-grpc /usr/local/bin/protoc-gen-go-grpc

# Copy buf buf-lint and buf-breaking
COPY --from=base /usr/local/bin/buf /usr/local/bin/buf
COPY --from=base /usr/local/bin/protoc-gen-buf-breaking /usr/local/bin/protoc-gen-buf-breaking
COPY --from=base /usr/local/bin/protoc-gen-buf-lint /usr/local/bin/protoc-gen-buf-lint

# Connect plugins
COPY --from=base /usr/local/bin/protoc-gen-connect-go /usr/local/bin/protoc-gen-connect-go

ENTRYPOINT ["/usr/local/bin/buf"]
