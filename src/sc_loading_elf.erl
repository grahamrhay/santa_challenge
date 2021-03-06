-module(sc_loading_elf).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    lager:info("Started loading presents"),
    ok = gen_server:call(sc_elf_pool, request_elf),
    gen_server:cast(self(), load_present),
    {ok, #{}}.

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(load_present, State) ->
    ok = gen_server:call(sc_load_q, get, infinity),
    sc_present:load(),
    ok = gen_server:call(sc_santa, load_present),
    gen_server:cast(self(), load_present),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
