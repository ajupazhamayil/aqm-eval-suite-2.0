#!/bin/bash

VirtualCores=$(nproc --all)
VirtualCoresUsed=$(($VirtualCores-2))
if (( VirtualCoresUsed < 1 )); then
  VirtualCoresUsed=1
  echo "Only one core is used"
fi

ScenarioNumbers="5.1.1
5.1.2
5.2
5.3.1
5.3.2
5.4
6
8.2.2
8.2.3
8.2.4
8.2.5
8.2.6.1
8.2.6.2
4.5"


RunOneScenario () {
  local ScenarioNum='./waf --run "aqm-eval-suite-runner --number='$1'"'
  echo $ScenarioNum
  eval $ScenarioNum
}

i=0
pids=""
for sn in $ScenarioNumbers
do
  if (($i%$VirtualCoresUsed==0))
  then
    for p in $pids; do
      if wait $p; then
        echo "Process $p success"
      else
        echo "Process $p fail, So Exiting the all process"
        exit 1
      fi
    done
    echo $pids
    pids=""
  fi
  RunOneScenario "$sn" &
  pids+=" $!"
  ((++i))
done
wait
