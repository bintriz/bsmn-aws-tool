#!/bin/bash

ARGUMENT_LIST=(
    "timezone"
)

# read arguments
opts=$(getopt \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)

eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        --timezone)
            TZ=$2
            shift 2
            ;;

        *)
            break
            ;;
    esac
done

# Installing packages
yum -y update
yum -y install libcurl-devel gsl-devel # for bcftools
yum -y install readline-devel sqlite-devel # for python
yum -y install gcc72-c++ libXpm-devel xauth # for root
yum -y install tmux parallel emacs # etc 

# Timezone
ZONEINFO=$(find /usr/share/zoneinfo -type f|sed 's|/usr/share/zoneinfo/||') 
if [[ ! -z "$TZ" ]] && [[ $ZONEINFO =~ (^|[[:space:]])"$TZ"($|[[:space:]]) ]]; then
    sed -i '/ZONE/s|UTC|'$TZ'|' /etc/sysconfig/clock
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
    reboot
fi