"Actual ResourceFactory implementation creates new
 [[PooledResource]] objects for the [[Pool]]"
shared interface ResourceFactory<Resource> {
    shared formal Resource createResource();
}
