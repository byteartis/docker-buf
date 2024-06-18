# Docker Buf

Docker image with Buf and support for protobuf and grpc code generation in multiple languages

## Versions

| Tool | Version |
| - | - |
| [buf](https://github.com/bufbuild/buf) | v1.33.0 |
| [protoc](https://github.com/protocolbuffers/protobuf) | v27.1 |
| [grpc](https://github.com/grpc/grpc) | v1.64.2 |
| [grpc-java](https://github.com/grpc/grpc-java) | v1.64.0 |
| [protoc-gen-js](https://github.com/protocolbuffers/protobuf-javascript) | v3.21.2 |
| [protoc-gen-go](https://pkg.go.dev/google.golang.org/protobuf/cmd/protoc-gen-go) | v1.34.2 |
| [protoc-gen-go-grpc](https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc) | v1.4.0 |
| [grpc-tools](https://www.npmjs.com/package/grpc-tools) | v1.12.4 |
| [grpc-web](https://github.com/grpc/grpc-web) | v1.5.0 |

## Language Support

Full support for protobuf and grpc generation for the following languages:

| Language | Plugins |
| - | - |
| C++ | **cpp**, **cpp-grpc** |
| Ruby | **ruby**, **ruby-grpc** |
| Python | **python**, **python-grpc** |
| PHP | **php**, **php-grpc** |
| C# | **csharp**, **csharp-grpc** |
| Objective-C | **objc**, **objc-grpc** |
| Java | **java**, **java-grpc** |
| Go | **go**, **go-grpc** |
| JavaScript | **js**, **node-grpc**, **web-grpc** |

## Example buf.gen.yaml

```yaml
version: v1
managed:
  enabled: true
  go_package_prefix:
    default: acme/foo/bar/gen/go
plugins:
  - name: cpp
    out: gen/cpp
  - name: cpp-grpc
    out: gen/cpp

  - name: ruby
    out: gen/ruby
  - name: ruby-grpc
    out: gen/ruby

  - name: python
    out: gen/python
  - name: python-grpc
    out: gen/python

  - name: php
    out: gen/php
  - name: php-grpc
    out: gen/php

  - name: csharp
    out: gen/csharp
  - name: csharp-grpc
    out: gen/csharp

  - name: objc
    out: gen/objc
  - name: objc-grpc
    out: gen/objc

  - name: java
    out: gen/java
  - name: java-grpc
    out: gen/java

  - name: go
    out: gen/go
    opt: paths=source_relative
  - name: go-grpc
    out: gen/go
    opt:
      - paths=source_relative

  - name: js
    out: gen/js
    opt: import_style=commonjs_strict,binary
  - name: node-grpc
    out: gen/js
    opt: grpc_js
  - name: web-grpc
    out: gen/js
    opt: import_style=commonjs,mode=grpcwebtext
```
