#!/bin/bash

echo "Cleanup environments..."
rcc config cleanup --all

echo "Available RCC environents:"
rcc ht ls

echo "Importing the environment from ZIP file... "
rcc holotree import /data/cmk_synthetic_web/env.zip

echo "Environment import done (env.zip)."
echo "Available RCC catalogs:"
rcc ht catalogs
