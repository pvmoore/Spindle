module spindle.ast.module_;

import spindle.all;

/**
 * Module
 *      Statement (0 or more)
 */
final class Module : ASTNode {
    string name;
    string path;
    Token[] tokens;
    bool isMainModule;
    bool isParsed;

    FunctionDecl[] publicFunctions;
    TypeDecl[] publicTypes;

/* ASTNode */
    override NodeID id() {
        return NodeID.Module;
    }
    override ASTNode clone() {
        assert(false);
    }
/* Object */
    override string toString() {
        return "[Module %s]".format(name);
    }
}