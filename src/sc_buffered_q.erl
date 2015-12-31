-module(sc_buffered_q).
-behaviour(gen_server).

-export([start_link/2]).

-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

start_link(Name, Limit) ->
    gen_server:start_link({local, Name}, ?MODULE, [Name, Limit], []).

init([Name, Limit]) ->
    State = #{
        name => Name,
        limit => Limit,
        count => 0,
        wait_q => queue:new()
    },
    {ok, State}.

handle_call(add, From, State = #{count:=Count, name:=Name, limit:=Limit, wait_q:=WaitQ}) ->
    UpdatedCount = Count + 1,
    case UpdatedCount > Limit of
        false ->
            lager:info("~p: added item to q (~p)", [Name, UpdatedCount]),
            {reply, ok, State#{count => UpdatedCount}};
        _ ->
            lager:info("~p: limit breached", [Name]),
            {noreply, State#{wait_q => queue:in(From, WaitQ)}}
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
