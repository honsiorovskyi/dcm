#!/bin/sh

MODULES=(config app cluster dns)
MODULES_ALIASES=(cls)

source ./vars.sh

for module in "${MODULES[@]}"; do
    source ./modules/${module}.sh
done

config_init


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

contains() {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}


if [ $# -gt 0 ]; then
    module=$1; shift 1
    
    if ! contains $module ${MODULES[@]} ${MODULES_ALIASES[@]} ; then
        echo "Module '$module' not found"
        exit 1
    fi
    
    # # display debug info
    # if [ -n "$_DCM_MGMT" ]; then
    #     verbose_state
    # else
    #     use $DEFAULT_MANAGER
    # fi
    
    # run module
    $module "$@"
fi

