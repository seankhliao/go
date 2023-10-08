# syntax=docker/dockerfile:1
FROM golang:alpine AS build
WORKDIR /root
ENV CGO_ENABLED=0
ENV GOFLAGS="-trimpath"
ENV GOBIN=/usr/local/bin
ENV GOEXPERIMENT=cacheprog
RUN apk add --no-cache bash curl gcc git musl-dev
RUN git clone --depth=1 --single-branch --no-tags https://go.googlesource.com/go
RUN cd go/src && ./make.bash
RUN rm -rf go/pkg/linux_*
ENV PATH=/root/go/bin:$PATH
RUN curl -Lo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/builds/latest/skaffold-linux-amd64
RUN go install -ldflags='-s -w' github.com/google/ko@latest
RUN go install -ldflags='-s -w' honnef.co/go/tools/cmd/staticcheck@latest
RUN chmod +x /usr/local/bin/skaffold

FROM alpine
LABEL org.opencontainers.image.source https://github.com/seankhliao/go
RUN apk add --no-cache git # buildvcs
ENV CGO_ENABLED=0
ENV GOFLAGS='-trimpath "-ldflags=-s -w"'
ENV PATH=/root/go/bin:$PATH
COPY --from=build /usr/local/bin/skaffold /usr/local/bin/skaffold
COPY --from=build /usr/local/bin/ko /usr/local/bin/ko
COPY --from=build /usr/local/bin/staticcheck /usr/local/bin/staticcheck
COPY --from=build /root/go /root/go
WORKDIR /workspace
RUN go build std
ENTRYPOINT [ "go" ]
