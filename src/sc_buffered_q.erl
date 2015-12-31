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
    erlang:send_after(1000, self(), tick),
    State = #{
        name => Name,
        limit => Limit,
        count => 0,
        add_q => queue:new(),
        get_q => queue:new()
    },
    {ok, State}.

handle_call(add, From, State = #{count:=Count, name:=_Name, limit:=Limit, add_q:=AddQ, get_q:=GetQ}) ->
    UpdatedCount = Count + 1,
    case UpdatedCount > Limit of
        false ->
            case queue:is_empty(GetQ) of
                true ->
                    %lager:info("~p: added item (~p)", [Name, UpdatedCount]),
                    {reply, ok, State#{count => UpdatedCount}};
                _ ->
                    %lager:info("~p: unblocked waiter", [Name]),
                    {{value, Client}, UpdatedQ} = queue:out(GetQ),
                    gen_server:reply(Client, ok),
                    {reply, ok, State#{get_q => UpdatedQ}}
            end;
        _ ->
            %lager:info("~p: limit breached (~p)", [Name, Limit]),
            {noreply, State#{add_q => queue:in(From, AddQ)}}
    end;

handle_call(get, From, State = #{count:=Count, name:=_Name, add_q:=AddQ, get_q:=GetQ}) ->
    case Count > 0 of
        true ->
            case queue:is_empty(AddQ) of
                true ->
                    UpdatedCount = Count - 1,
                    %lager:info("~p: removed item from q (~p)", [Name, UpdatedCount]),
                    {reply, ok, State#{count => UpdatedCount}};
                _ ->
                    {Client, UpdatedQ} = queue:out(AddQ),
                    gen_server:reply(Client, ok),
                    %lager:info("~p: sent item to waiter", [Name]),
                    {reply, ok, State#{add_q => UpdatedQ}}
            end;
        _ ->
            %lager:info("~p: nothing in q", [Name]),
            {noreply, State#{get_q => queue:in(From, GetQ)}}
    end;

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(tick, State = #{name:=Name, count:=Count}) ->
    erlang:send_after(1000, self(), tick),
    lager:info("~p => ~p", [Name, Count]),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
