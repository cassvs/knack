-module(knack).
-export([join_pool/0, ack/2, ack/3]).

%%% knack.erl
%%% A worse-than-usual implementation of the Ackermann function
%%% Cass Smith, Dec 12, 2021

%% Join a worker pool. You need to run this at startup on each node
join_pool() ->
    erlang:set_cookie('foobarbaz'),         % <- Change this, I guess
    net_adm:ping('introducer_node@host').   % <- CHANGE THIS to any node's ID
%% You may need local DNS on your cluster's LAN for this to work, idk.
%% Maybe an IP address would work instead of a hostname, I haven't tried

%% Choose a random node from the pool
pick_node() ->
    Pool = nodes(),
    lists:nth(rand:uniform(length(Pool)), Pool).

%% Starts distributed job and returns result
ack(M, N) when N >=0, M >= 0, is_integer(N), is_integer(M) ->
    spawn(pick_node(), knack, ack, [self(), M, N]),
    receive
        X -> X
    end.

%% Tail recursion and distributed recursion.
ack(Parent, 0, N) ->
    Parent ! N + 1;

ack(Parent, M, 0) ->
    ack(Parent, M - 1, 1);

ack(Parent, M, N) ->
    spawn(pick_node(), knack, ack, [self(), M, N - 1]),
    %% Absolutely nothing is gained by performing this branch recursion on a
    %% different node. It only results in vastly worse performance and proves
    %% that the pooling works. This process just waits for the remote process
    %% to finish.
    receive
        X -> ack(Parent, M - 1, X)
    end.
