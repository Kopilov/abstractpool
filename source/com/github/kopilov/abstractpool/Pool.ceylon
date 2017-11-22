import java.util.concurrent {
    LinkedBlockingQueue
}
import ceylon.time {
    Clock,
    systemTime
}
import ceylon.collection {
    ArrayList
}
import java.lang {
    Thread
}
"Universal dynamic resource pool.
 Allows to reuse [[PooledResource]] objects created with [[ResourceFactory]]"
shared class Pool<out Resource> (
        "Object that creates actual resources in the pool"
        ResourceFactory<out Resource> factory,
        "Time in seconds from last resource usage to it's removing"
        Float expirationTime = 60.0
        )
        given Resource satisfies PooledResource
        {

    value freeResources = LinkedBlockingQueue<Resource>();
    variable Boolean isCleaning = false;

    Resource generateResource() {
        Resource resource = factory.createResource();
        void obtainResource() {
        }
        void releaseResource() {
            freeResources.put(resource);
            if (!isCleaning) {
                Thread(cleanResources).start();
            }
        }
        resource.obtainFromPool = obtainResource;
        resource.releaseToPool = releaseResource;
        return resource;
    }

    shared Resource getResource() {
        if (freeResources.empty || isCleaning) {
            return generateResource();
        } else {
            return freeResources.take();
        }
    }

    shared void cleanResources() {
        isCleaning = true;
        Clock cleandAt = systemTime;
        value oldResources = ArrayList<PooledResource>();
        Integer size = freeResources.size();
        for (Integer i in 1..size) {
            value resource = freeResources.take();
            if ((cleandAt.milliseconds() - resource.lastUsage) / 1000.0 > expirationTime) {
                oldResources.add(resource);
            } else {
                freeResources.put(resource);
            }
        }
        for (PooledResource resource in oldResources) {
            resource.close();
        }
        isCleaning = false;
    }

    shared Integer size => freeResources.size();
}
