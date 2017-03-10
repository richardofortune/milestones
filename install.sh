#!/bin/bash

# usage: install.sh ben-biddington repo-name {api key}

username=$1
repo="onboarding_me"
accessToken=$2
usage="./install.sh {github username} {repository name} {access token}"

function yellow {
    echo -e "\e[33m$@\e[0m"
}

function debug {
    if [ ! -z $DEBUG ]; then
        yellow "[DEBUG] $1"
    fi
}

function curlVerbosity {
  if [ ! -z $DEBUG ]; then
    -i
  else
    -s
  fi
}

function post {
  path=$1
  body=$2
  url=https://api.github.com/repos/$username/$repo$path

  debug "POST $url"

  curl -u $username:$accessToken $curlVerbosity -L -X POST -d "$body" -H 'Content-Type: application/json' "$url"
}

function _delete {
  path=$1

  url=https://api.github.com/repos/$username/$repo$path

  debug "DELETE $url"

  curl -u $username:$accessToken -X DELETE "$url"
}

function addLabels {
  echo "Creating labels"

  _delete '/labels/1%20Easy'
  _delete '/labels/2%20Medium'
  _delete '/labels/3%20Hard'

  curl -u $username:$accessToken -iL -X POST -d '{ "name": "1 Easy", "color" : "00ff00" }' -H 'Content-Type: application/json' "https://api.github.com/repos/$username/$repo/labels"
  curl -u $username:$accessToken -iL -X POST -d '{ "name": "2 Medium" }' -H 'Content-Type: application/json' "https://api.github.com/repos/$username/$repo/labels"
  curl -u $username:$accessToken -iL -X POST -d '{ "name": "3 Hard", "color" : "ff0000" }' -H 'Content-Type: application/json' "https://api.github.com/repos/$username/$repo/labels"
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

function demandConnection {
    local url="https://api.github.com"
    local reply="`curl -u $username:$accessToken -iLs -H 'Content-Type: application/json' "$url"`"
    local replyStatus="`echo "$reply" | head -n 1`"

    if [[ ! $replyStatus == *"200 OK"* ]]; then
        echo ""
        echo -e 'Failed to authenticate with github api. The status returned was:\n\n'
        echo "$replyStatus"
        echo -e '\n'
        echo -e "Full reply:\n\n$reply\n\n"
        echo "Check you have supplied your github access token as command line parameters. Find your personal acces token at https://github.com/settings/tokens"
        echo -e "\nUsage: $usage"
        exit 1
    fi
}

demandConnection
addLabels
addMilestones
addIssues
