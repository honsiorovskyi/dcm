#!/bin/sh

#==============================================================================
#
# MODULE: debug
#
#   Provides debugging facilities.
#
# Variables used:
#
#   VERBOSE
#   RUNTIME
#   _DCM_MGMT
#
#==============================================================================

verbose-state() {
    if [ "$VERBOSE" = "yes" -o "$VERBOSE" = "true" -o "$VERBOSE" = "1" ]; then
        echo "--------------------------"
        echo "Runtime    : $RUNTIME"
        echo "Management : $_DCM_MGMT"
        echo "--------------------------"
    fi
}
