#!/bin/sh

#==============================================================================
#
# VARIABLES
#
#==============================================================================

RUNTIME=(sh -c)
CLUSTER_DIR=$HOME/cluster
DEFAULT_MANAGER=swarm
SWARM_MANAGER_HOST=tcp://127.0.0.1:4000
SWARM_INTERNAL_CIDR=10.32.0.0/12  # using auto-assign in the default Weave subnet
WEAVE_HOST=tcp://127.0.0.1:2375  # should be a TCP socket, because it is used in Docker port assignment
UP_FLAGS=-d
STOP_FLAGS=
RM_FLAGS=-vf
RESTART_FLAGS=
LOGS_FLAGS=
SCALE_FLAGS=
DEBUG=
VERBOSE=yes

# load user-defined config
[ -f $HOME/.dcmrc ] && source $HOME/.dcmrc
[ -f ./dcmrc ] && source ./dcmrc
