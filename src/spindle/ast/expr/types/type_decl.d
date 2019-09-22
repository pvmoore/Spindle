module spindle.ast.expr.types.type_decl;

import spindle.all;

/**
 * TypeDecl
 */
class TypeDecl : Expression {
public:
    __gshared static TypeDecl UNKNOWN = new TypeDecl(TypeKind.UNKNOWN);
    __gshared static TypeDecl VOID    = new TypeDecl(TypeKind.VOID);

    TypeKind kind;
    int ptrDepth;

    this(TypeKind k, int ptrDepth = 0) {
        this.ptrDepth = ptrDepth;
        this.kind     = k;
    }

    bool isPtr()       { return ptrDepth>0; }
    bool isValue()     { return !isPtr(); }
    bool isFunction()  { return false; }
    bool isStruct()    { return false; }
    bool isArray()     { return false; }
    bool isReal()      { return kind.isReal(); }
    bool isInteger()   { return kind.isInteger(); }
    bool isVoid()      { return kind==TypeKind.VOID; }
    bool isBool()      { return kind==TypeKind.BOOL; }
    bool isBasicType() { return isBool() || isInteger() || isReal(); }

    bool canImplicitlyCastTo(TypeDecl other) {
        if(!commonCanImplicitlyCastTo(other)) return false;

        if(isVoid() || other.isVoid()) return false;
        if(!other.isBasicType()) return false;

        if(kind==other.kind) return true;

        if(isReal() == other.isReal()) return kind <= other.kind;

        return other.isReal();
    }
    bool exactlyMatches(TypeDecl other) {
        assert(isResolved() && other.isResolved());
        return other.kind == kind;
    }
    ArrayDecl asArrayDecl() {
        return null;
    }
    FunctionDecl asFunctionDecl() {
        return null;
    }
    StructDecl asStructDecl() {
        return null;
    }
    uint size() {
        assert(isResolved());
        if(isPtr()) return 8;
        switch(kind) with(TypeKind) {
            default:
                return 0;
            case BOOL:
            case BYTE:
                return 1;
            case SHORT:
                return 2;
            case INT:
            case FLOAT:
                return 4;
            case LONG:
            case DOUBLE:
                return 8;
        }
    }
    Expression defaultValue() {
        assert(isResolved());

        if(isPtr()) {
            auto n = new NullLiteral;
            n.add(this.clone());
            return n;
        }

        switch(kind) with(TypeKind) {
            case BOOL:
                return new NumberLiteral(false);
            case BYTE:
            case SHORT:
            case INT:
            case LONG:
                return new NumberLiteral(0, kind);
            case FLOAT:
            case DOUBLE:
                return new NumberLiteral(0.0, kind);
            default:
                assert(false, "defaultValue kind = %s".format(kind));
        }
    }

/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return !kind.isUnknown();
    }
    override TypeDecl getType() {
        return this;
    }
    override Comptime comptime() {
        return Comptime.YES;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.TypeDecl;
    }
    override ASTNode clone() {
        auto n = new TypeDecl(kind, ptrDepth).at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return From!"std.string".toLower("%s%s".format(kind, repeat("*", ptrDepth)));
    }
protected:
    bool commonCanImplicitlyCastTo(TypeDecl other) {
        assert(isResolved() && other.isResolved());

        if(isPtr() && other.isPtr() && other.isVoid()) return true; // anytype* --> void*

        if(isValue() != other.isValue()) return false;

        return true;
    }
}
