-module(santa_challenge_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Procs = [
        {sc_make_q, {sc_buffered_q, start_link, [sc_make_q, 10]}, permanent, 5000, worker, [sc_buffered_q]},
        {sc_the_list, {sc_the_list, start_link, []}, permanent, 5000, worker, [sc_the_list]}
    ],
    {ok, {{one_for_one, 1, 5}, Procs}}.
