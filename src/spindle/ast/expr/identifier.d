module spindle.ast.expr.identifier;

import spindle.all;

/**
 * Identifier
 */
final class Identifier : Expression {
    string name;
    VariableDecl target;

    this(string name) {
        this.name = name;
    }
/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return target && target.isResolved();
    }
    override TypeDecl getType() {
        return target ? target.getType() : TypeDecl.UNKNOWN;
    }
    override Comptime comptime() {

        if(!isResolved()) return Comptime.UNRESOLVED;

        // todo - if target is never modified then we can be comptime

        return Comptime.NO;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.Identifier;
    }
    override ASTNode clone() {
        auto n = new Identifier(name).at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        string t = target ? " --> %s".format(target) : " (unresolved)";
        return "id:%s%s".format(name, t);
    }
}