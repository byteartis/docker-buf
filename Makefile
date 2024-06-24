include ./versions.env
export

.DEFAULT_GOAL := build-local

build-local:
	@DOCKER_BUILDKIT=1 \
    docker build \
		--network host \
		--build-arg BUF_VERSION=$(BUF_VERSION) \
		--build-arg PROTOBUF_VERSION=$(PROTOBUF_VERSION) \
		--build-arg PROTOBUF_GO_VERSION=$(PROTOBUF_GO_VERSION) \
		--build-arg PROTOBUF_JAVASCRIPT_VERSION=$(PROTOBUF_JAVASCRIPT_VERSION) \
		--build-arg PROTOBUF_PROTOPLUGIN_VERSION=$(PROTOBUF_PROTOPLUGIN_VERSION) \
		--build-arg PROTOBUF_ES_VERSION=$(PROTOBUF_ES_VERSION) \
		--build-arg GRPC_VERSION=$(GRPC_VERSION) \
		--build-arg GRPC_GO_VERSION=$(GRPC_GO_VERSION) \
		--build-arg GRPC_NODE_TOOLS_VERSION=$(GRPC_NODE_TOOLS_VERSION) \
		--build-arg GRPC_WEB_VERSION=$(GRPC_WEB_VERSION) \
		--build-arg GRPC_JAVA_VERSION=$(GRPC_JAVA_VERSION) \
    --build-arg CONNECT_GO_VERSION=$(CONNECT_GO_VERSION) \
    --build-arg CONNECT_ES_VERSION=$(CONNECT_ES_VERSION) \
		-t byteartis/buf:local \
		.
