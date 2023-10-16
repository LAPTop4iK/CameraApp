#!/bin/sh
# stop script on any fail
set -e

PROJECT_PATH="$(git rev-parse --show-toplevel)"
$PROJECT_PATH/Addons/swiftlint --silence-deprecation-warnings . $@

