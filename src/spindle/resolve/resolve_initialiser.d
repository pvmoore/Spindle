module spindle.resolve.resolve_initialiser;

import spindle.all;

/**
 * This needs to be converted into one of:
 *      - ArrayLiteral
 *      - StructInitialiser
 *      - FunctionLiteral
 *      - Cast | NullLiteral | NumberLiteral
 */
final class ResolveInitialiser {
private:
    Resolver resolver;
public:
    this(Resolver resolver) {
        this.resolver  = resolver;
    }
    void resolve(UnresolvedInitialiser n) {
        auto type = n.getType();

        if(!type) {
            return;
        }

        /* We now have some sort of TypeDecl */

        if(type.isA!TypeExpression && !type.as!TypeExpression.isResolved()) {
            /* We need more info */
            return;
        }

        bool isPtr = (type.isFunction() && type.ptrDepth>1) ||
                     (!type.isFunction() && type.isPtr());

        if(isPtr) {
            convertToCastNullOrNumber(n, type);
        } else if(type.isArray()) {
            convertToArrayLiteral(n);
        } else if(type.isStruct()) {
            convertToStructLiteral(n);
        } else if(type.isFunction()) {
            convertToFunctionLiteral(n);
        } else {
            convertToCastNullOrNumber(n, type);
        }
    }
private:
    void convertToArrayLiteral(UnresolvedInitialiser n) {
        auto ini  = new ArrayLiteral().at(n);
        ini.add(n.lastChild());
        n.transferAllChildrenTo(ini);
        resolver.fold(n, ini);
    }
    void convertToCastNullOrNumber(UnresolvedInitialiser n, TypeDecl type) {

        /* Type but no initialiser expression */
        if(n.numChildren()==1) {

            if(type.isPtr()) {
                /* Convert to NullLiteral */
                auto nn = new NullLiteral().at(n);
                nn.add(n.firstChild());
                resolver.fold(n, nn);
                return;
            }

            if(type.isVoid()) {
                resolver.spindle.addProblem(resolver.module_, "void type has no default value", n);
                return;
            }

            /* Convert to NumberLiteral */
            NumberLiteral nn;
            if(type.isBool()) {
                nn = new NumberLiteral(false).at(n);
            } else if(type.isInteger()) {
                nn = new NumberLiteral(0, type.kind).at(n);
            } else {
                nn = new NumberLiteral(0.0, type.kind).at(n);
            }
            resolver.fold(n, nn);

        } else if(n.numChildren()==2) {
            /*
             * - Convert to Cast.
             * - Swap the children so that the type is now first
             */
            auto nn      = new Cast().at(n);
            auto theType = n.lastChild();
            if(!theType.isA!TypeDecl) {
                theType = new TypeExpression().at(theType).add(theType);
            }
            nn.add(theType);
            nn.add(n.firstChild());
            resolver.fold(n, nn);

        } else {
            resolver.spindle.addProblem(resolver.module_, "Expecting a single initialisation expression", n);
        }
    }
    void convertToStructLiteral(UnresolvedInitialiser n) {
        auto ini = new StructLiteral().at(n);
        ini.add(n.lastChild());
        n.transferAllChildrenTo(ini);
        resolver.fold(n, ini);
    }
    void convertToFunctionLiteral(UnresolvedInitialiser n) {
        auto ini  = new FunctionLiteral().at(n);
        ini.add(n.lastChild());
        n.transferAllChildrenTo(ini);
        resolver.fold(n, ini);
    }
}