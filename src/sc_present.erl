-module(sc_present).

-export([make/0]).
-export([wrap/0]).

make() ->
    lager:info("Making present"),
    timer:sleep(50).

wrap() ->
    lager:info("Wrapping present"),
    timer:sleep(10).
