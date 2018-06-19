import com.github.kopilov.abstractpool {
    Pool
}
import java.util.concurrent {
    ExecutorService,
    Executors
}
import java.lang {
    Thread
}
shared void run() {

    FactoryExample fe = FactoryExample();
    Float expirationTime = 5.0;
    value pool = Pool<ResourceExample>(fe, expirationTime);

    ExecutorService executor = Executors.newFixedThreadPool(8);
    for (i in 1..5000) {
        void task() {
            try (r = pool.getResource()) {
                print("getResource");
                r.calculateAndPrint(10, i);
            }
        }
        executor.execute(task);
    }
    print("size 1 = ``pool.size``");
    executor.shutdown();
    while(!executor.terminated) {
        Thread.sleep(10);
    }
    print("size 2 = ``pool.size``");
    Thread.sleep(10 * 1000);
    print("size 3 = ``pool.size``");
    try (r = pool.getResource()) {
        print("getResource");
        r.calculateAndPrint(10, 0);
    }
    Thread.sleep(1000);
    print("size 4 = ``pool.size``");
}
