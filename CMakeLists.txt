cmake_minimum_required(VERSION 3.21)

set(ETCD-V3-API-CPP_VERSION_MAJOR 3)
set(ETCD-V3-API-CPP_VERSION_MINOR 5)
set(ETCD-V3-API-CPP_VERSION_PATCH 10)
project(etcd-v3-grpc-cpp 
    LANGUAGES CXX C 
    VERSION ${ETCD-V3-API-CPP_VERSION_MAJOR}.${ETCD-V3-API-CPP_VERSION_MINOR}.${ETCD-V3-API-CPP_VERSION_PATCH})

# edit the following settings as you desire
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_EXTENSION OFF)
add_compile_options(-Wfatal-errors)

# edit the following line to add your cmake modules
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake_modules)
# edit the following line to add your dependencies
find_package(gRPC REQUIRED)
message(STATUS "Using gRPC version ${gRPC_VERSION}")
find_package(Protobuf REQUIRED)
message(STATUS "Using protobuf version ${Protobuf_VERSION}")
find_package(Threads REQUIRED)

message(STATUS "Updating and init submodules")
execute_process(
    COMMAND git submodule update --init)
message(STATUS "Submodules done")

message(STATUS "Generating protobuf sources")
execute_process(
    COMMAND bash ${CMAKE_SOURCE_DIR}/gen_proto.sh)
message(STATUS "Protobuf sources done")

file(GLOB_RECURSE API_SRCS "etcd-v3-grpc-cpp/*.cc")
add_library(${PROJECT_NAME} STATIC ${API_SRCS})

# you may add more dependencies' header dir here
target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/etcd-v3-grpc-cpp>
        $<INSTALL_INTERFACE:etcd-v3-grpc-cpp>
    PRIVATE
        ${PROJECT_SOURCE_DIR}/src)

target_link_libraries(${PROJECT_NAME}
    PUBLIC
        protobuf::libprotobuf
        gRPC::grpc
        gRPC::grpc++)


# install settings
include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
# install public headers
set(PUBLIC_HEADER_DIR ${PROJECT_SOURCE_DIR}/etcd-v3-grpc-cpp)
install(DIRECTORY ${PUBLIC_HEADER_DIR}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.hpp"
)
# auto versioning reads from header.h to get versionstring
message(STATUS "current etcd-v3-api-cpp version: ${ETCD-V3-API-CPP_VERSION_MAJOR}.${ETCD-V3-API-CPP_VERSION_MINOR}.${ETCD-V3-API-CPP_VERSION_PATCH}")
set(CPACK_PACKAGE_VERSION_MAJOR ${ETCD-V3-API-CPP_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${ETCD-V3-API-CPP_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${ETCD-V3-API-CPP_VERSION_PATCH})
# cpack settings, edit the following to pack up as you desire
if(UNIX)
    set(CPACK_GENERATOR "TGZ")
else()
    set(CPACK_GENERATOR "ZIP")
endif()
set(CPACK_PACKAGE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/packages)
include(CPack)
