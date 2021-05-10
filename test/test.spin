

// array declarations and definitions
//a = array(int) {1,2,3}
//b = array(float, 1)
//c = array(int,2) {1,2}

// struct declarations and definitions
//a = struct(prop:int, prop2:float)
//b = struct(prop:int = 1, foo=fn(){}) { prop = 3, foo = fn(){} }

// function declarations and definitions
//a = fn() {}
//b = fn(a:int->void)
//c:fn(a:int->float)

dir_deg = fn fn float(float) (d : int)  {

}
b = fn float(f:float) {

}
b = fn(f:float):float {

}
b = fn(f:float) float {

}
b = fn(f:float) return float {

}
c = fn(f:float -> fn(float->float)) {

}
c = fn(f:float => fn(float=>float)) {

}
c = fn(f:float >> fn(float>>float)) {

}
c = fn(f:float) : fn(float):float {

}
c = fn(f:float) return fn(float) return float {

}


// basic initialisers
//a = 3
//b = int{2}
//c:int


// type aliases
//T = int
//a : T
//b = T{4}


// type expression
//getInt = fn() { return struct(prop = 0) }
//a : getInt()








// s = struct(prop1:int) {
//     prop1 = 3
// }

//p = s.prop



// todo - the nameExpr points to the target VariableDecl
//doSomething()


//A = int
//B = (A*)
//C = (B*){1}
// B = (A*)
// C = (B*)
// a = C{3.4}


// todo - make this fold
//a = 10
//b = a + 10


//a = float*{null}    // Cast { NullLiteral }



// S = struct(
//     a:pub int = 1,
//     b:float,
//     baz:fn(),
//     boo:fn(void->void),
//     biz:fn(void),
//     boz:fn(->void),

//     foo = fn() { return 1 }
// )


/*
a = array(int, 3) {1,2,3}

b = array(float, 1)
c = array(int) {1,2}     // array(int,2)

a = 1

a = 0x00ff_fa
a = 0b00010_000
a = 1000_0000


a = int{1}

a = fn(p:int*, q:float**) {  }

b = fn(int,bool->int)

a:float = 3.2
main = pub fn() {
    b = 3
}

call()

var:getType()
getType = fn() { return int }
//
//a = 105
//b = int{3}
//c = int
//
//
call(3, 4)
*/

/**********************************************

T = int

t:T

//a = 3.1

b := 2
b += 3 + 1 * (4 + 7)

a = b

z:int




Thing = pub struct(prop:int) {
    prop:4
}

Elephant = struct(size:long) {
    size:50
}
Elephant2 = struct(size:long)

*********************************************/

/*
foo = fn(a:int) {
    return struct(prop:int)
}

f = foo(3)
g = foo(a:3)
*/



// s = struct(
//     len:int,
//     arr:int*,

//     add = pub fn(value: int) { // (this:@this*, value:type)

//     },
//     length = pub fn() { // (this:@this*)
//         return s.len
//     }
// )


/*
ListInt = List(int)

List = fn(T : @type) {
    return struct(
        len:T,
        arr:T*,

        add = pub fn(value: T) { // (this:@this*, value:T)

        },
        length = pub fn() { // (this:@this*)
            return s.len
        }
    )
    {
        len = @init(T), arr: null
    }
}
*/

