#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Preparing to build and push images..."
echo "Travis Branch : ${TRAVIS_BRANCH}"
echo "Travis Tag    : ${TRAVIS_TAG}"
echo "Travis Commit : ${TRAVIS_COMMIT}"

# Log in to gcr.io using a key file for the Travis CI service account. The key
# file is NOT stored plaintext and is decrypted by Travis CI before this script
# is run.
echo "Logging into gcr.io..."
docker login -u _json_key --password-stdin https://gcr.io < "${DIR}/spire-travis-ci.json"

# Tag and push latest build by Git hash
docker tag spiffe-helper gcr.io/spiffe-io/spiffe-helper:"${TRAVIS_COMMIT}"
docker push gcr.io/spiffe-io/spiffe-helper:"${TRAVIS_COMMIT}"

if [ -n "${TRAVIS_TAG}" ]; then
	# This is a tagged build. Tag and push under the git tag.
	docker tag spiffe-helper gcr.io/spiffe-io/spiffe-helper:"${TRAVIS_TAG}"
	docker push gcr.io/spiffe-io/spiffe-helper:"${TRAVIS_TAG}"
elif [ x"${TRAVIS_BRANCH}" = x"master" ]; then
	# This is an untagged build for master. Tag and push as unstable
	docker tag spiffe-helper gcr.io/spiffe-io/spiffe-helper:unstable
	docker push gcr.io/spiffe-io/spiffe-helper:unstable
fi
