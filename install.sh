#!/bin/bash

# usage: install.sh ben-biddington repo-name {api key}

username=$1
repo="onboarding_me"
accessToken=$2

function post {
  path=$1
  body=$2
  url=https://api.github.com/repos/$username/$repo$path

  # echo "url: $url"

  curl -u $username:$accessToken -iL -X POST -d "$body" -H 'Content-Type: application/json' "$url"
}

function _delete {
  path=$1

  url=https://api.github.com/repos/$username/$repo$path

  # echo "url: $url"

  curl -u $username:$accessToken -X DELETE "$url"
}

function addLabels {
  echo "Creating labels"

  curl -u $username:$accessToken -iL -X POST -d '{ "name": "1 Easy", "color" : "00ff00" }' -H 'Content-Type: application/json' "https://api.github.com/repos/$username/$repo/labels"
  curl -u $username:$accessToken -iL -X POST -d '{ "name": "1 Medium" }' -H 'Content-Type: application/json' "https://api.github.com/repos/$username/$repo/labels"
  curl -u $username:$accessToken -iL -X POST -d '{ "name": "2 Hard", "color" : "ff0000" }' -H 'Content-Type: application/json' "https://api.github.com/repos/$username/$repo/labels"
}

# todo: add emoji
function addMilestones {
  echo "Creating milestones"

  _delete '/milestones/1'
  _delete '/milestones/2'
  _delete '/milestones/3'

  post '/milestones' '{ "title": "00 The People and The tools" }' -H 'Content-Type: application/json'
  post '/milestones' '{ "title": "01 Getting hands on" }' -H 'Content-Type: application/json'
  post '/milestones' '{ "title": "02 Doing your best work" }' -H 'Content-Type: application/json'
}

function addIssues {
  echo "Switching on issues for username <$username> using access token <$accessToken> using <https://api.github.com/repos/$username/$repo>"

  json='{ "name": "'$repo'", "has_issues": "true" }'

  echo "Creating an issue for username <$username> using access token <$accessToken> using <https://api.github.com/repos/$username/$repo/issues>"

  json='{ "title": "example" }'

  curl -u $username:$accessToken -iL -X POST -d "$json" -H 'Content-Type: application/json' "https://api.github.com/repos/$username/$repo/issues"
}

#addLabels
addMilestones
