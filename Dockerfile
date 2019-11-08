FROM golang:1.13-alpine

RUN apk add --no-cache ca-certificates

ENV \
  GO111MODULE=on \
  CGO_ENABLED=0 \
  GOOS=linux \
  GOARCH=amd64

WORKDIR /go/src/github.com/nshttpd/mikrotik-exporter
ADD go.mod go.sum /go/src/github.com/nshttpd/mikrotik-exporter/
RUN go mod download

ADD . .

RUN \
  go build -v -installsuffix cgo -ldflags="-w -s" -o /go/bin/mikrotik-exporter .


FROM alpine:3.10

RUN apk add --no-cache ca-certificates
COPY --from=0 /go/bin /go/bin

USER nobody
# ENTRYPOINT ["/go/bin/universal-exporter"]
EXPOSE 8090
ENV PATH='/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
CMD /go/bin/mikrotik-exporter
