#!/bin/sh

#==============================================================================
#
# MODULE: use
#
#   This module is used to setup internal _DOCKER_HOST variable according
#   to the management system used. The default option is to manage cluster
#   with the Swarm Manager, but also you can work directly with Weave
#   or Docker itself.
#
# Variables used:
#
#   _DOCKER_HOST [export]
#   SWARM_MANAGER_HOST
#   WEAVE_HOST
#   DOCKER_HOST [system]
#
#==============================================================================

use-usage() {
    echo "use - sets up the internal _DOCKER_HOST variable, which is used to specify the current management system."
    echo ""
    echo "Usage:"
    echo "  use swarm - use Swarm Manager as a mangement system"
    echo "  use weave - use Weave Proxy as a management system"
    echo "  use docker - use Docker itself as a management system"
}

use() {
    if [ $# -lt 1 ]; then
       use-usage
       return 1
    fi

    command=$1; shift 1
    args=$@

    export _DCM_MGMT=$command
    case $command in 
        swarm)            
            [ -z $SWARM_MANAGER_HOST ] && echo "Warning! SWARM_MANAGER_HOST variable is not defined."
            export _DOCKER_HOST=$SWARM_MANAGER_HOST
            ;;
        weave)
            [ -z $WEAVE_HOST ] && echo "Warning! WEAVE_HOST variable is not defined."
            export _DOCKER_HOST=$WEAVE_HOST
            ;;
        docker)
            export _DOCKER_HOST=$DOCKER_HOST
            ;;
        *)
            use-usage 
    esac

    # here we place `verbose-state` at the end, since `use` changes system state
    verbose-state
}
