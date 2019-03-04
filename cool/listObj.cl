class List inherits A2I {
  item: Object;
  next: List;

  init(i: Object, rest: List): List {
    {
      item <- i;
      next <- rest;
      self;
    }
  }; 

  flatten(): String {
    let string: String <-
      case item of
        i: Int => i2a(i);
        s: String => s;
        o: Object => { abort(); ""; };
      esac
    in
      if (isvoid next) then string else string.concat(next.flatten()) fi
  };

};

class Main inherits IO {
  main(): Object {
    let nil: List,
        list: List <- (new List).init(101, (new List).init(" Cool language ", (new List).init("\n", nil)))
    in
        out_string(list.flatten())
  };
};

