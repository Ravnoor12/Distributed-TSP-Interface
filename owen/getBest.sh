#!/usr/bin/bash

function getCurrentBest() {
weightType=$1
distFile="database0$weightType.txt"
minDist=$(tail -n 5 "/users/PWSU0471/nehrbajo/proj03data/$distFile" | head -n 1)
echo "$minDist"
}


bestDist=$(getCurrentBest $1)
echo $bestDist
