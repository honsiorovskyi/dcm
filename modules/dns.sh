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

dns-usage() {
    echo "Usage:"
    echo "  dns get [args...]"
    echo "  dns list [args...]"
}

dns-get() {
    $RUNTIME "weave dns-lookup $args"
}

dns-list() {
    $RUNTIME "weave status dns $args"
}

dns() {
    if [ $# -lt 1 ]; then
       dns-usage
       return 1
    fi

    command=$1; shift 1
    args=($@)

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

