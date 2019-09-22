module spindle.ast.expr.string_literal;

import spindle.all;

/**
 * StringLiteral
 */
final class StringLiteral : Expression {
    string value;

/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return true;
    }
    override TypeDecl getType() {
        return TypeDecl.UNKNOWN;
    }
    override Comptime comptime() {
        // todo - we can make this comptime later
        return Comptime.NO;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.StringLiteral;
    }
    override ASTNode clone() {
        auto n = new StringLiteral().at(this);
        n.value = value;
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return value;
    }
}