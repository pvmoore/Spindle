module spindle.resolve.find_variable;

import spindle.all;

final class FindVariable {
private:

public:
    /**
     * Return the first reachable VariableDecl with name = _name_
     */
    VariableDecl findDeclaration(ASTNode startNode, string name) {
        ASTNode node = startNode;
        VariableDecl var;

        while(true) {
            node = node.prevNode();
            if(!node) return null;

            if((var = isAMatch(node, name)) !is null) return var;
        }
    }
    /**
     * Return all reachable VariableDecls with name = _name_
     */
    Set!VariableDecl findDeclarations(ASTNode startNode, string name) {
        VariableDecl var;
        auto node    = startNode;
        auto results = new Set!VariableDecl;

        while(true) {
            node = node.prevNode();
            if(!node) break;

            if(node.isA!Module) {
                /* All module scope variables are visible */
                foreach(n; node.children()) {
                    if((var = isAMatch(n, name)) !is null) { results.add(var); }
                }
                break;
            } else if(node.isA!StructDecl) {
                /* All struct scope variables are visible */
                foreach(n; node.children()) {
                    if((var = isAMatch(n, name)) !is null) { results.add(var); }
                }
            } else {
                if((var = isAMatch(node, name)) !is null) { results.add(var); }
            }
        }

        return results;
    }
private:
    auto isAMatch(ASTNode n, string name) {
        auto v = n.as!VariableDecl;
        return (v && v.name == name) ? v : null;
    }
}