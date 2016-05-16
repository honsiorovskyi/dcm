
DEF_CONFIG=1

config_change_value() {
    local name=$1; shift 1
    local value=$1; shift 1
    
    echo "Where should I save this configuration to?"
    local _IFS=$IFS; IFS=$(echo -en "\n\b")
    local config
    select config in ${CONFIG_FILES[@]}; do
        if [ -z $config ]; then
            echo "Please select a number."
            continue
        fi
        
        sed -e "s/^${name}=.*$/${name}='${value}'/g" -i "$config" >/dev/null 2>&1
        
        if ! grep "${name}='${value}'" $config >/dev/null 2>&1; then
            printf "\n${name}='${value}'" >> $config
        fi
        
        return
    done
    IFS=$_IFS
}

config_usage() {
    config_print_debug
    echo
    echo 'Usage:'
    echo '    change - change a single setting value'
    echo '    use - change the management system used'
    echo '    dump - `cat` current config files in order they are processed by DCM'
    exit 1
}

config_print_debug() {
    if [ "$VERBOSE" = "yes" -o "$VERBOSE" = "true" -o "$VERBOSE" = "1" ]; then
        echo "[debug] Using runtime: ${RUNTIME}, management: ${MANAGEMENT}"
    fi
}

config_use() {
    [ $# -lt 1 ] && echo "Not enough arguments!" && config_usage
    
    case $1 in 
        swarm|weave|docker)  
            config_change_value "MANAGEMENT" "$1"          
            config_init
            ;;
        *)
            config_usage
            ;;
    esac
}

config_change() {
    [ $# -lt 2 ] && echo "Not enough arguments!" && config_usage
    config_change_value "$1" "$2"
    config_init
}

config_dump() {
    local config
    for config in "${CONFIG_FILES[@]}"; do
        [ -f "${config}" ] && echo "# --- ${config} ---" && cat "$config" && printf "\n\n"
    done
}

config() {
    if [ $# -lt 1 ]; then
       config_usage
       return 1
    fi

    local command=$1; shift 1

    case $command in
        use)
            config_use "$@"
            ;;
        change)
            config_change "$@"
            ;;
        dump)
            config_dump
            ;;
        *)
            config_usage
            ;; 
    esac

    config_print_debug
}

config_init() {
    # load user-defined config
    local config
    for config in "${CONFIG_FILES[@]}"; do
        [ -f "${config}" ] && source "$config"
    done
       
    case $MANAGEMENT in 
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
            echo "Environmental variable MANAGEMENT is set incorrectly. Exiting."
            exit 1
            ;;
    esac
}
