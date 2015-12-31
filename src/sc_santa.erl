-module(sc_santa).
-behaviour(gen_server).

-export([start_link/1]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-define(SLEIGH_CAPACITY, 5000).

start_link(TotalPresents) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [TotalPresents], []).

init([TotalPresents]) ->
    lager:info("Ho ho ho! ~p", [TotalPresents]),
    {ok, #{loaded_presents=>0, delivered_presents=>0, total_presents=>TotalPresents}}.

handle_call(load_present, _From, State = #{loaded_presents:=LoadedPresents, delivered_presents:=DeliveredPresents, total_presents:=TotalPresents}) ->
    UpdatedPresents = LoadedPresents + 1,
    case UpdatedPresents =:= ?SLEIGH_CAPACITY of
        true ->
            UpdatedPresentCount = DeliveredPresents + ?SLEIGH_CAPACITY,
            lager:info("Making delivery. Total delivered presents: ~p", [UpdatedPresentCount]),
            timer:sleep(500),
            case UpdatedPresentCount >= TotalPresents of
                true ->
                    ok = gen_server:call(sc_elf_pool, close);
                _ ->
                    ok
            end,
            {reply, ok, State#{loaded_presents:=0, delivered_presents:=UpdatedPresentCount}};
        _ ->
            {reply, ok, State#{loaded_presents:=UpdatedPresents}}
    end;

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
