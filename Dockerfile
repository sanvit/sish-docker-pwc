FROM alpine:3

RUN apk add --no-cache ca-certificates

COPY --from=antoniomika/sish:latest /app /app
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /app

EXPOSE 8080 2222

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
