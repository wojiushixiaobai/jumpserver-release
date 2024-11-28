#!/usr/bin/env bash
#

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION="$1"

checkout() (
    set -ex
    REPO="$1"
    TAG="$2"
    SRC="$3"

    git clone --depth 1 --branch "$TAG" "http://github.com/$REPO" "$SRC"
)

REPOS="jumpserver/jumpserver jumpserver/koko jumpserver/lion jumpserver/chen jumpserver/lina jumpserver/luna"

for REPO in $REPOS; do
    case "$REPO" in
        "jumpserver/jumpserver")
            SRC="core"
            ;;
        *)
            SRC=$(basename "$REPO")
            ;;
    esac
    checkout "$REPO" "$VERSION" "$SRC"
    pushd "$SRC"
    GHSHA=$(git rev-parse HEAD)
    echo "$GHSHA" > GHSHA
    rm -rf .git .github
    case "$REPO" in
        "jumpserver/jumpserver")
            sed -i "s@VERSION = .*@VERSION = '${VERSION}'@g" apps/jumpserver/const.py
            ;;
        "jumpserver/koko")
            sed -i "s@VERSION ?=.*@VERSION := ${VERSION}@g" Makefile
            sed -i "s@COMMIT := .*@COMMIT := ${GHSHA}@g" Makefile
            ;;
        "jumpserver/lion")
            sed -i "s@VERSION ?=.*@VERSION := ${VERSION}@g" Makefile
            sed -i "s@COMMIT := .*@COMMIT := ${GHSHA}@g" Makefile
            ;;
        "jumpserver/lina")
            sed -i "s@version-dev@${VERSION}@g" src/layout/components/NavHeader/About.vue
            ;;
        "jumpserver/luna")
            sed -i "s@version =.*;@version = '${VERSION}';@g" src/environments/environment.prod.ts
            ;;
    esac
    popd
done