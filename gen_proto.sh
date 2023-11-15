#!/bin/bash

dest="etcd-v3-grpc-cpp"
etcd_v3=(
    proto/etcd/api/authpb/auth.proto
    proto/etcd/api/etcdserverpb/etcdserver.proto
    proto/etcd/api/etcdserverpb/rpc.proto
    proto/etcd/api/mvccpb/kv.proto
    )

google_apis=(
    proto/googleapis/google/api/annotations.proto
    proto/googleapis/google/api/http.proto
)

for p in ${etcd_v3[*]}; do
    cp -f $p $dest/
    file_name=$(basename $p)
    sed -i 's/"etcd\/api\/.*\//"/' $dest/$file_name
    sed -i 's/"google\/api\//"google\//' $dest/$file_name
    sed -i '/option (gogo/d' $dest/$file_name
    sed -i '/import "gogoproto/d' $dest/$file_name
    sed -i 's/\[(gogoproto.*\]//' $dest/$file_name
done

if [ ! -d "$dest/google" ];then
    mkdir -p $dest/google
fi

for g in ${google_apis[*]};do
    cp -f $g $dest/google/
    file_name=$(basename $g)
    sed -i 's/"google\/api\//"google\//' $dest/google/$file_name
done

for f in $(ls etcd-v3-grpc-cpp|grep proto); do
    protoc -I=etcd-v3-grpc-cpp \
        --cpp_out=$dest \
        --grpc_out=$dest \
        --plugin=protoc-gen-grpc=$(which grpc_cpp_plugin) \
        $f
done

protoc -I=etcd-v3-grpc-cpp --cpp_out=$dest etcd-v3-grpc-cpp/google/annotations.proto
protoc -I=etcd-v3-grpc-cpp --cpp_out=$dest etcd-v3-grpc-cpp/google/http.proto