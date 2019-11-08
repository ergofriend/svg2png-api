FROM golang:1.12-alpine as builder

WORKDIR /go/app

ENV CGO_LDFLAGS_ALLOW='-I/usr/include/librsvg-2.0|-I/usr/include/glib-2.0|-I/usr/lib/glib-2.0/include|-I/usr/lib/libffi-3.2.1/include|-I/usr/include/libmount|-I/usr/include/blkid|-I/usr/include/gdk-pixbuf-2.0|-I/usr/include/cairo|-I/usr/include/pixman-1|-I/usr/include/freetype2|-I/usr/include/libpng16|-I/usr/include/harfbuzz|-I/usr/include/uuid'
ENV CGO_CFLAGS_ALLOW='-lrsvg-2|-lm|-lgio-2.0|-lgdk_pixbuf-2.0|-lgobject-2.0|-lglib-2.0|-lz|-lcairo'
ENV CGO_ENABLED=1
ENV GO111MODULE=on
ENV GOOS="linux"
ENV GOARCH="amd64"

RUN apk add --no-cache git \
    gcc \
    musl-dev \
    librsvg-dev \
    cairo-dev \
    pkgconfig

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY main.go .
COPY templates/test2.svg templates/

RUN apk add --no-cache \
    && go build -o app

RUN apk add --no-cache \
    && go get gopkg.in/urfave/cli.v2@master \
    && go get github.com/oxequa/realize

FROM alpine

WORKDIR /app

ENV CGO_LDFLAGS_ALLOW='-I/usr/include/librsvg-2.0|-I/usr/include/glib-2.0|-I/usr/lib/glib-2.0/include|-I/usr/lib/libffi-3.2.1/include|-I/usr/include/libmount|-I/usr/include/blkid|-I/usr/include/gdk-pixbuf-2.0|-I/usr/include/cairo|-I/usr/include/pixman-1|-I/usr/include/freetype2|-I/usr/include/libpng16|-I/usr/include/harfbuzz|-I/usr/include/uuid'
ENV CGO_CFLAGS_ALLOW='-lrsvg-2|-lm|-lgio-2.0|-lgdk_pixbuf-2.0|-lgobject-2.0|-lglib-2.0|-lz|-lcairo'
ENV CGO_ENABLED=0

RUN apk add --no-cache \
    librsvg-dev \
    cairo-dev \
    pkgconfig

# 日本語
RUN apk update \
    && apk add --no-cache curl fontconfig \
    && curl -O https://noto-website.storage.googleapis.com/pkgs/NotoSansCJKjp-hinted.zip \
    && mkdir -p /usr/share/fonts/NotoSansCJKjp \
    && unzip NotoSansCJKjp-hinted.zip -d /usr/share/fonts/NotoSansCJKjp/ \
    && chmod 644 /usr/share/fonts/NotoSansCJKjp/*.otf \
    && rm NotoSansCJKjp-hinted.zip \
    && fc-cache -fv

COPY --from=builder /go/app/app .
COPY --from=builder /go/app/templates/test2.svg templates/

RUN addgroup go \
    && adduser -D -G go go \
    && chown -R go:go /app/app

CMD ["./app"]