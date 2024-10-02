#!/bin/bash

echo "Cleanup environments..."
rcc config cleanup --all

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
rccremote -hostname 0.0.0.0 -debug -trace
