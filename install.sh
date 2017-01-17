#!/bin/bash

# usage: install.sh ben-biddington repo-name {api key}

username=$1
repo=onboarding_me
accessToken=$2

echo "Switching on issues for username <$username> using access token <$accessToken> using <https://api.github.com/repos/$username/$repo>"

curl -u $username:$accessToken -iL -X PATCH -d '{ "name": "$repo", "has_issues":"true"}' -H 'Content-Type: application/json' "https://api.github.com/repos/$username/$repo"
