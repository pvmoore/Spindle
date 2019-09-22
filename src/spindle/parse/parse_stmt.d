module spindle.parse.parse_stmt;

import spindle.all;

final class ParseStatement {
private:
    Parser parser;
public:
    this(Parser parser) {
        this.parser = parser;
    }
    void parse(ASTNode parent) {
        //writefln("parse statement parent=%s %s", parent, parser.get());

        switch(parser.kind()) with(TokenKind) {
            case ID:
                switch(parser.value()) {
                    case "return":
                        parseReturn(parent);
                        return;
                    default:
                        if(parser.peek(1).kind == EQUALS || parser.peek(1).kind == COLON) {
                            /* name = */
                            parseVariable(parent);
                            return;
                        }
                        break;
                }
                break;
            default: break;
        }

        /* Assume it's an Expression */
        parser.exprParser.parseIsolated(parent);
    }
    /**
     * id [ ':' TypeDecl ] [ '=' Expression ]
     */
    void parseVariable(ASTNode parent) {
        //writefln("parseVariable parent=%s %s", parent, parser.get());
        assert(parser.kind() == TokenKind.ID);

        auto v = new VariableDecl().at(parser);
        parent.add(v);

        v.name = parser.getValueAndSkip();

        if(parser.kind()==TokenKind.COLON) {
            parser.skip();
            parser.exprParser.parseFirst(v);
        } else {
            v.add(new TypeDecl(TypeKind.UNKNOWN).at(parser));
        }
        if(parser.kind()==TokenKind.EQUALS) {
            parser.skip();

            /* Handle pub */
            if(parser.kind()==TokenKind.ID && parser.value()=="pub") {
                v.isPublic = true;
                parser.skip();
            }

            parser.exprParser.parse(v);
        } else {
            v.add(new DefaultValue().at(parser));
        }
        //writefln("variable %s %s", v, parser.get());
    }
    /**
     * "return" [ Expression ]
     */
    void parseReturn(ASTNode parent) {
        auto n = new Return().at(parser);
        parent.add(n);

        parser.skip("return");

        if(parser.isOnSameLine()) {
            parser.exprParser.parse(n);
        }
    }
}