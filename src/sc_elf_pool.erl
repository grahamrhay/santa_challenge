-module(sc_elf_pool).
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
    lager:info("Started elf pool"),
    erlang:send_after(1000, self(), tick),
    {ok, #{total_elves=>0, available_elves=>0}}.

handle_call(request_elf, _From, State = #{total_elves:=TotalElves, available_elves:=0}) ->
    {reply, ok, State#{total_elves:=TotalElves + 1}};

handle_call(request_elf, _From, State = #{available_elves:=AvailableElves}) ->
    {reply, ok, State#{available_elves:=AvailableElves - 1}};

handle_call(close, _From, State = #{cookies:=Cookies}) ->
    lager:info("Delivery complete: ~p cookies spent", [Cookies]),
    {reply, ok, State#{total_elves:=0, available_elves:=0}};

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(tick, State = #{total_elves:=TotalElves, cookies:=Cookies}) ->
    erlang:send_after(1000, self(), tick),
    {noreply, State#{cookies:=Cookies + TotalElves}};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
