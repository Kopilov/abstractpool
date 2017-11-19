import com.github.kopilov.dynamicpool {
    ResourceFactory
}
class FactoryExample() satisfies ResourceFactory<ResourceExample> {
    shared actual ResourceExample createResource() {
        print ("createResource");
        return ResourceExample();
    }
}
