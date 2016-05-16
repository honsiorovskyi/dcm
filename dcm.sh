#!/bin/sh

# modules configuration
MODULES=(config app cluster dns)
MODULES_ALIASES=(cls)

contains() {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

source ./vars.sh

# load modules
for module in "${MODULES[@]}"; do
    source ./modules/${module}.sh
done

# load config
if [ -n "$DEF_CONFIG" ]; then
    config_init
else
    echo "Configuration module is not enabled! Exiting."
    exit 1
fi


# process command line arguments if any
if [ $# -gt 0 ]; then
    module=$1; shift 1
    
    # if the module is not loaded, exit
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

