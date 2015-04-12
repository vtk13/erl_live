-module(live_games).

-behaviour(gen_server).

%% API
-export([start_link/0, start/0, kill/0, create/1, count/0, finish/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {games}).
-record(game, {ref, players}).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

start() ->
  gen_server:start({local, ?MODULE}, ?MODULE, [], []).

kill() ->
  exit(whereis(?MODULE), kill).

create(Ref) ->
  gen_server:call(?MODULE, {create, Ref}).

count() ->
  gen_server:call(?MODULE, count).

finish(Ref) ->
  gen_server:call(?MODULE, {finish, Ref}).


init([]) ->
  {ok, #state{
    %% game_list stores 'game' records sor key 'ref' will be the second element in a tuple.
    games = ets:new(?MODULE, [{keypos, 2}])
  }}.

handle_call({create, Ref}, From, State) ->
  case ets:lookup(State#state.games, Ref) of
    [] ->
      true = ets:insert(State#state.games, #game{ref = Ref, players = [From]}),
      {reply, ok, State};
    [_Game] ->
      {reply, {error, already_created}, State}
  end;
handle_call(count, _From, State) ->
  {reply, ets:info(State#state.games, size), State};
handle_call({finish, Ref}, _From, State) ->
  case ets:lookup(State#state.games, Ref) of
    [] ->
      {reply, {error, not_found}, State};
    [_Game] ->
      true = ets:delete(State#state.games, Ref),
      %% TODO notify all players
      {reply, ok, State}
  end;
handle_call(_Request, _From, State) ->
  {reply, {error, invalid_request}, State}.

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
