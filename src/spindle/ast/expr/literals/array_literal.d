module spindle.ast.expr.literals.array_literal;

import spindle.all;

/**
 * ArrayLiteral ::= ArrayDecl '{' { Expression [ ',' Expression ] } '}'
 *
 * ArrayLiteral
 *      [0] ArrayDecl
 *      [1] Expression (0 or more)
 */
final class ArrayLiteral : Expression {

    ArrayDecl type() {
        return firstChild().as!ArrayDecl;
    }
    Expression[] expressions() {
        return children().as!(Expression[]);
    }
    uint numExpressions() {
        return numChildren()-1;
    }

    bool isTheType(Expression e) {
        return type() is e;
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
        // todo - make this comptime if possible
        return Comptime.NO;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.ArrayLiteral;
    }
    override ASTNode clone() {
        auto n = new ArrayLiteral().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "ArrayLiteral".format();
    }
}