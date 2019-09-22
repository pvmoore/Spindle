module spindle.ast.expr.unary;

import spindle.all;

/**
 * Unary
 *      Expression
 */
final class Unary : Expression {
    Operator op = Operator.NONE;

    Expression expression() { return firstChild().as!Expression; }

/* Expression */
    override int precedence() {
        return op.precedence();
    }
/* Statement */
    override bool isResolved() {
        return op != Operator.NONE && expression().isResolved();
    }
    override TypeDecl getType() {
        return expression().getType();
    }
    override Comptime comptime() {
        return expression().comptime();
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.Unary;
    }
    override ASTNode clone() {
        auto n = new Unary().at(this);
        n.op = op;
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return op.stringOf();
    }
}