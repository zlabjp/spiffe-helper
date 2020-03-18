# Build stage
ARG goversion
FROM golang:${goversion}-alpine as builder
RUN apk add build-base git mercurial
WORKDIR /work
ADD go.mod .
RUN go mod download
ADD . /work
RUN make build

# Base
FROM alpine AS base
RUN apk --no-cache add dumb-init
RUN apk --no-cache add ca-certificates
RUN mkdir -p /opt/spiffe-helper/bin

# SPIFFE Helper
FROM base
COPY --from=builder /work/spiffe-helper /opt/spiffe-helper/bin/spiffe-helper
WORKDIR /opt/spiffe-helper
ENTRYPOINT ["/usr/bin/dumb-init", "/opt/spiffe-helper/bin/spiffe-helper"]
CMD []
