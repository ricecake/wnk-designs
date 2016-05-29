-module(wnkd_web_index).

-export([init/2]).

init(Req, Args) ->
	{ok, Items} = wnkd_item:list_active(),
	{ok, Body} = wnkd_web_index_dtl:render([{page, <<"index">>}, {items, Items}]),
	Req2 = cowboy_req:reply(200, [
		{<<"content-type">>, <<"text/html">>}
	], Body, Req),
	{ok, Req2, Args}.
