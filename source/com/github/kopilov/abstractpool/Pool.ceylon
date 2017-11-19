import java.util.concurrent {
    ConcurrentHashMap
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

    value freeResources = ConcurrentHashMap<Integer,Resource>();
    value usedResources = ConcurrentHashMap<Integer,Resource>();
    variable Boolean isCleaning = false;

    Resource generateResource() {
        Resource resource = factory.createResource();
        void obtainResource() {
            Integer key = resource.hash;
            freeResources.remove(key);
            usedResources.put(key, resource);
        }
        void releaseResource() {
            Integer key = resource.hash;
            freeResources.put(key, resource);
            usedResources.remove(key);
            if (!isCleaning) {
                Thread(cleanResources).start();
            }
        }
        resource.obtainToPool = obtainResource;
        resource.releaseFromPool = releaseResource;
        return resource;
    }

    shared Resource getResource() {
        if (freeResources.empty || isCleaning) {
            return generateResource();
        } else {
            return freeResources.values().iterator().next();
        }
    }

    shared void cleanResources() {
        isCleaning = true;
        Clock cleandAt = systemTime;
        value oldResources = ArrayList<PooledResource>();
        for (PooledResource resource in freeResources.values()) {
            if ((cleandAt.milliseconds() - resource.lastUsage) / 1000.0 > expirationTime) {
                oldResources.add(resource);
            }
        }
        for (PooledResource resource in oldResources) {
            freeResources.remove(resource.hash);
            resource.close();
        }
        isCleaning = false;
    }

    shared Integer size => freeResources.size() + usedResources.size();
}
