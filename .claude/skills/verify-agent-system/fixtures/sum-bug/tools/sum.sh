#!/usr/bin/env bash
# Print the sum of the integers in a file, one per line.
#   tools/sum.sh <file>
set -euo pipefail
total=0
while read -r n; do
  total=$((total + n))
done < "$1"
echo "$total"
