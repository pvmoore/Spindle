module spindle.ast.expr.default_value;

import spindle.all;

/**
 * DefaultValue
 */
final class DefaultValue : Expression {
/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        // Replace with actual value during resolution
        return false;
    }
    override TypeDecl getType() {
        return TypeDecl.UNKNOWN;
    }
    override Comptime comptime() {
        return Comptime.YES;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.DefaultValue;
    }
    override ASTNode clone() {
        auto n = new DefaultValue().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "default value";
    }
}