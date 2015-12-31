-module(sc_making_elf).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    lager:info("Started making presents"),
    ok = gen_server:call(sc_elf_pool, request_elf),
    gen_server:cast(self(), make_present),
    {ok, #{}}.

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(make_present, State) ->
    ok = gen_server:call(sc_make_q, get, infinity),
    sc_present:make(),
    ok = gen_server:call(sc_wrap_q, add, infinity),
    gen_server:cast(self(), make_present),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
