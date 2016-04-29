#!/bin/sh

#==============================================================================
#
# VARIABLES
#
#==============================================================================

# handling zsh
if which setopt >/dev/null 2>&1; then
    setopt shwordsplit
fi

CONFIG_FILES=($HOME/.dcmrc $PWD/dcmrc)
RUNTIME=sh\ -c
CLUSTER_DIR=$HOME/cluster
DEFAULT_MANAGER=swarm
SWARM_MANAGER_HOST=tcp://127.0.0.1:4000
SWARM_INTERNAL_CIDR=10.32.0.0/12  # using auto-assign in the default Weave subnet
WEAVE_HOST=tcp://127.0.0.1:2375  # should be a TCP socket, because it is used in Docker port assignment
APP_UP_FLAGS=-d
APP_STOP_FLAGS=
APP_RM_FLAGS=-vf
APP_RESTART_FLAGS=
APP_LOGS_FLAGS=
APP_SCALE_FLAGS=
DEBUG=
VERBOSE=yes

# initialize user-defined config
