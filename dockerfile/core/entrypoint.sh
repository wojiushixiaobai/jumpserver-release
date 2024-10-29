#!/bin/bash
#

function cleanup() {
    local pids
    pids=$(jobs -p)
    if [ -n "$pids" ]; then
        kill "$pids" >/dev/null 2>&1
    fi
}

if [ -n "${DB_HOST}" ] && [ -n "${DB_PORT}" ]; then
    until check tcp://${DB_HOST}:${DB_PORT}; do
        echo "wait for jms_mysql ${DB_HOST} ready"
        sleep 2s
    done
fi

if [ -n "${REDIS_HOST}" ] && [ -n "${REDIS_PORT}" ]; then
    until check tcp://${REDIS_HOST}:${REDIS_PORT}; do
        echo "wait for jms_redis ${REDIS_HOST} ready"
        sleep 2s
    done
fi

trap cleanup EXIT
rm -f /opt/jumpserver/tmp/*.pid

case "$1" in
    start|init_db|upgrade_db)
        set -- /opt/jumpserver/jms "$@"
        ;;
    *)
        exec "$@"
        ;;
esac

exec "$@"
