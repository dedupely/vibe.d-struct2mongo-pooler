module vibedstruct2mongo;
import vibe.core.log;

class MongoDBConnection {
    import vibe.d;
    import vibe.core.connectionpool;

    import mondo : MongoPool, Mongo;
    ConnectionPool!Mongo connections;
    private string connectionString;

    auto connectionFactory () {
        return mongoPool.pop ();
    }

    this (string connectionString, uint maxConnections) {
        this.connectionString = connectionString;

        this.connections = new ConnectionPool!Mongo (
            &connectionFactory, maxConnections
        );
    }

    ~this () {
        connections = null;
    }

    auto opIndex (string collection) {
        return connections.lockConnection [collection];
    }

    import std.traits : MemberFunctionsTuple;
    auto opDispatch (string fun, Args ...)(Args args) 
        if (MemberFunctionsTuple!(Mongo, fun).length) {
            auto conn = connections.lockConnection ();
            enum called = `conn.` ~ fun ~ ` (args)`;
            static if (__traits (compiles, mixin (called))) {
                import std.traits : ReturnType;
                static if (is (ReturnType!(mixin (called)) == void)) {
                    // Doesn't return.
                    mixin (called);
                } else { // Returns.
                    return mixin (called);
                }
            } else {
                static assert (0, `Don't know what to do.`);
            }
        }
}

unittest {
    auto pool = new MongoDBConnection ("mongodb://localhost", 10);
    import struct2mongo;
    assert (pool.connected, `Not connected to Mongo.`);
    auto col = Col (pool [`newBase`][`newCollection`]);
    if (col.exists) col.drop;
    struct Example {
        int a = 0;
    }
    col.insert (Example (5));
}
