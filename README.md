dump_server
===========

An experiment to create a dump server to get GC information from the running rails app.

Goals:
-----
- Get ObjectSpace and Garbage Collector information about running apps.
- Minimize or eliminate probe effect.
- Make it work over unix socket.


Approaches:
-----
- Use a method inside the app (e.g. an action in controller).

  **Result:** it's the easiest approach, but probably it's the most useless, because making a request creates a lot of overhead when fetching the data. (i.e. probe effect is huge)

- Create a dump server that will run in a separate thread and would talk over unix socket.

  **Result:** the probe effect is minimal, it's the most stable and less invasive approach. (the best results so far)

- Use raw gdb to attach to the ruby process, eval ruby code, detach.

  **Result:** process hangs after detach

- Use [hijack](https://github.com/ileitch/hijack) to simplify attachment with gdb.

  **Result:** Compared to the dump server approach, it's not as stable, but the probe effect is almost the same.


Dump server
------
[Dump server](lib/dump_server.rb) implemented to talk over `/tmp/dump_server.sock` unix socket.

It's running inside a separate thread to prevent blocking of the main thread.

It uses forking technique, based on the [Faster Rails test runs...with Unix!](http://www.jstorimer.com/blogs/workingwithcode/8136295-screencast-faster-rails-test-runs-with-unix) screencast by Jesse Storimer. That technique is used to minimize the probe effects. (*Is it really needed in this case?*)

The dump server is required inside an initializer that also disables the GC. (*for testing purposes*)

You can use [demo socket client](lib/dump_client.rb) to get the `ObjectSpace.count_objects` from the running rails app.


Experiments
----------

Fetch the `ObjectSpace.count_objects` information twice to measure the **difference** between the results.
It would allow to crudely estimate the probe effect of the given approaches.
> Garbage collector is disabled

**App request:**
```ruby
{:TOTAL=>14675, :FREE=>74, :T_OBJECT=>337, :T_CLASS=>0, :T_MODULE=>0, :T_FLOAT=>0, :T_STRING=>7834, :T_REGEXP=>26, :T_ARRAY=>3133, :T_HASH=>295, :T_STRUCT=>54, :T_BIGNUM=>0, :T_FILE=>5, :T_DATA=>636, :T_MATCH=>427, :T_COMPLEX=>0, :T_RATIONAL=>0, :T_NODE=>1854, :T_ICLASS=>0}
```

**Dump server:**
```ruby
{:TOTAL=>0, :FREE=>-96, :T_OBJECT=>1, :T_CLASS=>0, :T_MODULE=>0, :T_FLOAT=>0, :T_STRING=>0, :T_REGEXP=>0, :T_ARRAY=>47, :T_HASH=>0, :T_STRUCT=>0, :T_BIGNUM=>0, :T_FILE=>1, :T_DATA=>47, :T_MATCH=>0, :T_COMPLEX=>0, :T_RATIONAL=>0, :T_NODE=>0, :T_ICLASS=>0}
```

**Hijack:**
```ruby
 {:TOTAL=>0, :FREE=>-84, :T_OBJECT=>1, :T_CLASS=>0, :T_MODULE=>0, :T_FLOAT=>0, :T_STRING=>38, :T_REGEXP=>0, :T_ARRAY=>25, :T_HASH=>1, :T_STRUCT=>0, :T_BIGNUM=>0, :T_FILE=>0, :T_DATA=>15, :T_MATCH=>0, :T_COMPLEX=>0, :T_RATIONAL=>0, :T_NODE=>4, :T_ICLASS=>0}
```
