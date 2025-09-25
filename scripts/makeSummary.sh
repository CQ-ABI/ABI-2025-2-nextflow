#!/usr/bin/env bash

for i in $(ls split_*_repeatcount.txt | sort); do
  echo -n "$i" | cut -d "_" -f 2 | tr -d "\n"; echo -n ", "
  cat $i
done
