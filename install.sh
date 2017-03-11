#!/bin/bash

# usage: install.sh ben-biddington {api key}

username=$1
repo="onboarding_me" #@todo: allow this to vary?
accessToken=$2
usage="./install.sh {github username} {gihub access token}"

if [ ! -z $DEBUG ]; then
   curlVerbosity="-i"
else
   curlVerbosity="-s"
fi

function yellow { # https://gist.github.com/chrisopedia/8754917
    echo -e "\e[33m$@\e[0m"
}

function green {
    echo -e "\e[32m$@\e[0m"
}

function red {
    echo -e "\e[31m$@\e[0m"
}

function debug {
    if [ ! -z $DEBUG ]; then
        yellow "[DEBUG] $1"
    fi
}

function tabify {
    echo "$1" | while read line ; do
        red "\t$line"
    done
}

function post {
    path=$1
    body=$2
    url=https://api.github.com/repos/$username/$repo$path

    debug "POST $url with body <$body>"

    local redirectTo='/dev/null'
  
    if [ ! -z $DEBUG ]; then
        redirectTo='/dev/stdout'
    fi  
  
    curl -u $username:$accessToken $curlVerbosity -L -X POST -d "$body" -H 'Content-Type: application/json' $url &> redirectTo
}

function patch {
    path=$1
    body=$2
  
    url=https://api.github.com/repos/$username/$repo$path

    debug "PATCH $url with payload $body"

    local redirectTo='/dev/null'
    
    if [ ! -z $DEBUG ]; then
        redirectTo='/dev/stdout'
    fi  
  
    curl -u $username:$accessToken $curlVerbosity -L -X PATCH -d "$body" -H 'Content-Type: application/json' $url &> $redirectTo
}


function _delete {
  path=$1

  url=https://api.github.com/repos/$username/$repo$path

  debug "DELETE $url with verbosity <$curlVerbosity>"

  curl -u $username:$accessToken $curlVerbosity -X DELETE "$url"
}

function addLabels {
  echo "Creating labels"

  _delete '/labels/1%20Easy'
  _delete '/labels/2%20Medium'
  _delete '/labels/3%20Hard'

  post "/labels" '{ "name": "1 Easy", "color" : "00ff00" }'
  post "/labels" '{ "name": "2 Medium" }'
  post "/labels" '{ "name": "3 Hard", "color" : "ff0000" }'
}

# todo: add emoji
function addMilestones {
    echo "Creating milestones"

    _delete '/milestones/1'
    _delete '/milestones/2'
    _delete '/milestones/3'

    while read milestone
    do
        post '/milestones' "$milestone"
    done < ./data/milestones
}

function enableIssues {
    local url=https://api.github.com/repos/$username/$repo

    echo "Switching on issues"
    
    debug "Switching on issues for username <$username> using access token <$accessToken> and <$url>"

    patch '' '{"name": "'$repo'", "has_issues": true}'
}

function addIssues {
    local url=https://api.github.com/repos/$username/$repo/issues
  
    echo "Creating an example issue"

    post '/issues' $json '{ "title": "example" }'
}

function demandConnection {
    local url="https://api.github.com"
    local reply="`curl -u $username:$accessToken -iLs -H 'Content-Type: application/json' "$url"`"
    local replyStatus="`echo "$reply" | head -n 1`"

    if [[ ! $replyStatus == *"200 OK"* ]]; then
        echo ""
        red "Failed to authenticate with github api at <$url> using access token <$accessToken>. The status returned was:\n\n"
        tabify "$replyStatus"
        echo -e '\n'
        red "Full reply:\n\n"
        tabify "$reply"
        echo -e "\nCheck you have supplied your github access token as command line parameter."
        echo -e "\nUsage:\n"
        green "\t$usage"
        echo -e "\nFind your personal access token at <https://github.com/settings/tokens>"
        exit 1
    fi
}

demandConnection
addLabels
addMilestones
enableIssues; addIssues
