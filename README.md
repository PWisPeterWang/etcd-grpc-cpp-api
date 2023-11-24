# etcd-v3-api-cpp
A project for generating etcd v3 api for C++ based on gRPC.
Normally it requires a C++ compiler which supports C++14 (due to gRPC dependencies).
It might work with lower version of C++ compiler (e.g. gcc 4.8.5) with older gRPC version.
Currently it's designed to work on Linux platform.

Basically, the project is pulling the proto file dependencies from [etcd](https://github.com/etcd-io/etcd.git), [gogoproto](https://github.com/cosmos/gogoproto.git) (actually it is not required for C++) and [googleapis](https://github.com/googleapis/googleapis.git). Then in the bash script `gen_proto.h`, it will take the necessary proto files from thoese repos and use sed to rip the Golang part from them (the gogoproto); call protoc to compile the grpc and pb sources for C++. Finally you can call `ninja` to build a static library containing the necessary grpc interface to access etcd v3 server using C++.

You can use the raw grpc interfaces to communicate with a etcd cluster as you desire. Better than legacy HTTP Restful API.

Currently it's bulding with etcd version 3.5.10. You can switch to other version of etcd in the submodule repo. 

## Build
```bash
cmake -H. -Bbuild -G Ninja
ninja -C build
```
## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

According to the TERMS of Apache 2.0 license, here are the changes to the proto files obtained from:

## googleapis

1. googleapis/google/api/annotations.proto
   replaced the proto file's `import "google/api/http.proto";` to `import "google/api/http.proto";`

## etcd

1. etcd/api/authpb/auth.proto
2. etcd/api/etcdserverpb/etcdserver.proto
3. etcd/api/etcdserverpb/rpc.proto
4. etcd/api/mvccpb/kv.proto
   replace the import path