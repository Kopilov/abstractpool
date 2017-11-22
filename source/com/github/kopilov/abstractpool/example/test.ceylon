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
//    value resource = ResourceExample();
//    resource.calculateAndPrint(2000);

    FactoryExample fe = FactoryExample();
    value pool = Pool<ResourceExample>(fe, 5.0);

    ExecutorService threadPool = Executors.newCachedThreadPool();

    for (i in 1..100) {
        void task() {
            try (r = pool.getResource()) {
                print("start");
                r.calculateAndPrint(10, i);
            }
        }
        threadPool.execute(task);
    }
    print(pool.size);
    threadPool.shutdown();
    while(!threadPool.terminated) {
        Thread.sleep(10);
    }
    print(pool.size);
    Thread.sleep(10 * 1000);
    print(pool.size);

    ExecutorService threadPool2 = Executors.newFixedThreadPool(8);
    for (i in 1..5000) {
        void task() {
            try (r = pool.getResource()) {
                print("start");
                r.calculateAndPrint(10, i);
            }
        }
        threadPool2.execute(task);
    }
    print(pool.size);
    threadPool2.shutdown();
    while(!threadPool2.terminated) {
        Thread.sleep(10);
    }
    print(pool.size);
    Thread.sleep(10 * 1000);
    print(pool.size);
}
