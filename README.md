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
| JavaScript | protoc-gen-js, protoc-gen-es | protoc-gen-node-grpc | protoc-gen-connect-es |
| TypeScript | protoc-gen-es | NA | protoc-gen-connect-es |
| Python | protoc | protoc-gen-python-grpc | NA |
| Ruby | protoc | protoc-gen-ruby-grpc | NA |
| PHP | protoc | protoc-gen-php-grpc | NA |
| Web | protoc-gen-es | protoc-gen-grpc-web | protoc-gen-connect-es |

### Versions

| Tool | Version |
| - | - |
| [buf](https://github.com/bufbuild/buf) | v1.34.0 |
| [protoc](https://github.com/protocolbuffers/protobuf) | v27.1 |
| [protoc-gen-go](https://pkg.go.dev/google.golang.org/protobuf/cmd/protoc-gen-go) | v1.34.2 |
| [protoc-gen-js](https://github.com/protocolbuffers/protobuf-javascript) | v3.21.2 |
| [protoc-gen-es](https://github.com/bufbuild/protobuf-es) | v1.10.0 |
| [grpc](https://github.com/grpc/grpc) | v1.64.2 |
| [protoc-gen-go-grpc](https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc) | v1.4.0 |
| [grpc-java](https://github.com/grpc/grpc-java) | v1.64.0 |
| [grpc-tools](https://www.npmjs.com/package/grpc-tools) | v1.12.4 |
| [grpc-web](https://github.com/grpc/grpc-web) | v1.5.0 |
| [protoc-gen-connect-go](https://github.com/connectrpc/connect-go) | v1.16.2 |
| [protoc-gen-connect-go](https://github.com/connectrpc/connect-es) | v1.4.0 |

## Example

Check the sample repository [here](https://github.com/byteartis/docker-buf-sample).

## Versioning

Since this image contains multiple tools there is no straightforward way to version it. For that reason versioning will be done based on the following rules:

- Major bump when any of the tools is updated to a new major version
- Minor bump when any of the tools is updated to a new minor version
- Patch bump when any of the tools is updated to a new patch version
