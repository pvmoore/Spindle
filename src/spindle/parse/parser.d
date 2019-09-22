module spindle.parse.parser;

import spindle.all;

final class Parser {
private:
    Token[] tokens;
    int pos;
public:
    Spindle spindle;
    Module module_;
    ParseStatement stmtParser;
    ParseExpression exprParser;
    ParseType typeParser;
    ParseOperator operatorParser;
    ParseLiteral literalParser;

    this(Spindle s, Module module_) {
        this.spindle        = s;
        this.module_        = module_;
        this.tokens         = module_.tokens;
        this.stmtParser     = new ParseStatement(this);
        this.exprParser     = new ParseExpression(this);
        this.typeParser     = new ParseType(this);
        this.operatorParser = new ParseOperator(this);
        this.literalParser  = new ParseLiteral(this);
    }
    /**
     * Look through tokens for public types and functions.
     * Add them to module_.
     */
    void collectPublicSymbols() {
        // todo
    }
    /**
     * Build the initial AST.
     */
    void buildAST() {
        log("Parsing %s", module_);

        int count = 0;
        while(!eof()) {
             stmtParser.parse(module_);
             count++;
        }
        log("parsed %s stmts", count);
    }

/** Token navigation below here */

    Token peek(int offset=0) {
        if(pos+offset<tokens.length) return tokens[pos+offset];
        return NO_TOKEN;
    }
    int position() { return pos; }
    int length()   { return tokens.length.as!int; }
    bool eof()     { return pos >= tokens.length; }
    auto get()     { return peek(); }
    auto kind()    { return peek().kind; }
    auto value()   { return peek().value ; }
    auto line()    { return peek().line; }
    auto column()  { return peek().column; }
    bool isOnSameLine() { return line() == peek(-1).line; }
    void skip(int count=1)   { pos+=count;}
    void skip(TokenKind k) {
        if(kind()!=k) assert(false);
        skip();
    }
    void skip(string kw) {
        if(value()!=kw) assert(false);
        skip();
    }
    void skipIf(TokenKind k) {
        if(kind()==k) skip();
    }
    void expectOneOf(TokenKind[] kinds...) {
        auto actual = kind();
        foreach(k; kinds) {
            if(k==actual) return;
        }
        assert(false);
    }
    string getValueAndSkip(int count=1) { string v = value(); skip(count); return v; }

    int findRBR(int offset = 0) {
        int br;
        for(; pos+offset < tokens.length; offset++) {
            auto k = tokens[pos+offset].kind;
            switch(k) with(TokenKind) {
                case LBR: br++; break;
                case RBR: if(--br==0) return offset; else break;
                default: break;
            }
        }
        return -1;
    }
    void addProblem(string message, ASTNode node) {
        spindle.addProblem(module_, message, node);
    }
}