-module(santa_challenge_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Procs = [
        {sc_make_q, {sc_buffered_q, start_link, [sc_make_q, infinity]}, permanent, 5000, worker, [sc_buffered_q]},
        {sc_wrap_q, {sc_buffered_q, start_link, [sc_wrap_q, 1000]}, permanent, 5000, worker, [sc_buffered_q]},
        {sc_load_q, {sc_buffered_q, start_link, [sc_load_q, 2000]}, permanent, 5000, worker, [sc_buffered_q]},
        {sc_deliver_q, {sc_buffered_q, start_link, [sc_deliver_q, 5000]}, permanent, 5000, worker, [sc_buffered_q]},
        {sc_the_list, {sc_the_list, start_link, []}, permanent, 5000, worker, [sc_the_list]},
        {sc_making_elf, {sc_making_elf, start_link, []}, permanent, 5000, worker, [sc_making_elf]},
        {sc_wrapping_elf, {sc_wrapping_elf, start_link, []}, permanent, 5000, worker, [sc_wrapping_elf]},
        {sc_loading_elf, {sc_loading_elf, start_link, []}, permanent, 5000, worker, [sc_loading_elf]}
    ],
    {ok, {{one_for_one, 1, 5}, Procs}}.
