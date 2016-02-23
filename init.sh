#!/bin/sh

#==============================================================================
#
# INITIALIZATION
#
# Variables used:
#
#   _DCM_MGMT
#   DEFAULT_MANAGER
#
#==============================================================================

if [ -n "$_DCM_MGMT" ]; then
    verbose-state
else
    use $DEFAULT_MANAGER
fi
