#!/bin/bash

echo "Cleanup environments..."
rcc config cleanup --all

# build the Playwright environment
cd cmk_synthetic_web
rm -f env.zip

echo "Building Playwright environment..."
time rcc ht vars >/dev/null 2>&1
rcc ht ls

echo "Exporting the environment... "
rcc holotree export --robot robot.yaml --zipfile env.zip

echo "Environment export done (env.zip)."
