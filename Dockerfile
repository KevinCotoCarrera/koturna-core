# Multi-stage Dockerfile for Phoenix 1.8 / Elixir 1.19 / OTP 27
ARG ELIXIR_VERSION=1.19.1
ARG OTP_VERSION=27.0
ARG ALPINE_VERSION=3.20.3

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION} AS build

RUN apk add --no-cache build-base git

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod

COPY lib lib
COPY priv priv
COPY assets assets

RUN mix assets.deploy
RUN mix compile
RUN mix release

FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache openssl ncurses-libs libstdc++ libgcc

WORKDIR /app
RUN chown nobody:nobody /app

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/koturna ./

USER nobody

ENV HOME=/app
ENV PHX_SERVER=true

EXPOSE 4000

CMD ["/app/bin/server"]
