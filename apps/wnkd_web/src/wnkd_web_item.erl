-module(wnkd_web_item).

-export([init/2]).

init(Req, []) ->
	{ok, Body, Req2} = cowboy_req:body(Req, [{length, 100000000}]),
	Request = jsx:decode(Body, [return_maps]),
	ok = wnkd_item:create(Request),
	Req3 = cowboy_req:reply(200, [
		{<<"content-type">>, <<"text/json">>}
	], jsx:encode(#{ status => ok }), Req2),
	{ok, Req3, []}.
