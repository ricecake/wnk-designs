-module(wnkd_item).

-export([
	create/1
]).

-define(THUMB_WIDTH, 320).
-define(FULL_WIDTH, 640).

-include_lib("erl_img/include/erl_img.hrl").

create(#{ <<"images">> := Images }) ->
	process_images(maps:to_list(Images)),
	ok.

process_images([]) -> ok;
process_images([{Title, #{ <<"type">> := Type, <<"data">> := Data }} |Rest]) ->
	{ok, Image} = erl_img:load(base64:decode(Data)),
	io:format("~p~n", [{Title, Type, Image#erl_image.width, Image#erl_image.height}]),
	process_images(Rest).

