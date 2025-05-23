FROM quay.io/projectquay/golang:1.24 AS builder

WORKDIR /go/src/app
COPY . .

ARG TARGETOS
ARG TARGETARCH
ARG BINARY=app

RUN make build TARGETOS=${TARGETOS} TARGETARCH=${TARGETARCH} BINARY=${BINARY}


FROM scratch

ARG BINARY=app
WORKDIR /
COPY --from=builder /go/src/app/${BINARY} /${BINARY}
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/app"]
