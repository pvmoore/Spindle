module spindle.ast.stmt.statement;

import spindle.all;

abstract class Statement : ASTNode {
    abstract bool isResolved();
    abstract TypeDecl getType();
    abstract Comptime comptime();
}

bool areResolved(Statement[] stmts) {
    foreach(s; stmts) {
        if(!s.isResolved()) return false;
    }
    return true;
}

//##################################################################################

enum Comptime { UNRESOLVED, YES, NO }

string toString(Comptime ct) {
    final switch(ct) with(Comptime) {
        case YES        : return "comptime";
        case UNRESOLVED : return "comptime?";
        case NO         : return "not comptime";
    }
}

Comptime mergeComptime(Statement[] stmts...) {
    Comptime result = Comptime.YES;
    foreach(e; stmts) {
        auto ct = e.comptime();
        if(ct==Comptime.NO) return Comptime.NO;
        if(ct==Comptime.UNRESOLVED) result = ct;
    }
    return result;
}
Comptime merge(Comptime[] cts...) {
    Comptime result = Comptime.YES;
    foreach(ct; cts) {
        if(ct==Comptime.NO) return Comptime.NO;
        if(ct==Comptime.UNRESOLVED) result = ct;
    }
    return result;
}
