FROM ruby:2.2 as builder

ENV RAILS_ENV production

WORKDIR /app

COPY . /app
RUN bundle install --standalone --system

FROM ruby:2.2-slim

RUN adduser docker \
  && mkdir -p /messages/sqs \
  && chown docker /messages/sqs

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app/bin /app/bin
COPY --from=builder /app/lib /app/lib

USER docker
EXPOSE 9494

# Note: We use thin, because webrick attempts to do a reverse dns lookup on every request
# which slows the service down big time.  There is a setting to override this, but sinatra
# does not allow server specific settings to be passed down.
CMD ["/usr/local/bundle/bin/fake_sqs", "--database=/messages/sqs/database.yml", "--bind", "0.0.0.0", "--port", "9494", "--server", "thin"]
