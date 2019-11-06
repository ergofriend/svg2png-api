FROM golang:1.12-alpine as build

WORKDIR /go/app

COPY . .

RUN apk add --no-cache git \
    && go build -o app

FROM alpine

WORKDIR /app

COPY --from=build /go/app/app .
COPY --from=build /go/app/templates/test2.svg templates/

RUN addgroup go \
    && adduser -D -G go go \
    && chown -R go:go /app/app

CMD ["./app"]