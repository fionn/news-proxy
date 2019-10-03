#!/bin/bash

set -eEo pipefail

[ -z "$PORT" ] && readonly PORT=1234

set -u

function log {
    echo -e "$1" >&2
}

function handler {
    local line
    while read -r line; do
        line=$(tr -d "\r\n" <<< "$line")
        log "> \e[2m$line\e[0m"
        if grep -qE "^GET /" <<< "$line"; then
            request=$(cut -d " " -f 2 <<< "$line")
        elif [ -z "$line" ]; then
            proxy_request "$request"
            break
        fi
    done
}

function proxy_request {
    local request="https://$DESTINATION_HOST""$1"

    log "Proxying request for $request"
    out=$(curl -sSie "$REFERRER" "$request")

    status=$(http_status <<< "$out")
    log "Received HTTP $status"

    if [ "$status" != "200" ]; then
        echo -e "HTTP/1.1 502 Bad Gateway\r\n\r\n"
        return 1
    fi

    sed "1 s/^HTTP\/2.*$/HTTP\/1\.1 200 OK/" <<< "$out"
}

function http_status {
    line="$(head -n 1)"
    grep "HTTP" <<< "$line" > /dev/null
    cut -d " " -f 2 <<< "$line"
}

function listen {
    local pipe
    pipe="$(umask 077 && mktemp -d)/$RANDOM-$RANDOM-$RANDOM.fifo"
    umask 077 && mkfifo "$pipe"

    trap '[ -p $pipe ] && rm $pipe' EXIT

    while true; do
        # shellcheck disable=SC2094 # exception for named pipes
        handler < "$pipe" | nc -vl 0.0.0.0 "$PORT" > "$pipe"
    done
}

function main {
    while true; do
        listen || continue
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
