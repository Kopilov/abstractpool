"""This module contains simple [[Pool]] for keeping different reusable objects.
   Abstract [[PooledResource]] class should be extend by real resource to be kept.
   [[ResourceFactory]] interface should be satisfied with object that creates your resources for your pool.

   Example to use (also can be found in the package [[com.github.kopilov.abstractpool.example]]:

   FactoryExample.ceylon

        import com.github.kopilov.abstractpool {
            ResourceFactory
        }
        class FactoryExample() satisfies ResourceFactory<ResourceExample> {
            shared actual ResourceExample createResource(Integer resourceId) {
                print ("createResource");
                return ResourceExample(resourceId);
            }
        }

   ResourceExample.ceylon

        import com.github.kopilov.abstractpool {
            PooledResource
        }
        class ResourceExample(Integer resourceId) extends PooledResource() {
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
                                print("Everything is ``a``");
                                print("i = ``id``, d = ``d``");
                            }
                        }
                    }
                }
            }

            shared actual void close() {}

        }

   test.ceylon

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
            //Pause for expiration. Note: pool.expirationTime is shorter.
            Thread.sleep(10 * 1000);
            print("size 3 = ``pool.size``");
        }

   Some important things that we can notice in the output:
   - **getResource** is printed definitely 5000 times (the same as pool.getResource() invocations);
   - **createResource** should be printed 8 times (or about — the same as number of threads);
   - **size 1** is usually zero because all tasks are just started and pool has no free resources;
   - **size 2** is 8 (or about) because all created resource are returned to the pool.
   - **size 3** should be 0 because all resources had been expirated and autoremoved during pause.
   [[Pool]] cleans itself when it is used (resources are obtained and released, usually with try-with-resource) as during pause.
   """

native ("jvm")
module com.github.kopilov.abstractpool "1.2.0" {
    import java.base "8";
    shared import ceylon.time "1.3.3";
    import ceylon.collection "1.3.3";
}
