import com.github.kopilov.abstractpool {
    PooledResource
}
class ResourceExample() extends PooledResource() {
    variable String d = "";

    shared actual void obtain() {
        d = d + "obtained ";
        super.obtain();
    }
    shared actual void release(Throwable? error) {
        d = "";
        super.release(error);
    }

    shared void calculateAndPrint(Integer a, Integer id) {
        for (i in 1..a) {
            for (j in 1..a) {
                for (k in 1..a) {
                    if (i == a && j == a && k == a) {
                        print ("Everything is ``a``");
                        print("i = ``id``, d = ``d``");
                    }
                }
            }
        }
    }

    shared actual void close() {}

}