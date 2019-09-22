module spindle.ast.expr.parens;

import spindle.all;

/**
 * Parens
 *      Expression
 */
final class Parens : Expression {

    Expression expression() { return firstChild().as!Expression; }

/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return true;
    }
    override TypeDecl getType() {
        return expression().getType();
    }
    override Comptime comptime() {
        return expression().comptime();
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.Parens;
    }
    override ASTNode clone() {
        auto n = new Parens().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "()";
    }
}