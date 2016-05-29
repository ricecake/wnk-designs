%%%-------------------------------------------------------------------
%% @doc wnkd_web public API
%% @end
%%%-------------------------------------------------------------------

-module(wnkd_web_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	case wnkd_web_sup:start_link() of
		{ok, Pid} ->
			Dispatch = cowboy_router:compile([
				{'_', [
					% Static File route
					{"/static/[...]", cowboy_static, {priv_dir, wnkd_web, "static/"}},
					% Dynamic Pages
					{"/", wnkd_web_index, #{}},
					{"/administration", wnkd_web_page, admin},
					{"/api/item/:action", wnkd_web_item, []}
				]}
			]),
			{ok, _} = cowboy:start_http(wnkd_web, 25, [{ip, {127,0,0,1}}, {port, 8686}],
							[{env, [{dispatch, Dispatch}]}]),
			{ok, Pid}
	end.

%%--------------------------------------------------------------------

stop(_State) ->
	ok.

%%====================================================================
%% Internal functions
%%====================================================================
