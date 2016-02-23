#!/bin/sh

#==============================================================================
#
# INITIALIZATION
#
# Variables used:
#
#   _DCM_MGMT
#
#==============================================================================

if [ -n $_DCM_MGMT ]; then
    verbose-state
else
    use swarm
fi
