class Main inherits A2I {
    main(): Object {
      (new IO).out_string(i2a(fib(a2i((new IO).in_string()))).concat("\n"))
    };

    fib(i: Int): Int {
        if i = 1 then 1 else
        if i = 2 then 1 else
        fib(i - 1) + fib(i - 2)
        fi fi
    };
};

