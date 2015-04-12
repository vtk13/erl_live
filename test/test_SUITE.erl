-module(test_SUITE).
-compile(export_all).

all() ->
  [test_start_stop_game].

init_per_suite(Config) ->
  live_games:start(),
  Config.

end_per_suite(Config) ->
  live_games:kill(),
  ok.


test_start_stop_game(_) ->
  Game = make_ref(),
  0 = live_games:count(),
  ok = live_games:create(Game),
  1 = live_games:count(),
  live_games:finish(Game),
  0 = live_games:count(),
  ok.
