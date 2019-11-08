FROM golang:1.12-alpine as builder

WORKDIR /go/app

ENV CGO_LDFLAGS_ALLOW='-I/usr/include/librsvg-2.0|-I/usr/include/glib-2.0|-I/usr/lib/glib-2.0/include|-I/usr/lib/libffi-3.2.1/include|-I/usr/include/libmount|-I/usr/include/blkid|-I/usr/include/gdk-pixbuf-2.0|-I/usr/include/cairo|-I/usr/include/pixman-1|-I/usr/include/freetype2|-I/usr/include/libpng16|-I/usr/include/harfbuzz|-I/usr/include/uuid'
ENV CGO_CFLAGS_ALLOW='-lrsvg-2|-lm|-lgio-2.0|-lgdk_pixbuf-2.0|-lgobject-2.0|-lglib-2.0|-lz|-lcairo'
ENV CGO_ENABLED=0
ENV GO111MODULE=on

RUN apk add --no-cache git \
    librsvg-dev \
    cairo-dev \
    pkgconfig

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .

RUN apk add --no-cache \
    && go get gopkg.in/urfave/cli.v2@master \
    && go get github.com/oxequa/realize \
    && go build -o app

FROM alpine

WORKDIR /app

ENV CGO_LDFLAGS_ALLOW='-I/usr/include/librsvg-2.0|-I/usr/include/glib-2.0|-I/usr/lib/glib-2.0/include|-I/usr/lib/libffi-3.2.1/include|-I/usr/include/libmount|-I/usr/include/blkid|-I/usr/include/gdk-pixbuf-2.0|-I/usr/include/cairo|-I/usr/include/pixman-1|-I/usr/include/freetype2|-I/usr/include/libpng16|-I/usr/include/harfbuzz|-I/usr/include/uuid'
ENV CGO_CFLAGS_ALLOW='-lrsvg-2|-lm|-lgio-2.0|-lgdk_pixbuf-2.0|-lgobject-2.0|-lglib-2.0|-lz|-lcairo'
ENV CGO_ENABLED=0

RUN apk add --no-cache \
    librsvg-dev \
    cairo-dev \
    pkgconfig

COPY --from=builder /go/app/app .
COPY --from=builder /go/app/templates/test2.svg templates/

RUN addgroup go \
    && adduser -D -G go go \
    && chown -R go:go /app/app

CMD ["./app"]