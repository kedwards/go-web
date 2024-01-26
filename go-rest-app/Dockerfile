FROM golang:alpine AS build

ARG VERSION=0.0.0

RUN apk --no-cache add gcc g++ make git

WORKDIR /go/src/app

COPY . .

RUN go mod tidy

RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "-X main.version=${VERSION}" -o bin/main cmd/web/*.go

FROM alpine

RUN apk --no-cache add ca-certificates & rm -rf /var/cache/apk/*

WORKDIR /root

COPY --from=build /go/src/app .

EXPOSE 80

CMD ["./bin/main"]
