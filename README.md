# knack

A really really bad implementation of the Ackermann function.

Playing with distributed programming in Erlang.

## How to Run

1. Edit `knack.erl`. Change the cookie value if you want, and make sure you change the introducer_node ID to a node that actually exists (or will exist) on your cluster/network.
2. Compile: `erlc knack.erl`
3. Copy `knack.beam` into some directory on each node of your cluster.
4. On each node, run:
```
$ erl -sname SOME_NAME
> knack:join_pool().
```
(The names can all be the same, as long as the machines have different hostnames.)

5. On one of the nodes, run: `> knack:ack(2, 2)`
It should return 7 fairly quickly.

## "Cool, lemme try `ack(123, 456)`!"
Watch out! The Ackermann function is profoundly evil, and returns ludicrously huge values for even small inputs. Execution times get very long even for relatively small output values. `ack(3, 5)` takes several minutes on my setup, and only returns 61.

## "Will this melt my clusters' CPUs?"
Nope. The Ackermann function doesn't take advantage of concurrency at all: it still can only calculate one level of recursion at a time. Your clusters' CPUs will spend most of their time in blocking states, waiting for the results of deeper recursions.

## "Okay, but will it fill up all the nodes' memory?"
No again. Erlang processes are surprisingly light. I suppose if you ran the function with large enough inputs you could run out of memory, but it would take an absurdly long time.

## "\*sigh\* Will it at least flood my network with traffic?"
Also no. At any given moment, across the whole cluster, only one process is running, either spawning a new process or sending results back up to the process that spawned it. So there is at most one communication going on at once. Your network will have a lot of packets flying around, and the lights on your router will blink pleasantly, but in terms of bandwidth usage it's not much.

## "That's boring!"
Yes, it's a very slow and convoluted way of doing not much. But it's also a cool demo of distributed Erlang, a parable about when concurrency is beneficial and when it isn't, and maybe an effective method of making CS professors cry.

It was fun for me to make and test, and I leaned a bunch.
