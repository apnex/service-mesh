#!/bin/bash
if [[ $0 =~ ^(.*)/([^/]+)$ ]]; then
	WORKDIR=${BASH_REMATCH[1]}
	CMDNAME=${BASH_REMATCH[2]}
fi
source ${WORKDIR}/drv.core
source ${WORKDIR}/drv.svm.client

function buildNode {
	local KEY=${1}

	read -r -d '' JQSPEC <<-CONFIG # collapse into single line
		.[] | select(.name=="${KEY}")
	CONFIG
	NODE=$(echo ${NODES} | jq -r "$JQSPEC")

	# build node record
	read -r -d '' NODESPEC <<-CONFIG
		{
			"id": .name
		}
	CONFIG
	NEWNODE=$(echo "${NODE}" | jq -r "${NODESPEC}")

	## get node status
	RESULT=$(${WORKDIR}/drv.clusters.status.get.sh "${KEY}")

	read -r -d '' STATUSSPEC <<-CONFIG
		{
			"state": .lifeCycle.state,
			"details": .lifeCycle.details
		}
	CONFIG
	NEWSTAT=$(echo "${RESULT}" | jq -r "${STATUSSPEC}")

	# merge node and status
	MYNODE="$(echo "${NEWNODE}${NEWSTAT}" | jq -s '. | add')"
	printf "%s\n" "${MYNODE}"
}

## input driver
NODES=$(${WORKDIR}/drv.clusters.get.sh)

## build result
FINAL="[]"
for KEY in $(echo ${NODES} | jq -r '.[] | .name'); do
	MYNODE=$(buildNode "${KEY}")
	FINAL="$(echo "${FINAL}[${MYNODE}]" | jq -s '. | add')"
done
printf "${FINAL}" | jq --tab .
