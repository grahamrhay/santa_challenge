-module(sc_present).

-export([make/0]).
-export([wrap/0]).
-export([load/0]).

make() ->
    timer:sleep(50).

wrap() ->
    timer:sleep(10).

load() ->
    timer:sleep(5).
