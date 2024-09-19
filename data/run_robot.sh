#!/bin/bash

cd /data/cmk_synthetic_web
echo "Running the web test..."
rcc task script -- robot tests.robot
