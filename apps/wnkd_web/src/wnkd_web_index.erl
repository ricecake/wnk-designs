-module(wnkd_web_index).

-export([init/2]).

init(Req, Args) ->
	{ok, Items} = wnkd_item:list_active(),
	PartitionedItems = category_partition(Items, #{}),
	io:format("~p~n", [PartitionedItems]),
	{ok, Body} = wnkd_web_index_dtl:render([{page, <<"index">>} |maps:to_list(PartitionedItems)]),
	Req2 = cowboy_req:reply(200, [
		{<<"content-type">>, <<"text/html">>}
	], Body, Req),
	{ok, Req2, Args}.

category_partition([], Acc) -> Acc;
category_partition([#{ <<"category">> := Category, <<"full_description">> := Desc } = Item | Rest], Acc) ->
	ThisCategory = maps:get(Category, Acc, []),
	category_partition(Rest, Acc#{ Category => [Item#{ <<"full_description">> := markdown:conv(binary_to_list(Desc)) } |ThisCategory]}).
