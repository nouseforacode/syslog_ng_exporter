FROM alpine:3.10.0 AS builder

RUN apk add --update go curl make git musl-dev
ENV GOPATH /go
ENV SRC_PATH /go/src/github.com/brandond/syslog_ng_exporter
ENV COMMIT 2f65768013466d88f86451df6e8cc5a74849c626

RUN mkdir -p "${SRC_PATH%/syslog_ng_exporter}" \
    && curl -sL "https://github.com/brandond/syslog_ng_exporter/archive/${COMMIT}.tar.gz" > /tmp/syslog_ng_exporter.tar.gz \
    && tar -C "${SRC_PATH%/syslog_ng_exporter}" -zxf /tmp/syslog_ng_exporter.tar.gz \
    && mv "${SRC_PATH%/syslog_ng_exporter}/syslog_ng_exporter-${COMMIT}" "$SRC_PATH" \
    && rm -f /tmp/syslog_ng_exporter.tar.gz

RUN PATH="$PATH:$GOPATH/bin" make -C "$SRC_PATH"

FROM alpine:3.10.0
COPY --from=builder /go/src/github.com/brandond/syslog_ng_exporter/syslog_ng_exporter /usr/bin/syslog_ng_exporter
EXPOSE 9577
CMD ["/usr/bin/syslog_ng_exporter"]
