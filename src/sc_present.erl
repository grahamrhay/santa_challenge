-module(sc_present).

-export([make/0]).

make() ->
    lager:info("Making present"),
    timer:sleep(50).
