cmake_minimum_required(VERSION 3.21)

set(ETCDV3_CPP_API_VERSION_MAJOR 3)
set(ETCDV3_CPP_API_VERSION_MINOR 5)
set(ETCDV3_CPP_API_VERSION_PATCH 10)
project(etcdv3-api-cpp 
    LANGUAGES CXX C 
    VERSION ${ETCDV3_CPP_API_VERSION_MAJOR}.${ETCDV3_CPP_API_VERSION_MINOR}.${ETCDV3_CPP_API_VERSION_PATCH})

set(CMAKE_CXX_STANDARD_EXTENSION OFF)

# here we use the CONFIG mode for finding gRPC and protobuf
# if you don't have gRPC and protobuf installed in common well known path
# you need to set the -DCMAKE_PREFIX_PATH=/path/to/your/install/prefix
# then cmake shall find the config file generated when you build grpc from source
find_package(protobuf CONFIG REQUIRED)
find_package(gRPC CONFIG REQUIRED)
message(STATUS "Using gRPC version ${gRPC_VERSION}")

file(GLOB_RECURSE
    ETCD_PROTO "etcd/*.proto" "google/*.proto")
add_library(${PROJECT_NAME}
    STATIC
        ${ETCD_PROTO})
protobuf_generate(
    TARGET ${PROJECT_NAME}
    IMPORT_DIRS ${CMAKE_CURRENT_SOURCE_DIR})

protobuf_generate(
    TARGET ${PROJECT_NAME}
    IMPORT_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
    LANGUAGE grpc
    GENERATE_EXTENSIONS .grpc.pb.h .grpc.pb.cc
    PLUGIN "protoc-gen-grpc=\$<TARGET_FILE:gRPC::grpc_cpp_plugin>")

# you may add more dependencies' header dir here
target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
        $<INSTALL_INTERFACE:etcdv3-api-cpp>)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
        protobuf::libprotobuf
        gRPC::grpc++)
target_compile_options(${PROJECT_NAME}
    PUBLIC
        "-Wfatal-errors")
# this cxx_std_14 can be replace with cxx_std_11 ONLY if your gRPC version supports cxx11
target_compile_features(${PROJECT_NAME}
    PUBLIC
        cxx_std_14)

# install settings
include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    EXPORT ETCDV3_CPP_API_EXPORT
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

install(EXPORT ETCDV3_CPP_API_EXPORT
    FILE etcdv3-api-cpp-config.cmake
    NAMESPACE etcdv3-api-cpp::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/etcdv3-api-cpp)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "etcdv3-api-cpp-config-version.cmake"
    COMPATIBILITY SameMajorVersion)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/etcdv3-api-cpp-config-version.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/etcdv3-api-cpp)

# install public headers
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/etcd
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/etcdv3-api-cpp
    FILES_MATCHING
        PATTERN "*.h"
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/google
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/etcdv3-api-cpp
    FILES_MATCHING
        PATTERN "*.h")

# auto versioning reads from header.h to get versionstring
message(STATUS "current etcdv3-api-cpp version: ${ETCDV3_CPP_API_VERSION_MAJOR}.${ETCDV3_CPP_API_VERSION_MINOR}.${ETCDV3_CPP_API_VERSION_PATCH}")
set(CPACK_PACKAGE_VERSION_MAJOR ${ETCDV3_CPP_API_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${ETCDV3_CPP_API_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${ETCDV3_CPP_API_VERSION_PATCH})
# cpack settings, edit the following to pack up as you desire
if(UNIX)
    set(CPACK_GENERATOR "TGZ")
else()
    set(CPACK_GENERATOR "ZIP")
endif()
set(CPACK_PACKAGE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/packages)
include(CPack)
