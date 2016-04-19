#!/bin/sh

#==============================================================================
#
# MODULE: app
#
#   Provides application management commands.
#
# Variables used:
#
#   RUNTIME
#   APP_RUNTIME [internal]
#   _DOCKER_HOST
#   CLUSTER_DIR
#   PULL_FLAGS
#   UP_FLAGS
#   RM_FLAGS
#   STOP_FLAGS
#   RESTART_FLAGS
#   LOGS_FLAGS
#   SCALE_FLAGS
#
#==============================================================================

app-usage() {
    echo "USAGE:"
    echo "  app down <app_name> [args...]"
    echo "  app logs <app_name> [args...]"
    echo "  app pull <app_name> [args...]"
    echo "  app restart <app_name> [args...]"
    echo "  app scale <app_name> [args...]"
    echo "  app start <app_name> [args...]"
    echo "  app stop <app_name> [args...]"
    echo "  app up <app_name> [args...]"
    echo "  app update <app_name> [args...] (shortcut: upd)"
}

app-pull() {
    $APP_RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f $CLUSTER_DIR/$app_name.yml pull $PULL_FLAGS $args"
}

app-up() {
    $APP_RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f $CLUSTER_DIR/$app_name.yml up $UP_FLAGS $args"
}

app-rm() {
    $APP_RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f $CLUSTER_DIR/$app_name.yml rm $RM_FLAGS $args"
}

app-start() {
    $APP_RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f $CLUSTER_DIR/$app_name.yml start $args"
}

app-stop() {
    $APP_RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f $CLUSTER_DIR/$app_name.yml stop $STOP_FLAGS $args"
}

app-restart() {
    $APP_RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f $CLUSTER_DIR/$app_name.yml restart $RESTART_FLAGS $args"
}

app-logs() {
    $APP_RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f $CLUSTER_DIR/$app_name.yml logs $LOGS_FLAGS $args"
}

app-scale() {
    $APP_RUNTIME "DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f $CLUSTER_DIR/$app_name.yml scale $SCALE_FLAGS $args"
}


app() {
    if [ $# -lt 2 ]; then
       app-usage
       return 1
    fi

    command=$1; shift 1
    app_name=$1; shift 1
    args=($@)

    APP_RUNTIME=($RUNTIME "[ -f $CLUSTER_DIR/$app_name.env ] && source $CLUSTER_DIR/$app_name.env &&
        ([ "$VERBOSE" = "yes" -o "$VERBOSE" = "true" -o "$VERBOSE" = "1" ] && echo Using $CLUSTER_DIR/$app_name.env...) ;") 
    case $command in 
        down)
            app-stop
            app-rm
            ;;
        logs)
            app-logs
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
        update|upd)
            app-pull
            app-up
            ;;
        *)
            app-usage
    esac
}
