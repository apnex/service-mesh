#!/bin/bash
if [[ $0 =~ ^(.*)/([^/]+)$ ]]; then
	WORKDIR=${BASH_REMATCH[1]}
	CMDNAME=${BASH_REMATCH[2]}
fi
source ${WORKDIR}/drv.core
source ${WORKDIR}/vke.parameters

VKE_CLUSTER_NAME=${1}
if [[ -n "${VKE_CLUSTER_NAME}" ]]; then
	vke account login --organization ${CSP_ORGANIZATION_ID} --refresh-token ${CSP_REFRESH_TOKEN}
	vke cluster auth setup --folder SharedFolder --project SharedProject ${VKE_CLUSTER_NAME}
else
	printf "[$(corange "ERROR")]: Usage: $(cgreen "${CMDNAME}") $(ccyan "<cluster.name>")\n" 1>&2
fi
