#!/bin/bash
if [[ $0 =~ ^(.*)/([^/]+)$ ]]; then
	WORKDIR=${BASH_REMATCH[1]}
	CMDNAME=${BASH_REMATCH[2]}
fi
source ${WORKDIR}/drv.core
source ${WORKDIR}/demo-magic.sh

if [[ -n ${1} ]]; then
	# get yaml file
	./cmd.clusters.script.get.sh "${1}"

	# tag for istio
	clear
	pe "kubectl delete -f nsx-sm_${1}.yaml"

	# watch pods for registration
	pe "watch -n 5 kubectl get pods --all-namespaces"
else
	printf "[$(corange "ERROR")]: Usage: $(cgreen "${CMDNAME}") $(ccyan "<cluster.name>")\n" 1>&2
fi

