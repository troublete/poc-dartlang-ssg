FROM golang:1.20-alpine AS builder
WORKDIR /srv
COPY ./srv .
RUN CGO_ENABLED=0 go build -o server ./cmd/srv/...

FROM dart:2 AS dart-builder
WORKDIR /gen
COPY ./gen .
# change the following lines, to change the input directories which are used for the page generator
COPY ./example content
COPY ./example-config config
RUN dart pub get
RUN dart --no-sound-null-safety run ssg.dart

FROM scratch
COPY --from=builder /srv/server /srv
COPY --from=dart-builder /gen/out /static
CMD ["/srv"]