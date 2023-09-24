-module(master).
-export([start/0]).
-export([server_connect/2]).
-import(string,[substr/3, right/3, concat/2]).

server_connect(_, 15) ->
    ok;
server_connect(No_of_zeroes, No_of_coins) ->
    receive
        { Sender_1 }-> 
            Sender_1 ! { No_of_zeroes },
            io:fwrite("Connection esablished with ~p\n", [Sender_1]),
            server_connect(No_of_zeroes, No_of_coins);

        { Coin, Hashstring, Sender_id_2} ->
            io:fwrite(" ~p Mined coin ~p ~p from server ~p\n", [No_of_coins+1, Hashstring, Coin, Sender_id_2]),
            server_connect(No_of_zeroes, No_of_coins+1)
    end.

start() ->
    {ok, No_of_zeroes} = io:read("Enter Number of required preceeding zeroes:  "),
    {ok, Servercount} = io:read("Enter total server models to be spawned: "),
    spawn_nodes(self(), No_of_zeroes, Servercount),
    register(master, self()),
    statistics(runtime),
    {Time, _} = timer:tc(master, server_connect, [No_of_zeroes, 0]),
    {_, Time_CPU_Since_Last_Call} = statistics(runtime),
    io:fwrite("Total clock time: ~p\nTotal CPU time ~p\nRatio of CPU time to Run Time ~p\n", [Time/1000, Time_CPU_Since_Last_Call, Time_CPU_Since_Last_Call/(Time/1000)]),
    unregister(master).

spawn_nodes(_, _, 0) ->
    ok;
spawn_nodes(Pid, No_of_zeroes, Servercount) ->
    spawn(fun() -> bc_mining(Pid, No_of_zeroes) end),
    spawn_nodes(Pid, No_of_zeroes, Servercount-1).
bc_mining(Pid, No_of_zeroes) -> 
    Ufid = "ThilakReddyDaggula : ",
    Bc = base64:encode_to_string(crypto:strong_rand_bytes(8)),
    Uf_Bc = concat(Ufid, Bc),
    Hash = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256, Uf_Bc))]),
    String_1 = right("", No_of_zeroes, $0),
    Max_Zero = right("", No_of_zeroes+1, $0),
    Sub_string = substr(Hash, 1, No_of_zeroes),
    Maxsubstring = substr(Hash, 1, No_of_zeroes+1),
    if
        (String_1 == Sub_string) and (Max_Zero =/= Maxsubstring)->
            Pid ! {Hash, Uf_Bc, self()};
    true ->
        ok
    end,
    bc_mining(Pid, No_of_zeroes).
