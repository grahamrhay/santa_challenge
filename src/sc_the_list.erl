-module(sc_the_list).
-behaviour(gen_server).

-export([start_link/1]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-define(MAKING_ELVES, 5).
-define(WRAPPING_ELVES, 2).

start_link(TotalPresents) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [TotalPresents], []).

init([TotalPresents]) ->
    gen_server:cast(self(), start),
    lists:foreach(fun(_) -> {ok, _Pid} = supervisor:start_child(sc_making_elf_sup, []) end, lists:seq(1, ?MAKING_ELVES)),
    lists:foreach(fun(_) -> {ok, _Pid} = supervisor:start_child(sc_wrapping_elf_sup, []) end, lists:seq(1, ?WRAPPING_ELVES)),
    {ok, #{total_presents=>TotalPresents}}.

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(start, State=#{total_presents:=TotalPresents}) ->
    lager:info("Who's been naughty, and who's been nice?"),
    lists:foreach(fun(_) -> gen_server:call(sc_make_q, add, infinity) end, lists:seq(1, TotalPresents)),
    {noreply, State};

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
