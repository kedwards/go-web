FROM golang:alpine AS deps
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

FROM deps AS builder
ARG VERSION=0.0.0
ARG PORT=8888
ARG COLOR=000000
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
  -ldflags="-s -w -X main.version=${VERSION} -X main.port=${PORT} -X main.color=${COLOR}" \
  -o /server ./cmd

FROM scratch
COPY --from=builder /server /server
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
ENTRYPOINT ["/server"]
