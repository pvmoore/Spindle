module spindle.resolve.resolve_binary;

import spindle.all;

final class ResolveBinary {
private:
    Resolver resolver;
public:
    this(Resolver resolver) {
        this.resolver  = resolver;
    }
    void resolve(Binary n) {
        if(n.isResolved()) return;

        auto lt = n.leftType();
        auto rt = n.rightType();

        if(!lt.isResolved() || !rt.isResolved()) return;

        n.type = getBestFit(lt, rt);
        resolver.setModified(n);

        if(!n.type) {
            resolver.spindle.addProblem(resolver.module_, "Types %s and %s are incompatible".format(lt, rt), n);
        }

        /* Attempt to fold this expression */
        if(n.isResolved() && n.comptime()==Comptime.YES) {


        }
    }
}