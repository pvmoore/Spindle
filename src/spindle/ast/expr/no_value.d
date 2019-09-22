module spindle.ast.expr.no_value;

import spindle.all;

final class NoValue : Expression {
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
        return Comptime.YES;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.NoValue;
    }
    override ASTNode clone() {
        auto n = new NoValue().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "no value";
    }
}