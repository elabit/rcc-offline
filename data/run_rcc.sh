#!/bin/bash

echo "Current RCC environents:"
rcc ht ls

echo "Setting RCC_REMOTE_ORIGIN..."
export RCC_REMOTE_ORIGIN="http://rccremote:4653"

# build the Playwright environment from the RCC remote server (watch the logs on rccremote)
cd cmk_synthetic_web
echo "Building Playwright environment, fetch sources from rccremote..."
time rcc ht vars >/dev/null 2>&1
rcc ht ls
