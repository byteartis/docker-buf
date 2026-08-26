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
| [buf](https://github.com/bufbuild/buf) | 1.72.0 |
| [protoc](https://github.com/protocolbuffers/protobuf) | 36.0 |
| [protoc-gen-go](https://pkg.go.dev/google.golang.org/protobuf/cmd/protoc-gen-go) | 1.36.12 |
| [protoc-gen-js](https://github.com/protocolbuffers/protobuf-javascript) | 4.0.2 |
| [protoplugin](https://www.npmjs.com/package/@bufbuild/protoplugin) | 2.14.0 |
| [protoc-gen-es](https://www.npmjs.com/package/@bufbuild/protoc-gen-es) | 2.14.0 |
| [grpc](https://github.com/grpc/grpc) | 1.83.0 |
| [protoc-gen-go-grpc](https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc) | 1.6.2 |
| [grpc-java](https://github.com/grpc/grpc-java) | 1.83.1 |
| [grpc-tools](https://www.npmjs.com/package/grpc-tools) | 1.13.1 |
| [grpc-web](https://github.com/grpc/grpc-web) | 2.1.0 |
| [protoc-gen-connect-go](https://github.com/connectrpc/connect-go) | 1.20.0 |

## Example

Check the sample repository [here](https://github.com/byteartis/docker-buf-sample).

## Versioning

Since this image contains multiple tools there is no straightforward way to version it. For that reason versioning will be done based on the following rules:

- Major bump when any of the tools is updated to a new major version
- Minor bump when any of the tools is updated to a new minor version
- Patch bump when any of the tools is updated to a new patch version
