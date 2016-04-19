#!/bin/sh

#==============================================================================
#
# MODULE: cluster
#
#   Provides common cluster management commands.
#
# Variables used:
#
#   RUNTIME
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
    echo "  cluster pss - list all cluster containers in short format"
    echo "  cluster run <command> [args...] - run command in the cluster environment"
}

cluster-start-manager() {
    $RUNTIME "docker -H $WEAVE_HOST run \
        -e WEAVE_CIDR=$SWARM_INTERNAL_CIDR \
        -p ${SWARM_MANAGER_HOST#*//}:4000 \
        --name swarm -d \
        --restart always \
        swarm manage -H :4000 nodes://$(weave dns-lookup swarm-cluster | awk '{ print $1\":2375\" }' | sed -e ':a;/$/{N;s/\n/,/;ba}')"
}

cluster-stop-manager() {
    $RUNTIME "docker -H $WEAVE_HOST rm -vf swarm"
}

cluster-ps() {
    $RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker ps $args"
}

cluster-pss() {
    $RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker ps --format '{{ .ID }}  {{ .Names }}' $args"
}

cluster-run() {
    $RUNTIME "DOCKER_HOST=$_DOCKER_HOST $args"
}


cluster() {
    if [ $# -lt 1 ]; then
       cluster-usage
       return 1
    fi

    verbose-state

    command=$1; shift 1
    args=($@)

    case $command in 
        start-manager)
            cluster-start-manager
            ;;
        stop-manager)
            cluster-stop-manager
            ;;
        ps)
            cluster-ps
            ;;
        pss)
            cluster-pss
            ;;
        run)
            cluster-run
            ;;
        *)
            cluster-usage 
    esac
}

alias cls='cluster'
