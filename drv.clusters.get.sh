#!/bin/bash
if [[ $0 =~ ^(.*)/([^/]+)$ ]]; then
	WORKDIR=${BASH_REMATCH[1]}
	CMDNAME=${BASH_REMATCH[2]}
fi
source ${WORKDIR}/drv.core
source ${WORKDIR}/drv.svm.client

if [[ -n "${SMHOST}" ]]; then
	ITEM="clusters"
	URL=$(buildURL "${ITEM}")
	if [[ -n "${URL}" ]]; then
		printf "[$(cgreen "INFO")]: svm [$(cgreen "list")] ${ITEM} [$(cgreen "$URL")]... " 1>&2
		smGet "${URL}" | jq --tab .
	fi
fi
