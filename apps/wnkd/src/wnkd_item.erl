-module(wnkd_item).

-export([
	create/1,
	list_active/0
]).

-define(THUMB_WIDTH, 320).
-define(FULL_WIDTH, 640).

-include_lib("erl_img/include/erl_img.hrl").

list_active() ->
	{ok, Cols, Rows} = pgapp:equery(wnkd, "select * from item where active = true", []),
	{ok, [populate_images(Item) || Item <- to_map(Cols, Rows)]}.

create(#{ <<"images">> := Images, <<"primary">> := PrimaryImage } = Data) ->
	{ok, ID} = insert_item(Data),
	process_images(ID, PrimaryImage, maps:to_list(Images)),
	ok.

process_images(_ID, _PrimaryImage, []) -> ok;
process_images({ID, UUID}, PrimaryImage, [{Title, #{ <<"data">> := Data }} |Rest]) ->
	{ok, Image} = erl_img:load(base64:decode(Data)),

	{ok, URL}         = application:get_env(wnkd, object_store_url),
	{ok, Bucket}      = application:get_env(wnkd, object_store_bucket),
	{ok, AccessToken} = application:get_env(wnkd, object_store_access),
	{ok, SecretKey}   = application:get_env(wnkd, object_store_secret),

	Client = mini_s3:new(AccessToken, SecretKey, URL),

	Primary = PrimaryImage =:= Title,
	{ok, FullImage} = proportionalize(?FULL_WIDTH, Image),
	{ok, 1, _, [{FullUUID}]} = pgapp:equery(wnkd,
		"insert into photo (item, featured, type, role) values ($1, $2, $3, $4) returning uuid",
		[ID, Primary, <<"png">>, <<"fullsize">>]
	),
	FullPath = binary_to_list(<<UUID/binary, $/, FullUUID/binary>>),
	mini_s3:put_object(Bucket, FullPath, [FullImage], [], [], Client),

	{ok, ThumbImage} = proportionalize(?THUMB_WIDTH, Image),
	{ok, 1, _, [{ThumbUUID}]} = pgapp:equery(wnkd,
		"insert into photo (item, featured, type, role) values ($1, $2, $3, $4) returning uuid",
		[ID, Primary, <<"png">>, <<"thumbnail">>]
	),
	ThumbPath = binary_to_list(<<UUID/binary, $/, ThumbUUID/binary>>),
	mini_s3:put_object(Bucket, ThumbPath, [ThumbImage], [], [], Client),

	io:format("~p~n", [{Title, FullUUID, ThumbUUID}]),
	process_images({ID, UUID}, PrimaryImage, Rest).


proportionalize(MaxWidth, #erl_image{width = Width} = Image) ->
	ScaleFactor = MaxWidth / Width,
	Scaled = erl_img:scale(Image, ScaleFactor),
	io:format("~p~n", [Scaled#erl_image.type]),
	erl_img:to_binary(Scaled#erl_image{type = erl_img_image_png}).

insert_item(#{<<"title">> := Name, <<"category">> := Category, <<"description">> := Description}) ->
	{ok, 1, _, [{ID, UUID}]} = pgapp:equery(wnkd,
		"insert into item (name, category, full_description) values ($1, $2, $3) returning id, uuid",
		[Name, Category, Description]
	),
	{ok, {ID, UUID}}.

populate_images(#{<<"id">> := ID} = Item) ->
	{ok, Cols, Rows} = pgapp:equery(wnkd, "select * from photo where item = $1", [ID]),
	{Primary, Secondary} = lists:partition(fun(#{<<"featured">> := F})->
		F
	end, to_map(Cols, Rows)),
	Item#{<<"primary_image">> => Primary, <<"images">> => Secondary }.

to_map(Cols, Rows) ->
	ZipFun = fun({column, N, _, _, _, _}, V) ->
		{N, V}
	end,
	[
		begin
			MatchedFields = lists:zipwith(ZipFun, Cols, tuple_to_list(Row)),
			maps:from_list(MatchedFields)
		end || Row <- Rows
	].
