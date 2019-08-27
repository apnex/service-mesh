#!/bin/bash
if [[ $0 =~ ^(.*)/([^/]+)$ ]]; then
	WORKDIR=${BASH_REMATCH[1]}
	CMDNAME=${BASH_REMATCH[2]}
fi
source ${WORKDIR}/drv.core
source ${WORKDIR}/drv.svm.client

CLUSTERNAME=${1}
function makeBody {
	read -r -d '' BODY <<-CONFIG
	{
		"clusterName": "${CLUSTERNAME}"
	}
	CONFIG
	printf "${BODY}"
}

if [[ -n "${CLUSTERNAME}" ]]; then
	if [[ -n "${SMHOST}" ]]; then
		BODY=$(makeBody)
		ITEM="clusters/instance/install"
		URL=$(buildURL "${ITEM}")
		if [[ -n "${URL}" ]]; then
			printf "[$(cgreen "INFO")]: svm [$(cgreen "create")] ${ITEM} [$(cgreen "${URL}")]... " 1>&2
			smPut "${URL}" "${BODY}"
		fi
	fi
else
	printf "[$(corange "ERROR")]: Usage: $(cgreen "${CMDNAME}") $(ccyan "<cluster-name>")\n" 1>&2
fi
