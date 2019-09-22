module spindle.spindle;

import spindle.all;

final class Spindle {
private:
    final static class ModuleBundle {
        Module module_;
        Parser parser;
        Resolver resolver;
        Emitter emitter;
        this(Module m, Parser p, Resolver r, Emitter e) {
            this.module_ = m; this.parser = p; this.resolver = r; this.emitter = e;
        }
    }
    AbsProblem[] problems;
public:
    Config config;
    ModuleBundle[string /* path */] modules;
    Module mainModule;

    this(Config config) {
        this.config = config;
    }
    AbsProblem[] process() {

        try{
            auto bundle = processFile(config.srcDirectory ~ config.mainFilename);

            for(auto i = 0; i<6; i++) {
                auto status = bundle.resolver.resolve();
                log("resolved=%s modified=%s AST=", status.isResolved, status.wasModified);

                bundle.module_.dumpToLog();

                if(status.isResolved && !status.wasModified) {
                    break;
                }
                if(problems.length>0) {
                    break;
                }
                if(!status.wasModified) {
                    addProblem(new UnresolvedSymbols(bundle.module_));
                    break;
                }
            }
        }catch(From!"core.exception".AssertError e) {
            addProblem(new CompilerProblem("Assertion failed in file %s at line %s : %s".format(e.file, e.line, e.msg)));
            dbg("info=%s", e.info);
        }catch(Throwable t) {
            addProblem(new CompilerProblem(t));
        }finally{
            flushLog();
            flushConsole();
        }

        return problems;
    }
    void setRequiredModule(string name) {
        auto path = config.getPathFromModuleName(name);
        log("required module: '%s' -> '%s'", name, path);
    }
    void addProblem(Module m, char ch, int line, int column) {
        problems ~= new LexProblem(m, ch, line, column);
    }
    void addProblem(Module m, string message, ASTNode node) {
        problems ~= new NodeProblem(m, message, node);
    }
    void addProblem(AbsProblem p) {
        problems ~= p;
    }
private:
    ModuleBundle processFile(string path) {
        if(modules.containsKey(path)) {
            return modules[path];
        }

        if(!From!"std.file".exists(path)) throw new Error("File '%s' does not exist".format(path));

        auto module_  = new Module;
        module_.name = config.getModuleNameFromPath(path);
        module_.path = path;

        auto lexer = new Lexer(this, module_);
        module_.tokens = lexer.lex(path);

        auto parser     = new Parser(this, module_);
        auto resolver   = new Resolver(this, module_);
        auto emitter    = new Emitter(this, module_);
        auto bundle     = new ModuleBundle(module_, parser, resolver, emitter);

        modules[path] = bundle;
        log("Created %s", module_);

        if(modules.length==1) {
            module_.isMainModule = true;
            mainModule = module_;
        }

        parser.collectPublicSymbols();
        parser.buildAST();

        module_.dumpToLog();

        return bundle;
    }
}