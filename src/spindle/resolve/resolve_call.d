module spindle.resolve.resolve_call;

import spindle.all;

private enum LOG = true;

final class ResolveCall {
private:
    Resolver resolver;
    FileLogger fileLogger;
public:
    this(Resolver resolver) {
        this.resolver  = resolver;
        static if(LOG) {
            this.fileLogger = new FileLogger(".logs/call.log");
            this.fileLogger.setEagerFlushing(true);
        }
    }
    void resolve(Call call) {
        if(call.isResolved()) return;
        if(call.target) return;

        log("Looking for %s:%s '%s'", resolver.module_.name, call.line, call.name);

        /* Collect all VariableDecls with the correct name */
        auto matches = resolver.findDeclarations(call, call.name);
        log(matches);

        /* We need to know which vars are FunctionDecls */
        if(!allTypesAreTypeDecls(matches)) { log(".. Waiting for TypeDecls"); return; }

        filterOutNonFunctions(matches);
        filterOutWrongNumParams(matches, call);

        /* Now we need to know all the func parameter and call arg types */
        if(!allTypesAreResolved(matches)) { log(".. Waiting for type resolution"); return; }
        if(!call.arguments().areResolved()) { log(".. Waiting for argument resolution"); return; }

        filterOutWhereNamesDontMatch(matches, call);

        /* Select an exact parameter/argument match if possible */
        auto exactMatch = selectExactMatch(matches, call);
        if(exactMatch) {
            selectMatch(exactMatch, call);
            return;
        }

        filterOutNonPartialMatches(matches, call);

        if(matches.length==1) {
            selectMatch(matches.values()[0], call);
        } else if(matches.length==0) {
            // todo - no match
            resolver.spindle.addProblem(resolver.module_, "Function '%s' not found".format(call.name), call);
        } else {
            // todo - ambiguous
            resolver.spindle.addProblem(resolver.module_, "Ambiguous call", call);
        }
    }
private:
    void log(A...)(string fmt, A args) {
        static if(LOG) fileLogger.log(format(fmt, args));
    }
    void log(Set!VariableDecl matches) {
        static if(!LOG) return;
        log(".. %s name matches found:", matches.length);
        foreach(v; matches.values()) {
            auto f = v.getType().as!FunctionDecl;
            if(f) {
                log(".. fn(%s)", .toString(f.paramNames(), f.paramTypes()));
            } else {
                log(".. %s", v.getType());
            }
        }
    }
    void selectMatch(VariableDecl match, Call call) {
        call.target = match;
        resolver.setModified(call);
        log(".. Selected match: %s", match);
    }
    void filterOutNonFunctions(Set!VariableDecl matches) {
        foreach(v; matches.values().dup) {
            if(!v.getType().isFunction()) {
                matches.remove(v);
                log(".. Removed %s (non-function %s)", v, v.getType());
            }
        }
    }
    void filterOutWrongNumParams(Set!VariableDecl matches, Call call) {
        foreach(v; matches.values().dup) {
            auto f = v.getType().asFunctionDecl();
            if(call.numArguments() != f.numParams) {
                matches.remove(v);
                log(".. Removed %s (num params %s != %s)", v, f.numParams, call.numArguments());
            }
        }
    }
    /**
     * The name and the number of args are right. Remove all matches where the arg
     * does not at least partially match the param.
     */
    void filterOutNonPartialMatches(Set!VariableDecl matches, Call call) {
        foreach(v; matches.values().dup) {
            auto f = v.getType().asFunctionDecl();
            assert(f.isResolved());
            assert(f.numParams==call.numArguments());

            if(!call.argTypes().canImplicitlyCastTo(f.paramTypes())) {
                matches.remove(v);
                log(".. Removed %s (args do not implicitly convert)", f);
            }
        }
    }
    /**
     * If names are supplied in the call, they must match the function parameter names.
     */
    void filterOutWhereNamesDontMatch(Set!VariableDecl matches, Call call) {
        if(!call.hasNamedArguments() || call.numArguments()==0) return;

        foreach(v; matches.values().dup) {
            auto f = v.getType().asFunctionDecl();
            assert(f.isResolved());
            assert(f.numParams==call.numArguments());
            auto pnames = f.paramNames();

            foreach(i, name; call.argNames) {
                if(name != pnames[i]) {
                    matches.remove(v);
                    log(".. Removed %s (named arguments are wrong)", f);
                }
            }
        }
    }
    VariableDecl selectExactMatch(Set!VariableDecl matches, Call call) {
        foreach(v; matches.values()) {
            auto f = v.getType().asFunctionDecl();
            assert(f.isResolved());
            assert(f.numParams==call.numArguments());

            if(call.argTypes().exactlyMatch(f.paramTypes())) {
                log(".. Exact match found: %s", v);
                return v;
            }
        }
        return null;
    }
}