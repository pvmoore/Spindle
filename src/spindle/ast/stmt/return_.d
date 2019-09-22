module spindle.ast.stmt.return_;

import spindle.all;

/**
 * Return
 *      Expression (optional)
 */
final class Return : Statement {

    bool hasExpression()    { return hasChildren(); }
    Expression expression() { return firstChild().as!Expression; }

/* Statement */
    override bool isResolved() {
        return !hasExpression() || expression().isResolved();
    }
    override TypeDecl getType() {
        if(hasExpression()) return expression().getType();
        return TypeDecl.VOID;
    }
    override Comptime comptime() {
        if(!isResolved()) return Comptime.UNRESOLVED;
        return Comptime.YES;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.Return;
    }
    override ASTNode clone() {
        auto n = new Return().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "return";
    }
}