class Main inherits A2I {
  main(): Object {
    (new IO).out_string(i2a(a2i((new IO).in_string()) + 1).concat("\n"))
  };
};

