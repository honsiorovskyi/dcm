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

DEF_CLUSTER=1

cluster_usage() {
    echo "Usage:"
    echo "  cluster start_manager - starts Swarm Manager on the current host"
    echo "  cluster stop_manager - stops Swarm Manager on the current host"
    echo "  cluster ps - list all cluster containers"
    echo "  cluster pss - list all cluster containers in short format"
    echo "  cluster run <command> [args...] - run command in the cluster environment"
}

cluster_start_manager() {
    $RUNTIME "docker -H $WEAVE_HOST run \
        -e WEAVE_CIDR=$SWARM_INTERNAL_CIDR \
        -p ${SWARM_MANAGER_HOST#*//}:4000 \
        --name swarm -d \
        --restart always \
        swarm manage -H :4000 nodes://$(weave dns-lookup swarm-cluster | awk '{ print $1\":2375\" }' | sed -e ':a;/$/{N;s/\n/,/;ba}')"
}

cluster_stop_manager() {
    $RUNTIME "docker -H $WEAVE_HOST rm -vf swarm"
}

cluster_ps() {
    $RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker ps $@"
}

cluster_pss() {
    $RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker ps --format '{{ .ID }}  {{ .Names }}' $@"
}

cluster_run() {
    echo $@
    $RUNTIME "DOCKER_HOST=$_DOCKER_HOST $@"
}


cluster() {
    if [ $# -lt 1 ]; then
       cluster_usage
       return 1
    fi
    
    local command=$1; shift 1

    case $command in 
        start_manager)
            cluster_start_manager
            ;;
        stop_manager)
            cluster_stop_manager
            ;;
        ps)
            cluster_ps "$@"
            ;;
        pss)
            cluster_pss "$@"
            ;;
        run)
            cluster_run "$@"
            ;;
        *)
            cluster_usage 
    esac
}

# short alias
cls() {
    cluster "$@"
}
