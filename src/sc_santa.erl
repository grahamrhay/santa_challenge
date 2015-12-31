-module(sc_santa).
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
    lager:info("Ho ho ho!"),
    gen_server:cast(self(), begin_delivery),
    {ok, #{presents=>0}}.

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(begin_delivery, State = #{presents:=Presents}) ->
    ok = gen_server:call(sc_deliver_q, get, infinity),
    UpdatedPresents = Presents + 1,
    gen_server:cast(self(), begin_delivery),
    case UpdatedPresents =:= 5000 of
        true ->
            lager:info("Making delivery"),
            timer:sleep(500),
            {noreply, State#{presents:=0}};
        _ ->
            {noreply, State#{presents:=UpdatedPresents}}
    end;

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
