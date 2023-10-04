#!/bin/bash

set -e

check_commands()
{
    for cmd in "$@"
    do
        check_command "$cmd"
    done
}

check_command()
{
    command -v "$1" > /dev/null && return 0

    printf "please install '%s' before running this script\n" "$1"
    exit 1
}

check_commands git kubectl kustomize

TZ=${TZ:-$(ls -l /etc/localtime | cut -d'/' -f7,8)}
UPTIME_WEEK=${UPTIME_WEEK:-"Mon-Fri 08:00-19:00"}

kubectl get namespace dev-autoscaler &> /dev/null || kubectl create namespace dev-autoscaler

mkdir -p ./tmp
rm -rf ./tmp/config

cp -r ./config ./tmp/config

( cd tmp/config && \
    kustomize edit add configmap kube-downscaler --from-literal=DEFAULT_UPTIME="$UPTIME_WEEK $TZ" && \
    kustomize edit set namespace dev-autoscaler )

kustomize build ./tmp/config | kubectl apply -f -
