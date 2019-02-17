.PHONY: all test compile run docker

all: deps run

deps:
	mix deps.get

run:
	iex -S mix

test:
	mix test

docker: deps
	MIX_ENV=prod mix do compile, run
