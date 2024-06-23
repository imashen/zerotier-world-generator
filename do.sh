#!/bin/bash

set -e

echo "Enter public IP:"
read public_ip

echo "Enter port:"
read port

# Get identity from file
identity=$(cat identity.public)

# Temporary file for modified mkworld.cpp
temp_mkworld="mkworld_temp.cpp"

# Create or overwrite temporary mkworld.cpp
cp mkworld.cpp "$temp_mkworld"

# Insert definitions into temporary mkworld.cpp
sed -i "/\/\/ mycustomserver/r /dev/stdin" "$temp_mkworld" <<EOF
     roots.push_back(World::Root());
     roots.back().identity = Identity("$identity");
     roots.back().stableEndpoints.push_back(InetAddress("$public_ip/$port"));
EOF

echo "Wait a moment..."

mkdir -p bin
c++ -std=c++11 -Isrc -Isrc/ext -I.. -g -o bin/mkworld src/node/C25519.cpp src/node/Salsa20.cpp src/node/SHA512.cpp src/node/Identity.cpp src/node/Utils.cpp src/node/InetAddress.cpp src/osdep/OSUtils.cpp mkworld.cpp -lm

cd bin
./mkworld
mv world.bin ../planet

echo "Generate Done!"
cd ../
# Clean up temporary mkworld.cpp
rm "$temp_mkworld"
echo "Temporary Files Cleaned."
