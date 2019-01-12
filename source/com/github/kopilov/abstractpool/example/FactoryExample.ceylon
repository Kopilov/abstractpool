import com.github.kopilov.abstractpool {
    ResourceFactory
}
class FactoryExample() satisfies ResourceFactory<ResourceExample> {
    shared actual ResourceExample createResource(Integer resourceId) {
        print ("createResource");
        return ResourceExample(resourceId);
    }
}
