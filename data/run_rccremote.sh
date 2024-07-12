#!/bin/bash

# shared Holotree is required for rccremote to work
echo "Enabling shared Holotree..."
rcc ht shared -e
rcc ht init

# build the Playwright environment
cd cmk_synthetic_web
echo "Building Playwright environment..."
time rcc ht vars >/dev/null 2>&1
rcc ht ls

echo "Starting rccremote..."
rccremote -hostname rccremote -debug -trace
