FROM quay.io/projectquay/golang:1.24 AS builder

WORKDIR /go/src/app
COPY . .

ARG TARGETOS=linux
ARG TARGETARCH=amd64

RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -o bin/app .

FROM scratch

WORKDIR /
COPY --from=builder /go/src/app/bin/app /app
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/app"]
