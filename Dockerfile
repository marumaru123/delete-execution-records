FROM haskell:8.8.3

WORKDIR /work

COPY stack.yaml delete-execution-records.cabal /work/
RUN stack build --only-dependencies

COPY . /work/
RUN stack build && stack install

CMD delete-execution-records-exe -p $PORT