#!/bin/bash

# build the Playwright environment from the RCC remote server (watch the logs on rccremote)
cd /data/cmk_synthetic_web
echo "Running the web test..."
rcc task script -- robot tests.robot
