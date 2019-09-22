module spindle.ast.expr.types.type_utilities;

import spindle.all;

bool isResolvedType(Expression e) {
    auto type = e.as!TypeDecl;
    return type !is null && type.isResolved();
}
bool areResolved(TypeDecl[] types) {
    foreach(t; types) {
        if(!t.isResolved()) return false;
    }
    return true;
}
bool exactlyMatch(TypeDecl[] a, TypeDecl[] b) {
    if(a.length != b.length) return false;

    assert(areResolved(a) && areResolved(b));

    for(auto i=0; i<a.length; i++) {
        if(!a[i].exactlyMatches(b[i])) return false;
    }
    return true;
}
bool areResolvedTypes(Expression[] decls) {
    foreach(t; decls) {
        if(!t.isResolvedType()) return false;
    }
    return true;
}
TypeDecl asTypeDecl(ASTNode e) {
    auto t = e.as!TypeDecl;
    return t ? t : TypeDecl.UNKNOWN;
}
string toString(TypeDecl[] types) {
    auto buf = appender!(string);
    foreach(i, t; types) {
        if(i>0) buf ~= ",";
        buf ~= "%s".format(t);
    }
    return buf.data;
}
string toString(string[] names, TypeDecl[] types) {
    assert(names.length==types.length);
    auto buf = appender!(string);
    for(auto i=0; i<names.length; i++) {
        if(i>0) buf ~= ", ";
        buf ~= "%s:%s".format(names[i], types[i]);
    }
    return buf.data;
}
TypeKind[] typeKinds(TypeDecl[] types) {
    auto buf = appender!(TypeKind[]);
    foreach(t; types) {
        buf ~= t.kind;
    }
    return buf.data;
}
///
/// Return the largest type of a or b.
/// Return null if they are not compatible.
///
TypeDecl getBestFit(TypeDecl a, TypeDecl b) {
    if(!a.isResolved() || !b.isResolved()) return null;

    if((a.kind.isVoid() && a.isValue()) || (b.kind.isVoid() && b.isValue())) {
        return null;
    }

    if(a.exactlyMatches(b)) return a;

    if(a.isPtr() || b.isPtr()) {
        return null;
    }
    if(a.isStruct() || b.isStruct()) {
        // todo - some clever logic here
        return null;
    }
    if(a.isFunction() || b.isFunction()) {
        return null;
    }
    // if(a.isArray || b.isArray) {
    //     return null;
    // }

    if(a.isReal() == b.isReal()) {
        return a.size() >= b.size() ? a : b;
    }
    if(a.isReal()) return a;
    if(b.isReal()) return b;
    return a;
}
bool canImplicitlyCastTo(TypeDecl[] from, TypeDecl[] to) {
    assert(from.length==to.length);

    foreach(i, f; from) {
        if(!f.canImplicitlyCastTo(to[i])) return false;
    }

    return true;
}