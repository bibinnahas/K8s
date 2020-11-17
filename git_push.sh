#!/bin/bash

argument=${1:-"default_commit_for_k8s_test"}
echo "commit comment:" $argument
git add .
git commit -m "$argument"
git pull
git push origin -f

