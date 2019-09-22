module spindle.ast.expr.call;

import spindle.all;

/**
 * Call
 *      Expression (0 or more arguments)
 */
final class Call : Expression {
    string name;
    VariableDecl target;
    string[] argNames;

    Expression[] arguments() {
        return children().as!(Expression[]);
    }
    TypeDecl[] argTypes() {
        assert(arguments().areResolved());
        return arguments().map!(it=>it.getType()).array;
    }
    int numArguments() {
        return numChildren();
    }
    bool hasNamedArguments() {
        return argNames.length>0;
    }

/* Expression */
    override int precedence() {
        return 30;
    }
/* Statement */
    override bool isResolved() {
        return target && arguments().areResolved();
    }
    override TypeDecl getType() {
        return target ? target.getType() : TypeDecl.UNKNOWN;
    }
    override Comptime comptime() {
        // todo - this could be comptime later
        return Comptime.NO;
    }
/* ASTNode */
    override NodeID id() {
        return NodeID.Call;
    }
    override ASTNode clone() {
        auto n = new Call().at(this);
        n.name = name;
        return cloneChildren(n);
    }
/* Object */
    override string toString() {
        string ti = target && target.isResolved() ? target.toString() : "(unresolved target)";

        string s;
        if(hasNamedArguments()) {
            s = .toString(argNames, argTypes());
        } else {
            s = argTypes().toString();
        }

        return "Call %s(%s) -> %s".format(name, s, ti);
    }
}