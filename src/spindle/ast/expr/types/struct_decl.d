module spindle.ast.expr.types.struct_decl;

import spindle.all;

/**
 * StructDecl
 *      VariableDecl (0 or more)
 */
final class StructDecl : TypeDecl {
    __gshared static StructDecl UNKNOWN = new StructDecl(TypeKind.UNKNOWN);

    this(TypeKind k = TypeKind.STRUCT, int ptrDepth = 0) {
        super(k, ptrDepth);
    }

    VariableDecl[] properties() {
        return children().as!(VariableDecl[]);
    }
    string[] properyNames() {
        return properties().map!(it=>it.name).array;
    }
    TypeDecl[] propertyTypes() {
        return properties().map!(it=>it.type().asTypeDecl()).array;
    }

/* TypeDecl */
    override bool isStruct() {
        return true;
    }
    override uint size() {
        assert(isResolved());
        return propertyTypes().map!(it=>it.size()).sum();
    }
    override StructDecl asStructDecl() {
        return this;
    }
    override bool canImplicitlyCastTo(TypeDecl other) {
        if(!commonCanImplicitlyCastTo(other)) return false;

        auto otherStruct = other.asStructDecl();
        if(!otherStruct) return false;

        return properties().exactlyMatch(otherStruct.properties());
    }
    override bool exactlyMatches(TypeDecl other) {
        assert(isResolved() && other.isResolved());

        auto s = other.asStructDecl();
        if(s is null) return false;

        return exactlyMatch(propertyTypes(), s.propertyTypes());
    }
    override Expression defaultValue() {
        assert(isResolved());

        auto init = new StructLiteral;
        init.add(this.clone());
        foreach(t; propertyTypes()) {
            init.add(t.defaultValue());
        }
        return init;
    }
/* Statement */
    override bool isResolved() {
        return propertyTypes().areResolved();
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
        return NodeID.StructDecl;
    }
    override ASTNode clone() {
        auto n = new StructDecl(kind, ptrDepth).at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        auto names = properyNames();
        auto types = propertyTypes();

        assert(names.length == types.length);

        auto buf = appender!(string);
        for(auto i=0; i<names.length; i++) {
            if(i>0) buf ~= ", ";
            buf ~= "%s:%s".format(names[i], types[i]);
        }
        return "struct(%s)%s".format(buf.data, repeat("*", ptrDepth));
    }
}