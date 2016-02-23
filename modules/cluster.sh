#!/bin/sh

#==============================================================================
#
# MODULE: cluster
#
#   Provides common cluster management commands.
#
# Variables used:
#
#   WEAVE_HOST
#   WEAVE_CIDR
#   SWARM_INTERNAL_CIDR
#   SWARM_MANAGER_HOST
#
#==============================================================================

cluster-usage() {
    echo "Usage:"
    echo "  cluster start-manager - starts Swarm Manager on the current host"
    echo "  cluster stop-manager - stops Swarm Manager on the current host"
    echo "  cluster ps - list all cluster containers"
}

cluster-start-manager() {
    docker -H $WEAVE_HOST run \
        -e WEAVE_CIDR=$SWARM_INTERNAL_CIDR \
        -p $SWARM_MANAGER_HOST:4000 \
        --name swarm -d \
        swarm manage -H :4000 nodes://$(weave dns-lookup swarm-cluster | awk '{ print $1":2375" }' | sed -e ':a;/$/{N;s/\n/,/;ba}')
}

cluster-stop-manager() {
    docker -H $WEAVE_HOST rm -vf swarm
}

cluster-ps() {
    DOCKER_HOST=$_DOCKER_HOST docker ps
}

cluster() {
    if [ $# -lt 1 ]; then
       cluster-usage
       return 1
    fi

    verbose-state

    command=$1; shift 1
    args=$@

    case $command in 
        start-manager)
            start-manager
            ;;
        stop-manager)
            stop-manager
            ;;
        ps)
            cluster-ps
            ;;
        *)
            cluster-usage 
    esac
}

alias cls='cluster'
