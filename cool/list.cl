class List {
  item: String;
  next: List;

  init(i: String, rest: List): List {
    {
      item <- i;
      next <- rest;
      self;
    }
  }; 

  flatten(): String {
    if (isvoid next) then item else item.concat(next.flatten()) fi
  };

};

class Main inherits IO {
  main(): Object {
    let nil: List,
        list: List <- (new List).init("Hello", (new List).init(" Cool language ", (new List).init("\n", nil)))
    in
        out_string(list.flatten())
  };
};

