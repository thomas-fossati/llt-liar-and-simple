#!/bin/bash

set -eu
set -o pipefail

# interesting log tags:
# - LltRealtimeApp
# - PfFfMacScheduler
# - EpcSgwPgwApplication
# - EpcTftClassifier
# - EpcTft

declare -r S1_BW=5Mbps

function purge_results() {
  echo "purging previous results (should have been saved already)"
  rm -f $1/*.{txt,pcap,sca}
}

# $1: source
# $2: destination
function save_results() {
  local d="$2"
  echo "saving test results to ${d}"
  mkdir -p ${d}
  cp $1/*.{txt,pcap,sca} ${d}
}

function main() {
  local base_from=$1 base_to=$2

  for marking in "false" "true"
  do
    purge_results ${base_from}
    local tag="llt-simple-marking-${marking}"
    echo ">> Running trial with marking ${marking}"
    NS_LOG="LLTLiarAndSimple" ../../waf --run "llt-liar-and-simple --ns3::PointToPointEpcHelper::S1uLinkDataRate=$S1_BW --marking-enabled=${marking} --run=${tag}"
    save_results ${base_from} ${base_to}/${marking}
  done
}

main $*

# vim: ai ts=2 sw=2 et sts=2 ft=sh
