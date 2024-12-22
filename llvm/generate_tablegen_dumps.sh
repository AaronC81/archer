#!/bin/bash
set -e

# ==================================================================================================
# Regenerates LLVM TableGen dumps for Archer-supported architectures.
#
# This will:
#   - Build a Docker container with LLVM checkout(s) and TableGen build(s)
#   - Start the container
#   - Run TableGen to generate files for each supported architecture
#   - Tear down the Docker container
#
# If you get "Killed" messages, increase the daemon memory allowance in Docker Desktop.
# ==================================================================================================


# https://stackoverflow.com/a/246128/2626000
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create dump directory
rm -rf dump
mkdir -p dump

# Build and start Docker container with reproducible LLVM builds
docker build . -t archer-dump
container=$(docker run --rm -v "$SCRIPT_DIR/dump:/out" -dti archer-dump /bin/sh)
echo "Started container: $container"

# Run script to generate dumps
docker exec $container /bin/bash /script/dump.sh

# Kill container
# Because we started it with `--rm`, it'll be deleted automatically
docker kill $container
