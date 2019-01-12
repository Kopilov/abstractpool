import ceylon.time {
    Instant,
    systemTime
}
"This class should be extended with any elements and methods
 that should be kept in the [[Pool]]."
shared abstract class PooledResource(shared Integer id) satisfies Obtainable {

    variable Instant usedAt = systemTime.instant();

    shared variable Anything() obtainFromPool = (){throw Exception("Replace this executable with actual inside some pool");};
    shared variable Anything() releaseToPool = (){throw Exception("Replace this executable with actual inside some pool");};

    shared actual default void obtain() {
        obtainFromPool();
    }
    shared actual default void release(Throwable? error) {
        usedAt = systemTime.instant();
        releaseToPool();
    }

    shared Instant lastUsage => usedAt;

    shared formal void close();
}
