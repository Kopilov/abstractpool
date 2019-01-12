"Actual ResourceFactory implementation creates new
 [[PooledResource]] objects for the [[Pool]]"
shared interface ResourceFactory<Resource> given Resource satisfies PooledResource {
    shared formal Resource createResource(Integer resourceID);
}
