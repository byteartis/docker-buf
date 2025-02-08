FROM golang:1.23.1-bookworm AS base

# Install build dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip

WORKDIR /tmp

ARG TARGETPLATFORM

# https://github.com/protocolbuffers/protobuf
ARG PROTOBUF_VERSION
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    PLATFORM="linux-x86_64"; \
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    PLATFORM="linux-aarch_64"; \
    else \
    echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1; \
    fi && \
    curl -sSL "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-${PLATFORM}.zip" -o protoc.zip && \
    unzip protoc.zip -d protoc/ && \
    chmod +x ./protoc/bin/protoc

# https://github.com/protocolbuffers/protobuf-javascript
ARG PROTOBUF_JAVASCRIPT_VERSION
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    PLATFORM="linux-x86_64"; \
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    PLATFORM="linux-aarch_64"; \
    else \
    echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1; \
    fi && \
    curl -sSL "https://github.com/protocolbuffers/protobuf-javascript/releases/download/v${PROTOBUF_JAVASCRIPT_VERSION}/protobuf-javascript-${PROTOBUF_JAVASCRIPT_VERSION}-${PLATFORM}.zip" \
    -o protoc-gen-js.zip && \
    unzip protoc-gen-js.zip -d protoc-gen-js/ && \
    chmod +x protoc-gen-js/bin/protoc-gen-js

# https://github.com/grpc/grpc-web
WORKDIR /tmp
ARG GRPC_WEB_VERSION
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    PLATFORM="linux-x86_64"; \
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    PLATFORM="linux-aarch_64"; \
    else \
    echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1; \
    fi && \
    curl -sSL "https://github.com/grpc/grpc-web/releases/download/${GRPC_WEB_VERSION}/protoc-gen-grpc-web-${GRPC_WEB_VERSION}-${PLATFORM}" -o /usr/local/bin/protoc-gen-web-grpc && \
    chmod +x /usr/local/bin/protoc-gen-web-grpc

# https://pkg.go.dev/google.golang.org/protobuf/cmd/protoc-gen-go
ARG PROTOBUF_GO_VERSION
RUN GOBIN=/usr/local/bin go install google.golang.org/protobuf/cmd/protoc-gen-go@v${PROTOBUF_GO_VERSION}

# https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc
ARG GRPC_GO_VERSION
RUN GOBIN=/usr/local/bin go install "google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${GRPC_GO_VERSION}"

# https://github.com/bufbuild/buf
ARG BUF_VERSION
RUN GOBIN=/usr/local/bin go install \
    github.com/bufbuild/buf/cmd/buf@v${BUF_VERSION} \
    github.com/bufbuild/buf/cmd/protoc-gen-buf-breaking@v${BUF_VERSION} \
    github.com/bufbuild/buf/cmd/protoc-gen-buf-lint@v${BUF_VERSION}

# Connect gRPC plugins
ARG CONNECT_GO_VERSION
RUN GOBIN=/usr/local/bin go install \
    connectrpc.com/connect/cmd/protoc-gen-connect-go@v${CONNECT_GO_VERSION}

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

# https://github.com/grpc/grpc
ARG bazel=/tmp/grpc/tools/bazel
ARG GRPC_VERSION
RUN git clone --depth 1 --shallow-submodules -b v${GRPC_VERSION} --recursive https://github.com/grpc/grpc
WORKDIR /tmp/grpc
RUN $bazel build //src/compiler:all

# # https://github.com/grpc/grpc-java
WORKDIR /tmp
ARG GRPC_JAVA_VERSION
RUN git clone --depth 1 --shallow-submodules -b v${GRPC_JAVA_VERSION} --recursive https://github.com/grpc/grpc-java
WORKDIR /tmp/grpc-java
RUN $bazel build //compiler:grpc_java_plugin

WORKDIR /


##########
##########
FROM node:22-bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y git

# https://github.com/grpc/grpc-node/tree/master/packages/grpc-tools
ARG GRPC_NODE_TOOLS_VERSION
ARG PROTOBUF_PROTOPLUGIN_VERSION
ARG PROTOBUF_ES_VERSION
ARG CONNECT_ES_VERSION
RUN npm i -g \
    grpc-tools@${GRPC_NODE_TOOLS_VERSION} \
    @bufbuild/protoplugin@${PROTOBUF_PROTOPLUGIN_VERSION} \
    @bufbuild/protoc-gen-es@${PROTOBUF_ES_VERSION} \
    @connectrpc/protoc-gen-connect-es@${CONNECT_ES_VERSION}
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
