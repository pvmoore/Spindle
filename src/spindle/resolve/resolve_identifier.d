module spindle.resolve.resolve_identifier;

import spindle.all;

final class ResolveIdentifier {
private:
    Resolver resolver;
public:
    this(Resolver resolver) {
        this.resolver  = resolver;
    }
    void resolve(Identifier n) {
        if(n.target) return;

        auto var = resolver.findDeclaration(n);
        if(var) {
            n.target = var;
            var.numRefs++;
            resolver.setModified(n);
        } else {
            dbg("nope %s", n.name);
        }
    }
}