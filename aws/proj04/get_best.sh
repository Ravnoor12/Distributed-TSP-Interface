#!/usr/bin/bash

function getCurrentBest() {
weightType=$1
distFile="database$weightType.txt"
minDist=$(ssh "w597rxs@owens.osc.edu" "tail -n 5 /users/PWSU0471/nehrbajo/proj03data/$distFile | head -n 1")
echo "$minDist"
}

echo "started finding best distance $@"
dist=$(getCurrentBest $1)

echo "founded best dist: $dist"

echo $dist > bestDist.txt
