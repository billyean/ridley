class Main inherits A2I {
    main(): Object {
      (new IO).out_string(i2a(fib(a2i((new IO).in_string()))).concat("\n"))
    };

    fib(i: Int): Int {
      if i = 1 then 1 else
      if i = 2 then 1 else {
          let j: Int <- 1, k: Int <- 1, m: Int <- 1 in {
            while (not (i = 0)) loop
            {
               m <- j + k;
               j <- k;
               k <- m;
               i <- i - 1;
            } 
            pool;
            j;
          };
      } fi fi
    };
};

