include ./versions.env
export

build-local:
	@docker build \
		--network host \
		--build-arg BUF_VERSION=$(BUF_VERSION) \
		--build-arg PROTOC_VERSION=$(PROTOC_VERSION) \
		--build-arg GRPC_VERSION=$(GRPC_VERSION) \
		--build-arg GRPC_JAVA_VERSION=$(GRPC_JAVA_VERSION) \
		--build-arg PROTOC_JS_VERSION=$(PROTOC_JS_VERSION) \
		--build-arg PROTOC_GO_VERSION=$(PROTOC_GO_VERSION) \
		--build-arg PROTOC_GO_GRPC_VERSION=$(PROTOC_GO_GRPC_VERSION) \
		--build-arg GRPC_NODE_TOOLS_VERSION=$(GRPC_NODE_TOOLS_VERSION) \
		--build-arg PROTOC_WEB_GRPC_VERSION=$(PROTOC_WEB_GRPC_VERSION) \
		-t docker-buf:local \
		.
