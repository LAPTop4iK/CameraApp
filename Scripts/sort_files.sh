#!/bin/sh
# stop script on any fail
set -e

PROJECT_PATH="$(git rev-parse --show-toplevel)"
XCODEPROJ_PATH=$(find "$PROJECT_PATH" -maxdepth 1 -type d -name '*.xcodeproj')

$PROJECT_PATH/Addons/sort-Xcode-project-file "$XCODEPROJ_PATH/project.pbxproj"

