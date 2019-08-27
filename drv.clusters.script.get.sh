#!/bin/bash
if [[ $0 =~ ^(.*)/([^/]+)$ ]]; then
	WORKDIR=${BASH_REMATCH[1]}
	CMDNAME=${BASH_REMATCH[2]}
fi
source ${WORKDIR}/drv.core
source ${WORKDIR}/drv.svm.client

CLUSTERNAME=${1}
if [[ -n "${SMHOST}" && -n "${CLUSTERNAME}" ]]; then
	ITEM="clusters/cluster-agent-script"
	URL=$(buildURL "${ITEM}")
	URL+="?type=yaml&ClusterId=${CLUSTERNAME}"
	if [[ -n "${URL}" ]]; then
		printf "[$(cgreen "INFO")]: svm [$(cgreen "list")] ${ITEM} [$(cgreen "$URL")]... " 1>&2
		smGet "${URL}"
	fi
else
	printf "[$(corange "ERROR")]: Usage: $(cgreen "${CMDNAME}") $(ccyan "<cluster-name>")\n" 1>&2
fi

