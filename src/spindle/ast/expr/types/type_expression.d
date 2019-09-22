module spindle.ast.expr.types.type_expression;

import spindle.all;

/**
 * TypeExpression
 *      Expression (to be resolved into a TypeDecl somehow)
 */
final class TypeExpression : TypeDecl {
    VariableDecl var;   // Set if this is resolved and the child Expression was an Identifier

    this(TypeKind k = TypeKind.UNKNOWN, int ptrDepth = 0) {
        super(k, ptrDepth);
    }

    string name() { return var ? var.name : ""; }

    Expression expression() { return firstChild().as!Expression(); }

    TypeDecl targetType() { return expression().asTypeDecl(); }

/* TypeDecl */
    override bool isPtr()      { return ptrDepth>0 || (targetType().ptrDepth>0); }
    override bool isArray()    { return targetType().isArray(); }
    override bool isFunction() { return targetType().isFunction(); }
    override bool isStruct()   { return targetType().isStruct(); }

    override ArrayDecl asArrayDecl() {
        return targetType().as!ArrayDecl;
    }
    override FunctionDecl asFunctionDecl() {
        return targetType().as!FunctionDecl;
    }
    override StructDecl asStructDecl() {
        return targetType().as!StructDecl;
    }
    override uint size() {
        assert(isResolved());
        return targetType().size();
    }
    override bool canImplicitlyCastTo(TypeDecl other) {
        if(!commonCanImplicitlyCastTo(other)) return false;

        if(var) {
            auto otherTE = other.as!TypeExpression;
            if(!otherTE || !otherTE.var) return false;
            return var.exactlyMatches(otherTE.var);
        }

        return targetType().canImplicitlyCastTo(other);
    }
    override bool exactlyMatches(TypeDecl other) {
        assert(isResolved() && other.isResolved());

        return targetType().exactlyMatches(other);
    }
    override Expression defaultValue() {
        assert(isResolved());
        return targetType().defaultValue();
    }
/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return targetType().isResolved();// && !targetType().isA!TypeExpression;
    }
    override TypeDecl getType() {
        return this;
    }
    override Comptime comptime() {
        if(!isResolved()) return Comptime.UNRESOLVED;
        return Comptime.YES;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.TypeExpression;
    }
    override ASTNode clone() {
        auto n = new TypeExpression(kind, ptrDepth).at(this);
        n.var = var;
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        string n = name() ? name() : "(anon type)";
        string t = "%s".format(targetType().isResolved() ? targetType().toString() ~ repeat("*", ptrDepth) : "unresolved");
        return "%s --> %s".format(n ~ repeat("*", ptrDepth), t);
    }
}