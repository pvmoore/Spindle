module spindle.resolve.resolver;

import spindle.all;

final class Resolver {
private:
    enum DEBUG = false;
    ResolveBinary resolveBinary;
    ResolveCall resolveCall;
    ResolveIdentifier resolveIdentifier;
    ResolveInitialiser resolveInitialiser;
    ResolveLiteral resolveLiteral;
    ResolveToTypeDecl resolveToTypeDecl;
    ResolveVariableDecl resolveVariableDecl;
    FindVariable findVariable;
    bool modified, resolved;
    int iterations;

    ASTNode modifiedNode;

    struct Status {
        bool isResolved;
        bool wasModified;
        int iterations;
        string toString() { return "iteration: %s, resolved: %s, modified: %s".format(iterations, isResolved, wasModified); }
    }
public:
    Spindle spindle;
    Module module_;

    this(Spindle s, Module module_) {
        this.spindle             = s;
        this.module_             = module_;
        this.resolveBinary       = new ResolveBinary(this);
        this.resolveCall         = new ResolveCall(this);
        this.resolveIdentifier   = new ResolveIdentifier(this);
        this.resolveInitialiser  = new ResolveInitialiser(this);
        this.resolveLiteral      = new ResolveLiteral(this);
        this.resolveToTypeDecl   = new ResolveToTypeDecl(this);
        this.resolveVariableDecl = new ResolveVariableDecl(this);
        this.findVariable        = new FindVariable;
    }

    void setModified(ASTNode node = null) {
        this.modified = true;
        if(node) modifiedNode = node;
        if(DEBUG) log("modified node = %s", modifiedNode);
    }
    void setUnresolved() { this.resolved = false; }

    Status resolve() {
        this.modified = false;
        this.resolved = true;
        this.iterations++;

        logf("-------------------------------------- %s Start iteration %s", module_, iterations);
        if(DEBUG) dbg("---------------------------- iteration %s", iterations);

        recurse(module_);

        return Status(resolved, modified, iterations);
    }
    void fold(ASTNode replaceMe, ASTNode withMe) {
        assert(!withMe.isAttached());

        auto p = replaceMe.parent();
        assert(p);
        p.replaceChild(replaceMe, withMe);
        setModified(withMe);

        handleRemovedNode(replaceMe);
    }
    void resolveToType(Expression e) {
        resolveToTypeDecl.resolve(e);
    }
    VariableDecl findDeclaration(Identifier id) {
        return findVariable.findDeclaration(id, id.name);
    }
    Set!VariableDecl findDeclarations(ASTNode n, string name) {
        return findVariable.findDeclarations(n, name);
    }
    void addProblem(string message, ASTNode node) {
        spindle.addProblem(module_, message, node);
    }
private:
    void visit(ArrayLiteral n) {
        resolveLiteral.resolve(n); 
    }
    void visit(Binary n) {
        resolveBinary.resolve(n);
    }
    void visit(Call n) {
        resolveCall.resolve(n);
    }
    void visit(Calloc n) {

    }
    void visit(Cast n) {
        if(n.typeExpr().isResolved()) {
            fold(n.typeExpr(), n.typeExpr().getType().clone());
        }

        if(n.isResolved()) {
            /* If the cast is unnecessary, fold it */
            auto t  = n.type();
            auto et = n.expression().getType();
            if(t.exactlyMatches(et)) {
                auto e = n.expression().detach();
                fold(n, e);
                return;
            }
        }
    }
    void visit(DefaultValue n) {
        // auto parent = n.parent().as!VariableDecl;
        // if(parent) {

        auto type = n.parent().as!Statement.getType();
        if(type.isResolved()) {
            fold(n, type.defaultValue());
        }
    }
    void visit(FunctionLiteral n) {
        resolveLiteral.resolve(n);
    }
    void visit(Identifier n) {
        resolveIdentifier.resolve(n);
    }
    void visit(Module n) {
        // Nothing to do
    }
    void visit(NoValue n) {
        // Nothing to do
    }
    void visit(NullLiteral n) {
        resolveLiteral.resolve(n);
    }
    void visit(NumberLiteral n) {
        resolveLiteral.resolve(n);
    }
    void visit(Parens n) {

    }
    void visit(Return n) {

    }
    void visit(StringLiteral n) {
        resolveLiteral.resolve(n);
    }
    void visit(StructLiteral n) {
        resolveLiteral.resolve(n);
    }
    void visit(TypeDecl n) {
        resolveToTypeDecl.resolve(n);
    }
    void visit(TypeExpression n) {
        resolveToTypeDecl.resolve(n);
    }
    void visit(Unary n) {

    }
    void visit(UnresolvedInitialiser n) {
        resolveInitialiser.resolve(n);
    }
    void visit(VariableDecl n) {
        resolveVariableDecl.resolve(n);
    }
    void _visit(ASTNode n) {
        static if(DEBUG) dbg("visit(%s)".format(simpleClassName(n)));

        sw:final switch(n.id()) {
            static foreach(e; From!"std.traits".EnumMembers!NodeID) {
                mixin("case NodeID.%s: visit(cast(%s)n); break sw;".format(e, e));
            }
        }

        static if(DEBUG) dbg("    after visit(%s) %s", simpleClassName(n),
            n.isA!Statement ? n.as!Statement.isResolved() : true);
    }
    void recurse(ASTNode n) {

        if(!n.isAttached()) return;

        _visit(n);

        if(!n.isAttached()) { return; }

        if(n.isA!Statement && !n.as!Statement.isResolved()) setUnresolved();

        foreach(node; n.children().dup) {
            recurse(node);
        }
    }
    void handleRemovedNode(ASTNode n) {
        auto i = n.as!Identifier;
        if(i) {
            if(i.target) i.target.numRefs--;
        }
        auto ti = n.as!TypeExpression;
        if(ti) {
            if(ti.var) ti.var.numRefs--;
        }
        foreach(ch; n.children()) {
            handleRemovedNode(ch);
        }
    }
}