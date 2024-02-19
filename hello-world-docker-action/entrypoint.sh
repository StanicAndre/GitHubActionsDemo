#!/bin/sh -l

echo "hello $1"

#echo "::set-output name=time::$(date)"
echo "time=$(date)" >> GITHUB_OUTPUT
