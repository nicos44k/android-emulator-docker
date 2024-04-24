#!/bin/bash

SCRIPT_DIRECTORY=$(dirname "$0")

docker build --tag android_emulator_image --build-arg HOST_UID=$(id --user) --build-arg HOST_GID=$(id --group) $SCRIPT_DIRECTORY
