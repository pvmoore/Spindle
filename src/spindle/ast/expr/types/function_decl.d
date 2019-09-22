module spindle.ast.expr.types.function_decl;

import spindle.all;

/**
 * FunctionDecl
 *      Variable (0 or more) parameters
 *      Expression returnType
 */
final class FunctionDecl : TypeDecl {
    __gshared static FunctionDecl UNKNOWN = new FunctionDecl(TypeKind.UNKNOWN);
    int numParams;

    this(TypeKind k = TypeKind.FUNCTION, int ptrDepth = 0) {
        super(k, ptrDepth);
    }

    VariableDecl[] params() {
        return children()[0..numParams].as!(VariableDecl[]);
    }
    string[] paramNames() {
        return params().map!(it=>it.name).array;
    }
    TypeDecl[] paramTypes() {
        return params().map!(it=>it.type().asTypeDecl()).array;
    }
    TypeDecl returnType() {
        return children[numParams].asTypeDecl();
    }

    override bool isFunction() { return true; }

    bool isAParam(TypeDecl t) {
        auto i = indexOf(t);
        return i!=-1 && i < numParams;
    }
    bool isTheReturnType(TypeDecl t) {
        return children[numParams] is t;
    }
/* TypeDecl */
    // Functions are implicit pointers
    override bool isPtr()   {
        return true;
    }
    override bool isValue() {
        return false;
    }
    override FunctionDecl asFunctionDecl() {
        return this;
    }
    override bool canImplicitlyCastTo(TypeDecl other) {
        if(!commonCanImplicitlyCastTo(other)) return false;

        auto otherFunc = other.asFunctionDecl();
        if(!otherFunc) return false;

        return params().exactlyMatch(otherFunc.params());
    }
    override bool exactlyMatches(TypeDecl other) {
        assert(isResolved() && other.isResolved());

        auto f = other.asFunctionDecl();
        if(f is null) return false;

        return returnType().exactlyMatches(f.returnType()) && exactlyMatch(paramTypes(), f.paramTypes());
    }
/* Statement */
    override bool isResolved() {
        return paramTypes().areResolved() && returnType.isResolved();
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
        return NodeID.FunctionDecl;
    }
    override ASTNode clone() {
        auto n = new FunctionDecl(kind, ptrDepth).at(this);
        n.numParams = numParams;
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        string s = .toString(paramNames(), paramTypes());
        if(!s) s = "void";
        return "fn(%s->%s)".format(s, returnType());
    }
}

