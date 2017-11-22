import ceylon.time {
    systemTime
}
"This class should be extended with any elements and methods
 that should be kept in the [[Pool]]."
shared abstract class PooledResource() satisfies Obtainable {

    variable Integer usedAt = systemTime.milliseconds();

    shared variable Anything() obtainFromPool = (){throw Exception("Replace this executable with actual inside some pool");};
    shared variable Anything() releaseToPool = (){throw Exception("Replace this executable with actual inside some pool");};

    shared actual default void obtain() {
        obtainFromPool();
    }
    shared actual default void release(Throwable? error) {
        usedAt = systemTime.milliseconds();
        releaseToPool();
    }

    shared Integer lastUsage => usedAt;

    shared formal void close();
}
