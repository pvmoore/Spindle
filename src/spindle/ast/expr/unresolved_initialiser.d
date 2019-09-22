module spindle.ast.expr.unresolved_initialiser;

import spindle.all;

/**
 * UnresolvedInitialiser
 *      Statement  (0 or more)
 *      Expression (TypeDecl) always last
 */
final class UnresolvedInitialiser : Expression {

    Expression type() { return lastChild().as!Expression; }

/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return false;
    }
    override TypeDecl getType() {
        return type().asTypeDecl();
    }
    override Comptime comptime() {
        return Comptime.UNRESOLVED;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.UnresolvedInitialiser;
    }
    override ASTNode clone() {
        auto n = new UnresolvedInitialiser().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "UnresolvedInitialiser";
    }
}