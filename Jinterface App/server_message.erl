-module(server_message).
-import(io, [format/1, format/2]).
-import(string, [concat/2]).
-export([start/0, loop/0, stop/0]).
     
loop() ->
    receive
        stop ->
            format("Program stopped...~n",[]),
			loop();
		stop_server ->
			format("Server stopped");
        {Id,Text} ->
            format("Received~n",[]),
			Output = concat(concat(Text, "\n"), "Message received!"),
            Id ! {self(), Output},
            loop()
    end.
 
start() ->
    register(mess,spawn(server_message,loop,[])).
		
stop() ->
	mess ! stop_server,
	ok.