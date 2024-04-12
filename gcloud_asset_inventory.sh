#!/usr/bin/env bash
set -euo pipefail

check_binary(){
  if ! command -v "${1}" &> /dev/null
  then
      echo "${1} is a required binary, please install"
      exit 1
  fi
}

if [ "$(uname)" == "Darwin" ]; then
  date_cmd="gdate"  
else
  date_cmd="date"
fi

declare -r organizationID=${organizationID:-}

declare -r time=${1:-$(TZ=GMT $date_cmd +"%Y-%m-%dT%H:%M:%SZ")}

declare -a organizations=("$organizationID") # add relevant organization IDs here

declare -ar types=(
  appengine.googleapis.com/Application
  cloudfunctions.googleapis.com/CloudFunction
  compute.googleapis.com/Instance
  compute.googleapis.com/K8RelatedInstance
  sqladmin.googleapis.com/Instance
  storage.googleapis.com/Bucket
  k8s.io/Node
)

check_binary "gcloud"
check_binary "jq"

if [ -z "$organizationID" ]; then
  echo "usage: organizationID=someID gcloud_asset_inventory.sh"
  exit 1
fi

outfile=$(mktemp -q)
# shellcheck disable=SC2048
for type in ${types[*]}; do

  if [ "$type" == "compute.googleapis.com/K8RelatedInstance" ]; then
    (echo "${organizations[*]}" \
      | xargs -n1 -I{} gcloud asset list \
          --asset-types "compute.googleapis.com/Instance" \
          --content-type resource \
          --format 'value(assetType)' \
          --organization {} \
          --snapshot-time "$time" \
          --filter 'resource.data.labels:goog-gke-node' \
      | sort \
      | uniq -c \
      | awk '{ printf "{\"compute.googleapis.com/K8RelatedInstance\":%s}\n", $1 }' >> "$outfile") &
  else
    (echo "${organizations[*]}" \
      | xargs -n1 -I{} gcloud asset list \
          --asset-types "$type" \
          --content-type resource \
          --format 'value(assetType)' \
          --organization {} \
          --snapshot-time "$time" \
      | sort \
      | uniq -c \
      | awk '{ printf "{\"%s\":%s}\n", $2, $1 }' >> "$outfile") &
  fi

done

wait

jq -sS add < "$outfile"

rm "${outfile}"
