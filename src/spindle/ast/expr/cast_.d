module spindle.ast.expr.cast_;

import spindle.all;

/**
 * Cast ::= TypeDecl '{' Expression '}'
 *
 * Cast
 *      [0] TypeDecl
 *      [1] Expression
 */
final class Cast : Expression {

    TypeDecl type() {
        return firstChild().asTypeDecl;
    }
    Expression typeExpr() {
        return firstChild().as!Expression;
    }
    Expression expression() {
        return lastChild().as!Expression;
    }

/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return type().isResolvedType();
    }
    override TypeDecl getType() {
        return type();
    }
    override Comptime comptime() {

        if(!isResolved()) return Comptime.UNRESOLVED;

        return expression().comptime();
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.Cast;
    }
    override ASTNode clone() {
        auto n = new Cast().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        string r = isResolved() ? getType().toString() : "(unresolved)";
        return "Cast %s".format(r);
    }
}