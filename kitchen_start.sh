#!/usr/bin/env bash

# getScriptDir is a bash function that return the current execution script
# directory.  The script # will also follow the symlink to find out the
# correct directory.  It takes no parameters.
function getScriptDir() {
    unset CDPATH               # so this script won't be affect by CDPATH variable
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
      DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
      SOURCE="$(readlink "$SOURCE")"
      [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done
    echo "$( cd -P "$( dirname "$SOURCE" )" && pwd )"

}


SCRIPT_HOME=$(getScriptDir)
[[ ! -z $SCRIPT_HOME ]] && cd $SCRIPT_HOME

eval $(ruby get_aws_creds.rb)
[[ ! -z $OLDPWD ]] && cd -
kitchen "$@"
