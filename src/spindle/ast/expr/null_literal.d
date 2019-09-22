module spindle.ast.expr.null_literal;

import spindle.all;

/**
 * NullLiteral
 *      TypeDecl
 */
final class NullLiteral : Expression {

    Expression type() { return firstChild().as!Expression; }

    /* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return type().isResolved();
    }
    override TypeDecl getType() {
        return type().asTypeDecl();
    }
    override Comptime comptime() {
        return Comptime.YES;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.NullLiteral;
    }
    override ASTNode clone() {
        auto n = new NullLiteral().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "(null)";
    }
}