-module(sc_the_list).
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
    gen_server:cast(self(), start),
    {ok, #{}}.

handle_call(_Request, _From, State) ->
    {reply, ignored, State}.

handle_cast(start, State) ->
    lager:info("Who's been naughty, and who's been nice?"),
    TotalPresents = 5000,
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
