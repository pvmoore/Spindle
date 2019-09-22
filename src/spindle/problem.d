module spindle.problem;

import spindle.all;

abstract class AbsProblem {
    Module module_;
    string message;

    this(Module m, string msg) {
        this.module_ = m;
        this.message = msg;
    }

    string toShortString() {
        return "%s: %s".format(module_.name, message);
    }
    string toDetailedString() {
        return toShortString();
    }
protected:
    string getShortString(int line, int column) {
        return "[%s:%s:%s] %s".format(module_.name, line, column, message);
    }
}

final class CompilerProblem : AbsProblem {
    this(Throwable t) {
        super(null, "Compiler error: %s".format(t.message));
    }
    this(string msg) {
        super(null, "Compiler error: %s".format(msg));
    }
    override string toShortString() {
        return message;
    }
    override string toDetailedString() {
        return message;
    }
}

final class LexProblem : AbsProblem {
    int line, column;

    this(Module m, char ch, int line, int column) {
        super(m, "Unexpected token %s".format(ch));
        this.line   = line;
        this.column = column;
    }
    override string toShortString() {
        return getShortString(line, column);
    }
}

class NodeProblem : AbsProblem {
    ASTNode node;

    this(Module m, string msg, ASTNode node) {
        super(m, msg);
        this.node = node;
    }
    override string toShortString() {
        return getShortString(node.line, node.column);
    }
}

final class UnresolvedSymbols : AbsProblem {
    this(Module m) {
        super(m, "There are unresolved symbols");
    }
    override string toDetailedString() {

        auto buf = appender!(string);
        module_.recurse((n) {
            if(n.isA!Statement && !n.as!Statement.isResolved()) {
                buf ~= "\n[%s:%s] %s is unresolved".format(module_.name, n.line, n);
            }
        });

        return buf.data;
    }
}