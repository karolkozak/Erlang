-module(onp).
-export([onp/1]).


read(N) ->
 case string:to_float(N) of
	{error,no_float} -> list_to_integer(N);
	{F,_} -> F
	end.


onp(L) ->
	onp([], string:tokens(L, " ")).
onp([H], []) ->
	H;
onp([A, B|Stack], ["+"|List]) ->
	onp([B + A | Stack], List);
onp([A, B|Stack], ["-"|List]) ->
	onp([B - A | Stack], List);
onp([A, B|Stack], ["*"|List]) ->
	onp([B * A | Stack], List);
onp([A, B|Stack], ["/"|List]) ->
	onp([B / A | Stack], List);
onp([A, B|Stack], ["^"|List]) ->
	onp([math:pow(B,A) | Stack], List);
onp([A|Stack], ["sq"|List]) ->
	onp([math:sqrt(A) | Stack], List);
onp(Stack, [H|List]) ->
	onp([read(H)|Stack],List).