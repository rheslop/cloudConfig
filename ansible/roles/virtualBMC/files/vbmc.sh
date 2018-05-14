#!/bin/bash

for i in {1..3}; do
  if vbmc list | grep controller-${i} > dev/null ; then : ; else
  vbmc add controller-${i} --port 621${i} --username admin --password password ; fi
done

for i in {1..3}; do
  if vbmc list | grep compute-${i} > dev/null ; then : ; else
  vbmc add compute-${i} --port 623${i} --username admin --password password ; fi
done
