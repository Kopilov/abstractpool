import com.github.kopilov.abstractpool {
    ResourceFactory
}
class FactoryExample() satisfies ResourceFactory<ResourceExample> {
    shared actual ResourceExample createResource() {
        print ("createResource");
        return ResourceExample();
    }
}
