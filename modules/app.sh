#!/bin/bash

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

app_usage() {
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

pad() {
    n=$1; shift 1
    printf "%${n}s$*\n"
}

app_create() {
    # NOT IMPLEMENTED:
    # - [ version 1 only supported ]
    # - build
    # - logging
    # - aliases
    # - ipv4_address, ipv6_address
    # - ulimits
    # - volumes
    local app_name=$1; shift
    local config
    if [ -n "$app_name" -a "$app_name" != "-" ]; then
        config=$CLUSTER_DIR/$app_name.yml
        if [ -e "$config" ]; then
             local ans
             echo -n "File '$config' exists. Overwrite? [y/N] "
             read ans
             
             if [ "$ans" != "y" -a "$ans" != "Y" ]; then
                echo "Skipping. Config is NOT written" 
                return
            fi
        fi
    else
        config="/dev/stdout"
    fi
        
    while [ $# -ge 2 ] ; do
        local option=$1; shift 1
        case ${option} in
            --name)
                local name=$1; shift 1
                pad 0 "$name:" >> $config
                ;;                
            --restart|--image|--hostname|--command|--cgroup_parent|--container_name|--entrypoint|--log-driver|--net|--pid|--stop_signal)
                local val=$1; shift 1
                pad 4 "${option##--}: $val" >> $config
                ;;
            --volumes|--ports|--environment|--extra_hosts|--links|--cap_add|--cap_drop|--devices|--dns|--depends_on|--dns_search|--tmpfs|--env_file|--expose|--external_links|--extra_hosts|--labels|--security_opt|--volumes_from)
                local items=()
                while [[ "$1" != --* && $# -ge 1 ]] ; do # while we didn't find another option
                    items+=("$1")
                    shift 1
                done
                
                pad 4 "${option##--}:" >> $config
                for (( i = 0; i < ${#items[@]}; i++ )) ; do
                    pad 8 "- ${items[$i]}" >> $config
                done
                ;;
            --extends|--log_opt)
                # TODO: implement multilevel maps
                local items=()
                while [[ "$1" != --* && $# -ge 1 ]] ; do # while we didn't find another option
                    items+=("$1")
                    shift 1
                done
                
                pad 4 "${option##--}:" >> $config
                for (( i = 0; i < ${#items[@]}; i++ )) ; do
                    pad 8 "${items[$i]%%:*}: ${items[$i]#*:}" >> $config
                done
                ;;
                
        esac
    done
}

app_compose_cmd() {
    local compose_cmd=$1; shift
    local app_name=$1; shift
    
    local flags_varname=$(echo "app_${compose_cmd}_flags" | tr "[:lower:]" "[:upper:]")
    local flags=${!flags_varname} || echo hello
    
    echo $RUNTIME "[ -f \"$CLUSTER_DIR/$app_name.env\" ] && source $CLUSTER_DIR/$app_name.env && echo 'Using $CLUSTER_DIR/$app_name.env...'; DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f ${CLUSTER_DIR}/${app_name}.yml $compose_cmd $flags $@"
    $RUNTIME "[ -f \"$CLUSTER_DIR/$app_name.env\" ] && source $CLUSTER_DIR/$app_name.env && echo 'Using $CLUSTER_DIR/$app_name.env...'; DOCKER_HOST=$_DOCKER_HOST docker-compose -p $app_name -f ${CLUSTER_DIR}/${app_name}.yml $compose_cmd $flags $@"
}


app() {
    if [ "$#" -lt 2 ]; then
       app_usage
       return 1
    fi

    local command=$1; shift 1
    local app_name=$1; shift 1

    local APP_RUNTIME=($RUNTIME "[ -f \"$CLUSTER_DIR/$app_name.env\" ] && source $CLUSTER_DIR/$app_name.env &&
        ([ "$VERBOSE" = "yes" -o "$VERBOSE" = "true" -o "$VERBOSE" = "1" ] && echo Using $CLUSTER_DIR/$app_name.env...) ;") 
    case $command in 
        create)
            app_create "$app_name" "$@"
            ;;
            
        down)
            app_compose_cmd stop "$app_name" "$@"
            app_compose_cmd rm "$app_name" "$@"
            ;;
            
        logs|pull|restart|scale|start|stop|up)
            app_compose_cmd "$command" "$app_name" "$@"
            ;;
            
        update|upd)
            app_compose_cmd pull "$app_name" "$@"
            app_compose_cmd up "$app_name" "$@"
            ;;
            
        *)
            app_usage
    esac
}
