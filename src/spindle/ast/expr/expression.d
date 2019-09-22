module spindle.ast.expr.expression;

import spindle.all;

abstract class Expression : Statement {
    abstract int precedence();
}

bool areResolved(Expression[] exprs) {
    foreach(e; exprs) {
        if(!e.isResolved()) return false;
    }
    return true;
}