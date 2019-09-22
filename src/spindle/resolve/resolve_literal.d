module spindle.resolve.resolve_literal;

import spindle.all;

final class ResolveLiteral {
private:
    Resolver resolver;
public:
    this(Resolver resolver) {
        this.resolver  = resolver;
    }
    void resolve(ArrayLiteral n) {
        if(n.isResolved()) return;

        ArrayDecl array = n.type();
        if(!array.elementType().isResolved()) {
            todo();
        }
        if(!array.count().isResolved()) {
            int count = n.numExpressions();

            if(array.numChildren()==1) {
                array.add(new NumberLiteral(count, TypeKind.INT));
                resolver.setModified(array);
            } else {
                auto countEle = array.count();
                resolver.fold(array.count(), new NumberLiteral(count, TypeKind.INT).at(countEle));
            }
        }
    }
    void resolve(FunctionLiteral n) {
        if(n.isResolved()) return;

        TypeDecl retType = n.type().returnType();
        if(retType.kind.isUnknown()) {
            /* Determine the return type */
            TypeDecl t;
            n.recurseIf!Return((r) {
                if(!r.isResolved()) return;

                if(r.hasExpression()) {
                    t = t ? getBestFit(t, r.getType()) : r.getType();
                } else {
                    t = t ? getBestFit(t, new TypeDecl(TypeKind.VOID)) : new TypeDecl(TypeKind.VOID);
                }
            });
            t = (t ? t.clone().as!TypeDecl : new TypeDecl(TypeKind.VOID)).at(retType);
            resolver.fold(retType, t);
        }
    }
    void resolve(NullLiteral n) {
        if(n.isResolved()) return;


    }
    void resolve(NumberLiteral n) {
        if(n.isResolved()) return;

    }
    void resolve(StringLiteral n) {
        if(n.isResolved()) return;

    }
    void resolve(StructLiteral n) {
        if(!n.type().isResolved()) return;

        auto struct_ = n.type();



    }
}