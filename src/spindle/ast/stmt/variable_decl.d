module spindle.ast.stmt.variable_decl;

import spindle.all;

enum Const { UNRESOLVED, YES, NO }

/**
 * VariableDecl
 *      [0] Expression (TypeDecl)
 *      [1] Expression (value)
 */
final class VariableDecl : Statement {
    string name;
    bool isPublic;
    Const const_ = Const.UNRESOLVED;
    uint numRefs;

    Expression type() {
        return firstChild().as!Expression;
    }
    Expression value() {
        return lastChild().as!Expression;
    }

    bool isTheType(Expression e) {
        return firstChild() is e;
    }
    bool isTheValue(Expression e) {
        return lastChild() is e;
    }

/* Statement*/
    override bool isResolved() {
        return type().isResolvedType() && value().isResolved();
    }
    override TypeDecl getType() {
        return type().asTypeDecl();
    }
    override Comptime comptime() {
        //if(!isResolved()) return Comptime.UNRESOLVED;

        if(const_==Const.UNRESOLVED) return Comptime.UNRESOLVED;
        if(const_==Const.YES) return Comptime.YES;

        // todo - this can be comptime if it is unreferenced (possibly due to targeting Identifiers being folded)

        // if all identifiers which can see this variable have targets and
        //      - if numRefs==0 then we can remove this variable (if not a parameter)
        //      - if numRefs>0 and all identifiers do not modify the value then const_ = Const.YES

        return Comptime.NO;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.VariableDecl;
    }
    override ASTNode clone() {
        auto n      = new VariableDecl().at(this);
        n.name      = name;
        n.isPublic  = isPublic;
        auto ch = cloneChildren(n);
        return ch;
    }
/* Object */
    override string toString() {
        string n = name ? name : "(no name)";
        string a = isPublic ? " (pub)" : "";
        string c = const_ == Const.YES ? " (const)" : "";
        string r = numRefs == 0 ? "" : " (%s refs)".format(numRefs);
        return "variable: '%s':%s%s%s%s".format(n, getType(), a, c, r);
    }
}

//########################################################################

bool allTypesAreTypeDecls(Set!VariableDecl vars) {
    foreach(v; vars.values()) {
        auto t = v.type().as!TypeDecl;
        if(!t || t.kind==TypeKind.UNKNOWN) return false;
    }
    return true;
}

bool allTypesAreResolved(Set!VariableDecl vars) {
    foreach(v; vars.values()) {
        if(!v.type().isResolved()) return false;
    }
    return true;
}

/**
 * Note: Doesn't take into account any value.
 */
bool exactlyMatches(VariableDecl v1, VariableDecl v2) {
    assert(v1.isResolved() && v2.isResolved());
    return v1.name == v2.name && v1.getType().exactlyMatches(v2.getType());
}
bool exactlyMatch(VariableDecl[] vars1, VariableDecl[] vars2) {
    if(vars1.length != vars2.length) return false;

    for(auto i=0; i<vars1.length; i++) {
        if(!vars1[i].exactlyMatches(vars2[i])) return false;
    }
    return true;
}