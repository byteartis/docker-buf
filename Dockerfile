FROM --platform=linux/amd64 golang:1.17-buster AS build

# Install build dependencies
RUN apt-get update && apt-get install -y \
    # dependencies for grpc compile
    build-essential autoconf libtool pkg-config clang libc++-dev \
    # dependencies for grpc-java compile
    openjdk-11-jre \
    curl \
    unzip \
    zsh

WORKDIR /tmp

# https://github.com/protocolbuffers/protobuf
ARG PROTOC_VERSION=3.19.3
RUN curl -sSL "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip" -o protoc.zip && \
    unzip protoc.zip -d protoc/ && \
    chmod +x ./protoc/bin/protoc

# https://github.com/grpc/grpc
ARG bazel=/tmp/grpc/tools/bazel
ARG GRPC_VERSION=1.43.0
RUN git clone --depth 1 --shallow-submodules -b v${GRPC_VERSION} --recursive https://github.com/grpc/grpc
WORKDIR /tmp/grpc
RUN $bazel build //src/compiler:all

# https://github.com/grpc/grpc-java
WORKDIR /tmp
ARG GRPC_JAVA_VERSION=1.43.2
RUN git clone --depth 1 --shallow-submodules -b v${GRPC_JAVA_VERSION} --recursive https://github.com/grpc/grpc-java
WORKDIR /tmp/grpc-java
RUN $bazel build //compiler:grpc_java_plugin

# https://github.com/grpc/grpc-web
WORKDIR /tmp
ARG PROTOC_WEB_GRPC_VERSION=1.3.0
RUN curl -sSL "https://github.com/grpc/grpc-web/releases/download/${PROTOC_WEB_GRPC_VERSION}/protoc-gen-grpc-web-${PROTOC_WEB_GRPC_VERSION}-linux-x86_64" -o /usr/local/bin/protoc-gen-web-grpc && \
    chmod +x /usr/local/bin/protoc-gen-web-grpc

# https://pkg.go.dev/google.golang.org/protobuf/cmd/protoc-gen-go
ARG PROTOC_GO_VERSION=1.27.1
RUN GOBIN=/usr/local/bin go install google.golang.org/protobuf/cmd/protoc-gen-go@v${PROTOC_GO_VERSION}

# https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc
ARG PROTOC_GO_GRPC_VERSION=1.2.0
RUN GOBIN=/usr/local/bin go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${PROTOC_GO_GRPC_VERSION}

# https://github.com/bufbuild/buf
ARG BUF_VERSION=1.0.0-rc10
RUN GOBIN=/usr/local/bin go install \
    github.com/bufbuild/buf/cmd/buf@v${BUF_VERSION} \
    github.com/bufbuild/buf/cmd/protoc-gen-buf-breaking@v${BUF_VERSION} \
    github.com/bufbuild/buf/cmd/protoc-gen-buf-lint@v${BUF_VERSION}

WORKDIR /


##########
##########
FROM node:16.13.1-buster-slim AS build-node

# https://github.com/grpc/grpc-node/tree/master/packages/grpc-tools
ARG GRPC_NODE_TOOLS_VERSION=1.11.2
RUN npm i -g grpc-tools@${GRPC_NODE_TOOLS_VERSION}
RUN cp /usr/local/lib/node_modules/grpc-tools/bin/grpc_node_plugin /usr/local/bin/protoc-gen-node-grpc


##########
##########
FROM debian:buster-slim

# Install dependencies
RUN apt-get update && apt-get install -y git

# Copy protoc and well known proto files
COPY --from=build /tmp/protoc/bin/ /usr/local/bin/
COPY --from=build /tmp/protoc/include/google/protobuf/ /opt/include/google/protobuf/

# Copy protoc-grpc default plugins
COPY --from=build /tmp/grpc/bazel-bin/src/compiler/grpc_php_plugin /usr/local/bin/protoc-gen-php-grpc
COPY --from=build /tmp/grpc/bazel-bin/src/compiler/grpc_python_plugin /usr/local/bin/protoc-gen-python-grpc
COPY --from=build /tmp/grpc/bazel-bin/src/compiler/grpc_cpp_plugin /usr/local/bin/protoc-gen-cpp-grpc
COPY --from=build /tmp/grpc/bazel-bin/src/compiler/grpc_ruby_plugin /usr/local/bin/protoc-gen-ruby-grpc
COPY --from=build /tmp/grpc/bazel-bin/src/compiler/grpc_csharp_plugin /usr/local/bin/protoc-gen-csharp-grpc
COPY --from=build /tmp/grpc/bazel-bin/src/compiler/grpc_objective_c_plugin /usr/local/bin/protoc-gen-objc-grpc

# Copy protoc-grpc java plugin
COPY --from=build /tmp/grpc-java/bazel-bin/compiler/grpc_java_plugin /usr/local/bin/protoc-gen-java-grpc

# Copy protoc-grpc web plugin
COPY --from=build /usr/local/bin/protoc-gen-web-grpc /usr/local/bin/protoc-gen-web-grpc

# Copy protoc-grpc node plugin
COPY --from=build-node /usr/local/bin/protoc-gen-node-grpc /usr/local/bin/protoc-gen-node-grpc

# Copy protoc and protoc-grpc go plugins
COPY --from=build /usr/local/bin/protoc-gen-go /usr/local/bin/protoc-gen-go
COPY --from=build /usr/local/bin/protoc-gen-go-grpc /usr/local/bin/protoc-gen-go-grpc

# Copy buf buf-lint and buf-breaking
COPY --from=build /usr/local/bin/buf /usr/local/bin/buf
COPY --from=build /usr/local/bin/protoc-gen-buf-breaking /usr/local/bin/protoc-gen-buf-breaking
COPY --from=build /usr/local/bin/protoc-gen-buf-lint /usr/local/bin/protoc-gen-buf-lint

ENTRYPOINT ["/usr/local/bin/buf"]
