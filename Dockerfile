FROM haskell:8.8.3

RUN apt-get update
RUN apt-get upgrade -y --assume-yes
RUN apt-get install -y --assume-yes libpq-dev

WORKDIR /work

COPY stack.yaml delete-execution-records.cabal /work/
RUN stack build --only-dependencies

COPY . /work/
RUN stack build && stack install

# CMD delete-execution-records-exe -p $PORT
CMD delete-execution-records-exe
