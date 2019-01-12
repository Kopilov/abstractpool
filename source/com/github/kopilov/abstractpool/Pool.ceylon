import java.util.concurrent {
    LinkedBlockingDeque,
    ConcurrentHashMap,
    ExecutorService,
    ForkJoinPool
}
import ceylon.time {
    systemTime
}
import java.lang {
    Thread,
    Runnable
}
import java.util.concurrent.atomic {
    AtomicLong
}
"Universal dynamic resource pool.
 Allows to reuse [[PooledResource]] objects created with [[ResourceFactory]]"
shared class Pool<out Resource> (
        "Object that creates actual resources in the pool"
        ResourceFactory<out Resource> factory,
        "Time in seconds from last resource usage to it's removing"
        Float expirationTime = 60.0
    ) given Resource satisfies PooledResource {

    value nextResourceId = AtomicLong(0);
    value freeResources = ConcurrentHashMap<Integer, Resource>();
    value freeResourcesKeysStack = LinkedBlockingDeque<Integer>();

    ExecutorService cleaningExecutor = ForkJoinPool();
    value cleaningThreads = ConcurrentHashMap<Integer, WaitForObtainedOrExpired>();
    "Wait for [[resource]] to be reused or expired.
     Call [[PooledResource.close]] if [[PooledResource.lastUsage]] is less then systemTime - expirationTime.
     Simply stops if resource is obtained again."
    class WaitForObtainedOrExpired(Resource resource) satisfies Runnable {
        shared actual void run() {
            while (true) {
                //obtained again
                if (!freeResources.containsKey(resource.id)) {
                    cleaningThreads.remove(resource.id);
                    return;
                }
                //expired
                if ((systemTime.milliseconds() - resource.lastUsage.millisecondsOfEpoch) / 1000.0>expirationTime) {
                    freeResourcesKeysStack.remove(resource.id);
                    freeResources.remove(resource.id);
                    resource.close();
                    cleaningThreads.remove(resource.id);
                    return;
                }
                Thread.sleep(1000);
            }
        }
    }

    "Start new [[WaitForObtainedOrExpired]] thread for [[resource]] if not exists"
    void closeOnExpired(Resource resource) {
        if (!cleaningThreads.contains(resource.id)) {
            value waitForObtainedOrExpired = WaitForObtainedOrExpired(resource);
            cleaningThreads.put(resource.id, waitForObtainedOrExpired);
            cleaningExecutor.execute(waitForObtainedOrExpired);
        }
    }

    Resource generateResource() {
        Resource resource = factory.createResource(nextResourceId.incrementAndGet());
        void obtainResource() {

        }
        void releaseResource() {
            freeResources.put(resource.id, resource);
            freeResourcesKeysStack.putFirst(resource.id);
            closeOnExpired(resource);
        }
        resource.obtainFromPool = obtainResource;
        resource.releaseToPool = releaseResource;
        return resource;
    }

    shared Resource getResource() {
        if (freeResourcesKeysStack.empty) {
            return generateResource();
        } else {
            value resourceKey = freeResourcesKeysStack.takeFirst();
            return freeResources.remove(resourceKey);
        }
    }

    shared Integer size => freeResources.size();
}
