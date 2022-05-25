#!/usr/bin/env bash
set -euo pipefail

check_binary(){
  if ! command -v "${1}" &> /dev/null
  then
      echo "${1} is a required binary, please install"
      exit 1
  fi
}

declare -r organizationID=${organizationID:-}

declare -r time=${1:-$(TZ=GMT date +"%Y-%m-%dT%H:%M:%SZ")}

check_binary "gcloud"
check_binary "jq"

if [ -z "$organizationID" ]; then
  echo "usage: organizationID=someID gcloud_scc_inventory.sh"
  exit 1
fi

gcloud scc assets group "${organizationID}" \
  --format json \
  --group-by "security_center_properties.resource_type" \
  --page-size 1000 \
  --read-time "$time" \
  | jq -rS '[.[0].groupByResults[] | { "\(.properties[])": .count }] | add'
