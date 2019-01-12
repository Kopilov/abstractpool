"""This module contains simple [[Pool]] for keeping different reusable objects.
   Abstract [[PooledResource]] class should be extend by real resource to be kept.
   [[ResourceFactory]] interface should be satisfied with object that creates your resources for your pool.

   Example to use (also can be found in the package [[com.github.kopilov.abstractpool.example]]:

   FactoryExample.ceylon

        import com.github.kopilov.abstractpool {
            ResourceFactory
        }
        class FactoryExample() satisfies ResourceFactory<ResourceExample> {
            shared actual ResourceExample createResource() {
                print ("createResource");
                return ResourceExample();
            }
        }

   ResourceExample.ceylon

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
            Thread.sleep(10 * 1000); //pause 1
            print("size 3 = ``pool.size``");
            try (r = pool.getResource()) {
                print("getResource");
                r.calculateAndPrint(10, 0);
            }
            Thread.sleep(1000); //pause 2
            print("size 4 = ``pool.size``");
        }

   Some important things that we can notice in the output:
   - **getResource** is printed definitely 5001 time;
   - **createResource** is printed about 4700-4800 times because resources are reused;
   - **size 1** is zero or about zero because all tasks are just started and pool has no free resources;
   - **size 2** and **size 3** are about 4700-4800 because all created resource are returned to the pool.
   **size 3** can be little bigger than **size 2** if some resources released during pause 1.
   - **size 4** should be 1 because all other resource had been expirated during pause 1 and pool cleared during pause 2.
   [[Pool]] cleans itself when it is used (resources are obtained and released, usually with try-with-resource) as before pause 2.
   """

native ("jvm")
module com.github.kopilov.abstractpool "1.2.0" {
    import java.base "8";
    shared import ceylon.time "1.3.3";
    import ceylon.collection "1.3.3";
}
