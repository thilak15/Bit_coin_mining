-module(server).
-import(string,[substr/3, right/3, concat/2]).
-export([start/1]).

start(Ipaddress) ->
    spawn(fun() -> connect_to_master(Ipaddress) end).


connect_to_master(Ipaddress) ->
    Master_ip = list_to_atom(concat("master", concat("@", Ipaddress))),
    {master, Master_ip} ! {self()},
    receive
        { Num_of_zeroes } -> bc_mining(Num_of_zeroes, Master_ip)
    end.
    
bc_mining(Num_of_zeroes, Master_ip) -> 
    Ufid = "ThilakreddyDaggula:",
    String = base64:encode_to_string(crypto:strong_rand_bytes(8)),
    Uf_bc = concat(Ufid, String),
    Hash = io_lib:format("~64.16.0b", [binary:decode_unsigned(crypto:hash(sha256, Uf_bc))]),
    StrZ = right("", Num_of_zeroes, $0),
    MaxZ = right("", Num_of_zeroes+1, $0),
    Sub_str = substr(Hash, 1, Num_of_zeroes),
    Maxsubstring = substr(Hash, 1, Num_of_zeroes+1),
    if
        (StrZ == Sub_str) and (MaxZ =/= Maxsubstring)->
            {master, Master_ip} ! {Hash, Uf_bc, self()};
    true ->
        io:fwrite("")
    end,
    bc_mining(Num_of_zeroes, Master_ip).
