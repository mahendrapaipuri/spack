#!/bin/bash
#
# Copyright 2013-2021 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

#
# This script ensures that Spack can help users edit a configuration file
# even when the configuration is not valid.
#

# Source setup-env.sh before tests
export QA_DIR=$(dirname "$0")
export SHARE_DIR=$(cd "$QA_DIR/.." && pwd)
. "$SHARE_DIR/setup-env.sh"

env_cfg=""

function cleanup {
  # Regardless of whether the test fails or succeeds, we can't remove the
  # environment without restoring spack.yaml to match the schema
  if [ ! -z "env_cfg" ]; then
    echo "\
spack:
  specs: []
  view: False
" > "$env_cfg"
  fi

  spack env deactivate
  spack env rm -y broken-cfg-env
}

trap cleanup EXIT

spack env create broken-cfg-env
echo "Activating test environment"
spack env activate broken-cfg-env
env_cfg=`spack config --scope=env:broken-cfg-env edit --print-file`
echo "Environment config file: $env_cfg"

# Create an invalid packages.yaml configuration in the directory
echo "\
spack:
  specs: []
  view: False
  packages:
    what:
" > "$env_cfg"

echo "Try 'spack config edit' with broken environment"
spack config edit --print-file

