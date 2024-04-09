#!/bin/bash

# Initialize performance variables
perf_1=0
perf_4=0

# Compile and run the program with different thread counts
for t in 1 4
do
  echo -e "\nNumber of threads = $t"
  gcc -DNUMT=$t main.c -o main -lm -fopenmp -std=c99

  OUTPUT=$(./main 2>&1)
  echo "$OUTPUT"

  if [ $t -eq 1 ]; then
    perf_1=$(echo "$OUTPUT" | grep 'Peak Performance' | awk '{print $7}')
  else
    perf_4=$(echo "$OUTPUT" | grep 'Peak Performance' | awk '{print $7}')
  fi
done

# Ensure performance metrics are numeric
if ! [[ "$perf_1" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! [[ "$perf_4" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  echo "Error: Performance metrics are not numeric."
  exit 1
fi

# Calculate Speedup S = (Performance with four threads) / (Performance with one thread)
S=$(echo "scale=3; $perf_4 / $perf_1" | bc -l)
printf "Speedup (S): %.3f\n" "$S"

# Compute the parallel fraction
Fp=$(echo "scale=2; (4/3)*(1-(1/$S))" | bc -l)
printf "Parallel Fraction (Fp): %.2f\n" "$Fp"
