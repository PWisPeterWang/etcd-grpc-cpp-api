# etcd-v3-api-cpp
A easy protobuf-cmake-cpp project for generating etcd v3 api for C++ based on gRPC.
Normally it requires a C++ compiler which supports C++14 (due to gRPC dependencies).
It might work with lower version of C++ compiler (e.g. gcc 4.8.5) with older gRPC version.
Currently it's designed to work on Linux platform.

The project takes the proto files dependencies from [etcd](https://github.com/etcd-io/etcd.git) (version 3.5.10) and [googleapis](https://github.com/googleapis/googleapis.git). With the help of `protobuf_generate` from CMake, we can easily build a static library containing the necessary grpc interface to access etcd v3 server using C++.


## Build
```bash
cmake -H. -Bbuild -G Ninja
# put -DCMAKE_PREFIX_PATH=/path/to/your/grpc/installation
# if your grpc is not installed into well known paths

ninja -C build install
```
## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

According to the TERMS of Apache 2.0 license, here are the changes to the proto files obtained from:

## googleapis

1. googleapis/google/api/annotations.proto
   files taken to `google/api`.

## etcd

1. etcd/api/authpb/auth.proto
2. etcd/api/etcdserverpb/etcdserver.proto
3. etcd/api/etcdserverpb/rpc.proto
4. etcd/api/mvccpb/kv.proto
   files taken to `etcd/api`, the import paths are replaced accordingly, gogoproto dependencies removed.
