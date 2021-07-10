#!/bin/bash
set -euo pipefail

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

if [ -z ${1+x} ]; then
    echo "Please run the Docker image with Bamboo URL as the first argument"
    exit 1
fi

if [ ! -f ${BAMBOO_CAPABILITIES} ]; then
    cp ${INIT_BAMBOO_CAPABILITIES} ${BAMBOO_CAPABILITIES}
fi

if [ -z ${SECURITY_TOKEN+x} ]; then   
    exec java ${VM_OPTS:-} -jar "${AGENT_JAR}" "${1}/agentServer/"
else 
    exec java ${VM_OPTS:-} -jar "${AGENT_JAR}" "${1}/agentServer/" -t "${SECURITY_TOKEN}"
fi 
