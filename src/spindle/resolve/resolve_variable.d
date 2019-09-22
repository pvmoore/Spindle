module spindle.resolve.resolve_variable;

import spindle.all;

final class ResolveVariableDecl {
private:
    Resolver resolver;
public:
    this(Resolver resolver) {
        this.resolver  = resolver;
    }
    void resolve(VariableDecl n) {
        if(n.isResolved()) return;

        auto theType  = n.type();
        auto theValue = n.value();

        if(!theType.isA!TypeDecl) {
            resolver.resolveToType(theType);
            return;
        }

        if(!theType.isResolved()) {
            /* Get the type from the value */
            if(theValue.isResolved()) {
                resolver.fold(theType, theValue.getType().clone());

            }
        }
    }
}