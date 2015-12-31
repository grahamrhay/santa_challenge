-module(sc_wrapping_elf_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Procs = [{sc_wrapping_elf, {sc_wrapping_elf, start_link, []}, permanent, 5000, worker, [sc_wrapping_elf]}],
    {ok, {{simple_one_for_one, 5, 10}, Procs}}.
