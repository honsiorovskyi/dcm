#!/bin/sh

#==============================================================================
#
# MODULE: dns
#
#   Provides an interface to Weave DNS.
#
# Variables used:
#
#   RUNTIME
#
#==============================================================================

dns_usage() {
    echo "Usage:"
    echo "  dns get [args...]"
    echo "  dns list [args...]"
}

dns_get() {
    $RUNTIME "weave dns_lookup $args"
}

dns_list() {
    $RUNTIME "weave status dns $args"
}

dns() {
    if [ $# -lt 1 ]; then
       dns_usage
       return 1
    fi

    command=$1; shift 1
    args=($@)

    case $command in 
        get)
            dns_get
            ;;
        list)
            dns_list
            ;;
        *)
            dns_usage
    esac
}

