#!/bin/sh

CLOUD_DIR=~/cloud
SWARM_MANAGER_HOST=tcp://127.0.0.1:4000
SWARM_INTERNAL_CIDR=10.4.0.253/16
WEAVE_HOST=tcp://127.0.0.1:2375
UP_FLAGS=-d
STOP_FLAGS=
RM_FLAGS="-v -f"
RESTART_FLAGS=
LOGS_FLAGS=
SCALE_FLAGS=

dcm-init() {
    eval "$(weave env)"
}

dcm-cleanup() {
    eval "$(weave env --restore)"
}

app-usage() {
    echo "USAGE:"
    echo "\tdown <app_name> [args...]"
    echo "\tpull <app_name> [args...]"
    echo "\trestart <app_name> [args...]"
    echo "\tscale <app_name> [args...]"
    echo "\tstart <app_name> [args...]"
    echo "\tstop <app_name> [args...]"
    echo "\tup <app_name> [args...]"
    echo "\tupd <app_name> [args...]"
}

app-pull() {
    docker-compose -p $app_name -f $CLOUD_DIR/$app_name.yml pull $PULL_FLAGS $args
}


app-up() {
    docker-compose -p $app_name -f $CLOUD_DIR/$app_name.yml up $UP_FLAGS $args
}

app-rm() {
    docker-compose -p $app_name -f $CLOUD_DIR/$app_name.yml rm $RM_FLAGS $args
}

app-start() {
    docker-compose -p $app_name -f $CLOUD_DIR/$app_name.yml start $args
}

app-stop() {
    docker-compose -p $app_name -f $CLOUD_DIR/$app_name.yml stop $STOP_FLAGS $args
}

app-restart() {
    docker-compose -p $app_name -f $CLOUD_DIR/$app_name.yml restart $RESTART_FLAGS $args
}

app-logs() {
    docker-compose -p $app_name -f $CLOUD_DIR/$app_name.yml logs $LOGS_FLAGS $args
}

app-scale() {
    docker-compose -p $app_name -f $CLOUD_DIR/$app_name.yml scale $SCALE_FLAGS $args
}


app() {
    if [ $# -lt 2 ]; then
       app-usage
       return 1
    fi

    command=$1; shift 1
    app_name=$1; shift 1
    args=$@

    [ -f $CLOUD_DIR/$app_name.env ] && source $CLOUD_DIR/$app_name.env 
    case $command in 
        down)
            app-stop
            app-rm
            ;;
        pull)
            app-pull
            ;;
        restart)
            app-restart
            ;;
        scale)
            app-scale
            ;;
        start)
            app-start
            ;;
        stop)
            app-stop
            ;;
        up)
            app-up
            ;;
        upd)
            app-pull
            app-up
            ;;
        *)
            app-usage
    esac
}

dns-usage() {
    echo "USAGE:"
    echo "\tdns get [args...]"
    echo "\tdns list [args...]"
}

dns-get() {
    weave dns-lookup $args
}

dns-list() {
    weave status dns $args
}

dns() {
    if [ $# -lt 1 ]; then
       dns-usage
       return 1
    fi

    command=$1; shift 1
    args=$@

    case $command in 
        get)
            dns-get
            ;;
        list)
            dns-list
            ;;
        *)
            dns-usage
    esac
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

cluster() {
    if [ $# -lt 1 ]; then
       cluster-usage
       return 1
    fi

    command=$1; shift 1
    args=$@

    case $command in 
        start-manager)
            start-manager
            ;;
        stop-manager)
            stop-manager
            ;;
        *)
            cluster-usage 
    esac
}

