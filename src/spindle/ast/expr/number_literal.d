module spindle.ast.expr.number_literal;

import spindle.all;

/**
 * NumberLiteral
 */
final class NumberLiteral : Expression {
    __gshared static NumberLiteral UNKNOWN = new NumberLiteral(0, TypeKind.UNKNOWN);

    union {
        double _double;
        long _long;
        bool _bool;
    }
    TypeKind kind = TypeKind.UNKNOWN;

    this(double value, TypeKind kind) {
        this._double = value;
        this.kind    = kind;
    }
    this(long value, TypeKind kind) {
        this._long = value;
        this.kind  = kind;
    }
    this(bool value) {
        this._bool = value;
        this.kind  = TypeKind.BOOL;
    }

/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return !kind.isUnknown();
    }
    override TypeDecl getType() {
        return new TypeDecl(kind);
    }
    override Comptime comptime() {
        return Comptime.YES;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.NumberLiteral;
    }
    override ASTNode clone() {
        auto n = new NumberLiteral(_long, kind).at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        if(kind.isUnknown) {
            return "unresolved number";
        }
        if(kind.isBool()) {
            return _bool ? "true" : "false";
        }
        if(kind.isInteger()) {
            return "%s".format(_long);
        }
        return "%s".format(_double);
    }
}