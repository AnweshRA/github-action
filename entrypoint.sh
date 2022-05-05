#!/bin/bash

CONFIG="--config ./gitleaksaction/rules.toml"

echo running gitleaks "$(gitleaks --version) with the following command👇"

if [ "$GITHUB_EVENT_NAME" = "push" ]
then
  echo gitleaks --pretty --repo-path=$GITHUB_WORKSPACE --verbose --redact --commit=$GITHUB_SHA $CONFIG
  gitleaks --pretty --repo-path=$GITHUB_WORKSPACE --verbose --redact --commit=$GITHUB_SHA $CONFIG
elif [ "$GITHUB_EVENT_NAME" = "pull_request" ]
then 
  git --git-dir="$GITHUB_WORKSPACE/.git" log --left-right --cherry-pick --pretty=format:"%H" remotes/origin/$GITHUB_BASE_REF...remotes/origin/$GITHUB_HEAD_REF > commit_list.txt
  echo gitleaks --pretty --repo-path=$GITHUB_WORKSPACE --verbose --redact --commits-file=commit_list.txt $CONFIG
  gitleaks --pretty --repo-path=$GITHUB_WORKSPACE --verbose --redact --commits-file=commit_list.txt $CONFIG
fi

if [ $? -eq 1 ]
then
echo -e "\e[31m🛑 STOP! Gitleaks encountered leaks"
echo "----------------------------------"
echo -e $DONATE_MSG
exit 1
else
echo -e "\e[32m✅ SUCCESS! Your code is good to go!"
echo "------------------------------------"
echo -e $DONATE_MSG
fi
