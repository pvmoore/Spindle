module spindle.resolve.resolve_to_typedecl;

import spindle.all;

/**
 *
 */
final class ResolveToTypeDecl {
private:
    Resolver resolver;
public:
    this(Resolver resolver) {
        this.resolver  = resolver;
    }
    /**
     * Resolve Expression to a TypeDecl
     */
    void resolve(Expression n) {
        if(n.isA!TypeDecl) {
            resolve(n.as!TypeDecl);
            return;
        }
        switch(n.id()) {
            case NodeID.Call: resolve(n.as!Call); break;
            case NodeID.Identifier: resolve(n.as!Identifier); break;
            default:
                resolver.addProblem("Expecting a type", n);
                break;
        }
    }
    /**
     * Resolve Identifier to a TypeDecl
     */
    void resolve(Identifier n) {
        if(!n.isResolved()) return;

        resolver.fold(n, n.target.getType().clone());
    }
    /**
     * Resolve Call to a TypeDecl (the return type of the called function)
     */
    void resolve(Call n) {
        if(!n.isResolved()) return;

        auto func = n.target.getType();
        if(!func.isA!FunctionDecl) return;

        auto funcLiteral = n.target.value().as!FunctionLiteral;
        if(!funcLiteral) return;

        if(funcLiteral.numStatements()==0) {
            // must be void
        }
        if(funcLiteral.numStatements()==1) {
            auto stmt = funcLiteral.statements()[0];
            auto ret  = stmt.as!Return;
            if(ret && ret.hasExpression()) {
                auto expr = ret.expression().asTypeDecl();
                if(expr) {
                    resolver.fold(n, expr.clone());
                }
            }
        }
    }

    void resolve(TypeDecl t) {
        if(t.isResolved()) return;


    }
    void resolve(TypeExpression t) {
        if(t.isResolved()) return;

        auto expr = t.expression();

        /* Wait for the expression to be resolved first */
        if(!expr.isResolved()) return;

        auto id = expr.as!Identifier;
        if(id) {
            /* Look for a VariableDecl with name == id.name */
            auto var = resolver.findDeclaration(id);
            if(var && var.isResolved()) {
                t.var = var;
                var.numRefs++;
                resolver.fold(t.firstChild(), var.type().clone());
                return;
            }
        }

        /* If we are pointing to another TypeExpression, hop nearer to the actual type */
        // if(t.target && t.targetType().isA!TypeExpression && t.targetType().isResolved()) {

        //     t.ptrDepth += t.targetType().ptrDepth;

        //     auto targetTypeExpression = t.targetType().as!TypeExpression;

        //     t.target.numRefs--;
        //     t.target = targetTypeExpression.target;
        //     t.target.numRefs++;

        //     return;
        // }
    }
private:
    // void resolve(TypeDecl type, NullLiteral null_) {
    //     // NullLiteral
    //     //      type
    //     auto parent = null_.parent();

    //     switch(parent.id) {
    //         case NodeID.Cast:
    //             auto cast_ = parent.as!Cast;
    //             if(cast_.getType().isResolved()) {
    //                 resolver.fold(type, cast_.getType().clone());
    //             }
    //             break;
    //         default: throw new Error("resolve(TypeDecl,NullLiteral) - Unhandled parent %s".format(parent.id));
    //     }
    // }
    // void resolve(TypeDecl type, UnresolvedInitialiser ini) {
    //     // UnresolvedInitialiser
    //     //      type
    //     auto parent = ini.parent();


    // }
    // void resolve(TypeDecl type, FunctionDecl func) {

    //     auto parent = func.parent();

    //     switch(parent.id) {
    //         case NodeID.VariableDecl:
    //             auto var = parent.as!VariableDecl;

    //             if(var.isTheType(func)) {

    //                 if(func.isTheReturnType(type)) {

    //                     if(var.value().isA!DefaultValue) {
    //                         /* Assume void */
    //                         resolver.fold(type, new TypeDecl(TypeKind.VOID).at(type));
    //                     }
    //                 }
    //             }
    //             break;
    //         default: throw new Error("resolve(TypeDecl,FunctionDecl) - Unhandled parent %s".format(parent.id));
    //     }
    // }
}