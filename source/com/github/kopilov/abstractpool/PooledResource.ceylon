import ceylon.time {
    systemTime
}
"This class should be extended with any elements and methods
 that should be kept in the [[Pool]]."
shared abstract class PooledResource() satisfies Obtainable {

    variable Integer usedAt = systemTime.milliseconds();

    shared variable Anything() obtainToPool = (){throw Exception("Replace this executable with actual inside some pool");};
    shared variable Anything() releaseFromPool = (){throw Exception("Replace this executable with actual inside some pool");};

    shared actual void obtain() {
        obtainToPool();
    }
    shared actual void release(Throwable? error) {
        usedAt = systemTime.milliseconds();
        releaseFromPool();
    }

    shared Integer lastUsage => usedAt;

    shared formal void close();
}
