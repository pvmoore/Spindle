module spindle.ast.expr.calloc;

import spindle.all;

/**
 *  Calloc
 *      TypeDecl    (element type)
 */
final class Calloc : Expression {
    uint count;

    this(uint count) {
        this.count = count;
    }

    Expression type() { return firstChild().as!Expression; }

/* Expression */
    override int precedence() {
        return 0;
    }
/* Statement */
    override bool isResolved() {
        return type().isResolved();
    }
    override TypeDecl getType() {
        return type().asTypeDecl();
    }
    override Comptime comptime() {
        // todo - this could be comptime later
        return Comptime.NO;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.Calloc;
    }
    override ASTNode clone() {
        auto n = new Calloc(count).at(this);
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        return "calloc(%s)".format(count);
    }
}