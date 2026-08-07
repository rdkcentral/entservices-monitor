#!/bin/bash
#
# If not stated otherwise in this file or this component's LICENSE
# file the following copyright and licenses apply:
#
# Copyright 2026 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x
set -e
##############################
THUNDER_TOOLS_COMMIT_SHA="d5dd83c7c19c49c7f25c558c126500bd2d64f7a4"
THUNDER_COMMIT_SHA="2c0fcc5529e7da734be558ca6efa05d934dcce31"
GITHUB_WORKSPACE="${PWD}"
ls -la ${GITHUB_WORKSPACE}
cd ${GITHUB_WORKSPACE}

# # #############################
#1. Install Dependencies and packages

apt-get update
apt-get install --no-install-recommends -y libcurl4-openssl-dev valgrind lcov clang libsystemd-dev libboost-all-dev libwebsocketpp-dev meson curl libunwind-dev libdrm-dev
pip install jsonref

###########################################
# Clone the required repositories


git clone -b R4_4-RDK https://github.com/rdkcentral/ThunderTools.git
cd ThunderTools
git checkout $THUNDER_TOOLS_COMMIT_SHA
cd ..

git clone -b R4_4-RDK https://github.com/rdkcentral/Thunder.git
cd Thunder
git checkout $THUNDER_COMMIT_SHA
cd ..

git clone --branch 4.0.8 https://github.com/rdkcentral/entservices-apis.git

git clone --branch develop https://github.com/rdkcentral/entservices-testframework.git

############################
# Build Thunder-Tools
echo "======================================================================================"
echo "Building ThunderTools"
cd ThunderTools
cd -

cmake -G Ninja -S ThunderTools -B build/ThunderTools \
    -DCMAKE_INSTALL_PREFIX="$GITHUB_WORKSPACE/install/usr" \
    -DCMAKE_MODULE_PATH="$GITHUB_WORKSPACE/install/tools/cmake" \
    -DGENERIC_CMAKE_MODULE_PATH="$GITHUB_WORKSPACE/install/tools/cmake" \

cmake --build build/ThunderTools --target install


############################
# Build Thunder
echo "======================================================================================"
echo "Building Thunder"

cd Thunder
cd -

cmake -G Ninja -S Thunder -B build/Thunder \
    -DMESSAGING=ON \
    -DCMAKE_INSTALL_PREFIX="$GITHUB_WORKSPACE/install/usr" \
    -DCMAKE_MODULE_PATH="$GITHUB_WORKSPACE/install/tools/cmake" \
    -DBINDING=127.0.0.1 \
    -DPORT=55555 \
    -DEXCEPTIONS_ENABLE=ON \

cmake --build build/Thunder --target install


############################
# Build entservices-apis
echo "======================================================================================"
echo "Building entservices-apis"
cd entservices-apis
rm -rf jsonrpc/DTV.json
patch -p1 < $GITHUB_WORKSPACE/patches/entservices-only-dirs.patch
cd -

cmake -G Ninja -S entservices-apis  -B build/entservices-apis \
    -DCMAKE_INSTALL_PREFIX="$GITHUB_WORKSPACE/install/usr" \
    -DCMAKE_MODULE_PATH="$GITHUB_WORKSPACE/install/tools/cmake" \

cmake --build build/entservices-apis --target install
