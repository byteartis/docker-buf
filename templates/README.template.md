# Docker Buf

Docker image with support for [Protobuf](https://protobuf.dev/), [gRPC](https://grpc.io/), and [Connect](https://connectrpc.com/) code generation for multiple languages.

The image includes [Buf](https://buf.build/) to facilitate code generation, linting, and breaking changes detection.

## Plugins

### Language Support Table

| Language | Protobuf | gRPC | Connect |
| - | - | - | - |
| Go | protoc-gen-go | protoc-gen-go-grpc | protoc-gen-connect-go |
| Java | protoc | protoc-gen-java-grpc | NA |
| C++ | protoc | protoc-gen-cpp-grpc | NA |
| C# | protoc | protoc-gen-chsarp-grpc | NA |
| Objective-C | protoc | protoc-gen-objc-grpc | NA |
| JavaScript | protoc-gen-js, protoc-gen-es | protoc-gen-node-grpc | [Runtime] @connectrpc/connect |
| TypeScript | protoc-gen-es | NA | [Runtime] @connectrpc/connect |
| Python | protoc | protoc-gen-python-grpc | NA |
| Ruby | protoc | protoc-gen-ruby-grpc | NA |
| PHP | protoc | protoc-gen-php-grpc | NA |
| Web | protoc-gen-es | protoc-gen-grpc-web | [Runtime] @connectrpc/connect |

### Versions

| Tool | Version |
| - | - |
| [buf](https://github.com/bufbuild/buf) | {{BUF_VERSION}} |
| [protoc](https://github.com/protocolbuffers/protobuf) | {{PROTOC_VERSION}} |
| [protoc-gen-go](https://pkg.go.dev/google.golang.org/protobuf/cmd/protoc-gen-go) | {{PROTOC_GEN_GO_VERSION}} |
| [protoc-gen-js](https://github.com/protocolbuffers/protobuf-javascript) | {{PROTOC_GEN_JS_VERSION}} |
| [protoplugin](https://www.npmjs.com/package/@bufbuild/protoplugin) | {{PROTOPLUGIN_VERSION}} |
| [protoc-gen-es](https://www.npmjs.com/package/@bufbuild/protoc-gen-es) | {{PROTOC_GEN_ES_VERSION}} |
| [grpc](https://github.com/grpc/grpc) | {{GRPC_VERSION}} |
| [protoc-gen-go-grpc](https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc) | {{PROTOC_GEN_GO_GRPC_VERSION}} |
| [grpc-java](https://github.com/grpc/grpc-java) | {{GRPC_JAVA_VERSION}} |
| [grpc-tools](https://www.npmjs.com/package/grpc-tools) | {{GRPC_TOOLS_VERSION}} |
| [grpc-web](https://github.com/grpc/grpc-web) | {{GRPC_WEB_VERSION}} |
| [protoc-gen-connect-go](https://github.com/connectrpc/connect-go) | {{PROTOC_GEN_CONNECT_GO_VERSION}} |

## Example

Check the sample repository [here](https://github.com/byteartis/docker-buf-sample).

## Versioning

Since this image contains multiple tools there is no straightforward way to version it. For that reason versioning will be done based on the following rules:

- Major bump when any of the tools is updated to a new major version
- Minor bump when any of the tools is updated to a new minor version
- Patch bump when any of the tools is updated to a new patch version
