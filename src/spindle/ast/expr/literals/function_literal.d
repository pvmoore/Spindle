module spindle.ast.expr.literals.function_literal;

import spindle.all;

/**
 * FunctionLiteral ::= FunctionDecl '{' { Statement } '}'
 *
 * FunctionLiteral
 *      [0] FunctionDecl
 *      [1] Statement (0 or more)
 */
final class FunctionLiteral : Expression {

    FunctionDecl type() {
        return firstChild().as!FunctionDecl;
    }
    Statement[] statements() {
        return children()[1..$].as!(Statement[]);
    }
    int numStatements() {
        return numChildren()-1;
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
        return NodeID.FunctionLiteral;
    }
    override ASTNode clone() {
        auto n = new FunctionLiteral().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "FunctionLiteral".format();
    }
}