module spindle.ast.expr.literals.struct_literal;

import spindle.all;

/**
 * StructLiteral
 *      [0] StructDecl
 *      [1] VariableDecl (0 or more)
 */
final class StructLiteral : Expression {

    StructDecl type() {
        return firstChild().as!StructDecl;
    }
    VariableDecl[] properties() {
        return children()[1..$].as!(VariableDecl[]);
    }
    string[] propertyNames() {
        return properties().map!(it=>it.name).array.as!(string[]);
    }
    TypeDecl[] propertyTypes() {
        return properties().map!(it=>it.type()).array.as!(TypeDecl[]);
    }
    Expression[] propertyValues() {
        return properties().map!(it=>it.value()).array.as!(Expression[]);
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
        return NodeID.StructLiteral;
    }
    override ASTNode clone() {
        auto n = new StructLiteral().at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "StructLiteral".format();
    }
}