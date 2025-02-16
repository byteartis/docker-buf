#!/bin/bash

# Load versions from versions.env
source versions.env

# Read the template
template=$(cat templates/README.template.md)

# Replace placeholders with actual versions
template=${template//\{\{BUF_VERSION\}\}/$BUF_VERSION}
template=${template//\{\{PROTOC_VERSION\}\}/$PROTOBUF_VERSION}
template=${template//\{\{PROTOC_GEN_GO_VERSION\}\}/$PROTOBUF_GO_VERSION}
template=${template//\{\{PROTOC_GEN_JS_VERSION\}\}/$PROTOBUF_JAVASCRIPT_VERSION}
template=${template//\{\{PROTOPLUGIN_VERSION\}\}/$PROTOBUF_PROTOPLUGIN_VERSION}
template=${template//\{\{PROTOC_GEN_ES_VERSION\}\}/$PROTOBUF_ES_VERSION}
template=${template//\{\{GRPC_VERSION\}\}/$GRPC_VERSION}
template=${template//\{\{PROTOC_GEN_GO_GRPC_VERSION\}\}/$GRPC_GO_VERSION}
template=${template//\{\{GRPC_JAVA_VERSION\}\}/$GRPC_JAVA_VERSION}
template=${template//\{\{GRPC_TOOLS_VERSION\}\}/$GRPC_NODE_TOOLS_VERSION}
template=${template//\{\{GRPC_WEB_VERSION\}\}/$GRPC_WEB_VERSION}
template=${template//\{\{PROTOC_GEN_CONNECT_GO_VERSION\}\}/$CONNECT_GO_VERSION}
template=${template//\{\{PROTOC_GEN_CONNECT_ES_VERSION\}\}/$CONNECT_ES_VERSION}

# Write the result to README.md
echo "$template" > README.md
