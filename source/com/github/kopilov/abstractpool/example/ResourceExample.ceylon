import com.github.kopilov.abstractpool {
    PooledResource
}
class ResourceExample() extends PooledResource() {
    shared void calculateAndPrint(Integer a) {
        for (i in 1..a) {
            for (j in 1..a) {
                for (k in 1..a) {
                    if (i == a && j == a && k == a) {
                        print ("Everything is ``a``");
                    }
                }
            }
        }
    }

    shared actual void close() {}

}