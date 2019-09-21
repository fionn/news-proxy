#!/bin/bash

set -eo pipefail

[ -z "$PORT" ] && readonly PORT=1234

set -u

function handler {
    local line
    while read -r line
    do
        line=$(echo "$line" | tr -d "\r\n")
        echo ">: $line" >&2
        if echo "$line" | grep -qE "^GET /"
        then
            request=$(echo "$line" | cut -d " " -f2)
        elif [ -z "$line" ]
        then
            proxy_request "$request"
            break
        fi
    done
}

function proxy_request {
    local request="$DESTINATION_HOST""$1"
    echo "Proxying request for $request" >&2
    curl --http1.1 -ie "$REFERRER" "https://$request"
}

function listen {
    local pipe
    pipe="$(umask 077 && mktemp -d)/$RANDOM-$RANDOM-$RANDOM.fifo"
    umask 077 && mkfifo "$pipe"

    trap '[ -p $pipe ] && rm $pipe' EXIT

    while true
    do
        # shellcheck disable=SC2094 # exception for named pipes
        handler < "$pipe" | nc -vl 0.0.0.0 "$PORT" > "$pipe"
    done
}

function main {
    while true
    do
        listen || continue
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    main "$@"
fi
