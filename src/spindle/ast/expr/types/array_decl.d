module spindle.ast.expr.types.array_decl;

import spindle.all;

/**
 * ArrayDecl
 *      [0] Expression (TypeDecl) element type
 *      [1] Expression count
 */
final class ArrayDecl : TypeDecl {
    __gshared static ArrayDecl UNKNOWN = new ArrayDecl(TypeKind.UNKNOWN);

    this(TypeKind k = TypeKind.ARRAY, int ptrDepth = 0) {
        super(k, ptrDepth);
    }

    TypeDecl elementType() {
        return firstChild().asTypeDecl();
    }
    Expression count() {
        if(numChildren()==1) return NumberLiteral.UNKNOWN;
        return lastChild().as!Expression;
    }
    uint countAsInt() {
        assert(isResolved() && count().isA!NumberLiteral);
        return count().as!NumberLiteral._long.as!uint;
    }

    bool isTheType(Expression e) {
        return elementType() is e;
    }
    bool isTheCount(Expression e) {
        return count() is e;
    }

/* TypeDecl */
    override bool isArray() {
        return true;
    }
    override ArrayDecl asArrayDecl() {
        return this;
    }
    override bool canImplicitlyCastTo(TypeDecl other) {
        if(!commonCanImplicitlyCastTo(other)) return false;

        auto otherArray = other.asArrayDecl();
        if(!otherArray) return false;

        return countAsInt() == otherArray.countAsInt() &&
               elementType().exactlyMatches(otherArray.elementType());
    }
    override bool exactlyMatches(TypeDecl other) {
        assert(isResolved() && other.isResolved());

        auto a = other.asArrayDecl();
        if(a is null) return false;

        return countAsInt() == a.countAsInt() &&
               elementType().exactlyMatches(a.elementType());
    }
    override Expression defaultValue() {
        assert(isResolved());
        auto c = new Calloc(countAsInt());
        c.add(this.clone());
        return c;
    }
/* Statement */
    override bool isResolved() {
        return elementType().isResolved() && count.isResolved() && count.isA!NumberLiteral;
    }
    override TypeDecl getType() {
        return this;
    }
    override Comptime comptime() {
        if(!isResolved()) return Comptime.UNRESOLVED;
        return Comptime.YES;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.ArrayDecl;
    }
    override ASTNode clone() {
        auto n = new ArrayDecl(kind, ptrDepth).at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "array(%s,%s)".format(elementType(), count());
    }
}