module spindle.ast.expr.binary;

import spindle.all;

/**
 * Binary
 *      Expression
 *      Expression
 */
final class Binary : Expression {
    Operator op = Operator.NONE;
    TypeDecl type;

    Expression left()  { return firstChild().as!Expression; }
    Expression right() { return lastChild().as!Expression; }

    TypeDecl leftType() { return left().getType(); }
    TypeDecl rightType() { return right().getType(); }

/* Expression */
    override int precedence() {
        return op.precedence();
    }
/* Statement */
    override bool isResolved() {
        return getType().isResolved();
    }
    override TypeDecl getType() {
        return type ? type : TypeDecl.UNKNOWN;
    }
    override Comptime comptime() {
        return merge(mergeComptime(left(), right()));
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.Binary;
    }
    override ASTNode clone() {
        auto n = new Binary().at(this);
        n.op = op;
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "%s (%s)".format(op.stringOf(), isResolved() ? type.toString() : "unresolved");
    }
}
