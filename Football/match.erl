%% @author Karol
%% @doc @todo Add description to mecz.

-module(mecz).
-import(io, [format/1, format/2]).
-import(timer, [sleep/1]).
%%-export([start/2]).
-compile(export_all).

start(Kraj,Partner) -> 
	register(Kraj, spawn(?MODULE, loop, [Partner, 0])),
	register(Partner, spawn(?MODULE, loop, [Kraj, 0])).

loop(Partner, Bramki) ->   %%mi strzelono
	receive
		link ->
			link(whereis(Partner)),
			loop(Partner, Bramki);
		stop -> 
			Partner ! wynik,
			sleep(10),
			exit(ok);
		wynik ->
			format("Kraj ~s strzeli mi: ~p bramek~n", [Partner, Bramki]),
			loop(Partner, Bramki);
		kopnij -> rand(ran, Partner),
				  loop(Partner, Bramki);
		obroniona -> format("Obronilem"),
					 self() ! kopnij,
					 loop(Partner, Bramki);
		bramka -> format("Kraj ~s strzelil gola.~n", [Partner]),
				  Tmp = Bramki+1,
				  self() ! kopnij,
				  loop(Partner, Tmp)
	end.

linkme(Kraj) ->
	Kraj ! link.

kopnij(Kraj) -> 
	Kraj ! kopnij.
  
stop(Kraj) -> 
	Kraj ! wynik,
	Kraj ! stop.

rand(R, Partner) when ((R rem 3) == 0) ->
	whereis(Partner) ! bramka;
rand(R, Partner) when ((R rem 3) /= 0) ->
	whereis(Partner) ! obroniona;
rand(ran, Partner) -> 
	R = random:uniform(1000),
	rand(R, Partner).