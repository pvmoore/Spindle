module spindle.ast.astnode;

import spindle.all;

enum NodeID : uint {
    Binary, Call, Identifier,
    ArrayLiteral, Cast, FunctionLiteral, StructLiteral, UnresolvedInitialiser,
    NullLiteral, NumberLiteral, Parens, StringLiteral, Unary,
    ArrayDecl ,FunctionDecl, StructDecl, TypeDecl, TypeExpression,
    Module, DefaultValue, NoValue,
    Return, VariableDecl, Calloc
}

abstract class ASTNode {
private:
    ASTNode[] _children;
    ASTNode _parent;
protected:
    final ASTNode cloneChildren(ASTNode instance) {
        assert(instance, "instance is null");
        foreach(n; _children) {
            instance.add(n.clone());
        }
        return instance;
    }
public:
    int line, column;

    abstract NodeID id();
    abstract ASTNode clone();

/* Modify structure */
    final ASTNode add(ASTNode child) {
        if(child.hasParent()) {
            child.detach();
        }
        child._parent = this;
        _children ~= child;
        return this;
    }
    final void addToFront(ASTNode child) {
        if(child.hasParent()) {
            child.detach();
        }
        child._parent = this;
        _children.insert(0, child);
    }
    final void remove(ASTNode child) {
        assert(child._parent is this);
        child._parent = null;
        _children.remove(child);
        assert(!_children.contains(child));
    }
    final ASTNode detach() {
        if(hasParent()) {
            _parent.remove(this);
        }
        return this;
    }
    final void replaceChild(ASTNode child, ASTNode otherChild) {
        int i = indexOf(child);
        assert(i!=-1, "This is not my child");

        _children[i]       = otherChild;
        child._parent      = null;
        otherChild._parent = this;
    }
    final void transferAllChildrenTo(ASTNode other) {
        while(this.hasChildren()) {
            other.add(this.firstChild());
        }
    }

/* Getters */
    final auto children()    { return _children; }
    final auto hasParent()   { return _parent !is null; }
    final auto numChildren() { return _children.length.as!int; }
    final auto hasChildren() { return numChildren() > 0; }
    final auto parent()      { return _parent; }

    final int indexOf(ASTNode child) {
        return _children.indexOf(child);
    }
    final int index() {
        if(!hasParent()) return -1;
        return _parent.indexOf(this);
    }
    final auto firstChild() {
        if(_children.length==0) return null;
        return children[0];
    }
    final auto lastChild() {
        if(_children.length==0) return null;
        return children[$-1];
    }
    final ASTNode prevNode() {
        auto i = index();
        if(i==-1) return null;
        if(i>0) return _parent._children[i-1];
        return _parent;
    }
    final bool isAttached() {
        if(this.isA!Module) return true;
        if(_parent is null) return false;
        return _parent.isAttached();
    }

/* Utility */
    final void dumpToLog(string indent="") {
        log("%s%s", indent, toString());
        foreach(c; _children) {
            c.dumpToLog(indent~"| ");
        }
    }
    final void dumpToConsole(string indent="") {
        writefln("%s%s", indent, toString());
        foreach(c; _children) {
            c.dumpToConsole(indent~"| ");
        }
    }

/* Iteration */
    void recurse(void delegate(ASTNode n) functor) {
        functor(this);
        foreach(ch; _children) {
            ch.recurse(functor);
        }
    }
    void recurseIf(T)(void delegate(T n) functor) {
        if(this.isA!T) {
            functor(this.as!T);
        }
        foreach(ch; _children) {
            ch.recurseIf!T(functor);
        }
    }
}


auto at(T)(T node, int line, int column) {
    node.line   = line;
    node.column = column;
    return node;
}
auto at(T)(T node, Parser p) {
    node.line   = p.line;
    node.column = p.column;
    return node;
}
auto at(T)(T node, ASTNode other) {
    node.line   = other.line;
    node.column = other.column;
    return node;
}
