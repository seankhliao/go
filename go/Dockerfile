# syntax=docker/dockerfile:1
FROM golang:alpine AS build
ENV CGO_ENABLED=0
ENV GOFLAGS="-trimpath"
ENV GOBIN=/usr/local/bin
RUN apk add --no-cache bash curl gcc git musl-dev
RUN go install golang.org/dl/gotip@latest
RUN gotip download
RUN rm -rf /root/sdk/gotip/pkg/linux_*
RUN curl -Lo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/builds/latest/skaffold-linux-amd64
RUN gotip install -ldflags='-s -w' github.com/google/ko@latest
RUN gotip install -ldflags='-s -w' honnef.co/go/tools/cmd/staticcheck@latest
RUN chmod +x /usr/local/bin/skaffold

FROM alpine
LABEL org.opencontainers.image.source https://github.com/seankhliao/go
RUN apk add --no-cache git # buildvcs
ENV CGO_ENABLED=0
ENV GOFLAGS='-trimpath "-ldflags=-s -w"'
ENV PATH=/root/sdk/gotip/bin:/root/go/bin:$PATH
COPY --from=build /usr/local/bin/skaffold /usr/local/bin/skaffold
COPY --from=build /usr/local/bin/ko /usr/local/bin/ko
COPY --from=build /usr/local/bin/staticcheck /usr/local/bin/staticcheck
COPY --from=build /root/sdk/gotip /root/sdk/gotip
WORKDIR /workspace
RUN go build std
ENTRYPOINT [ "go" ]
