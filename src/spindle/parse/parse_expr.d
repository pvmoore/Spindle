module spindle.parse.parse_expr;

import spindle.all;

final class ParseExpression {
private:
    Parser parser;
public:
    this(Parser parser) {
        this.parser = parser;
    }
    void parse(ASTNode parent) {
        //writefln("parse expression parent=%s %s", parent.id(), parser.get());
        parseFirst(parent);
        parseSecond(parent);
    }
    /**
     * Parse expression. Don't allow any precedence shift above parent.
     */
    void parseIsolated(ASTNode parent) {
        //writefln("parseIsolated expression parent=%s %s", parent, parser.get());

        auto n = new Parens().at(parser);

        parse(n);

        n.transferAllChildrenTo(parent);
    }
    void parseFirst(ASTNode parent) {
        //writefln("parseFirst parent=%s %s", parent.id(), parser.get());
        switch(parser.kind()) with(TokenKind) {
            case ID:
                string value = parser.value();
                if("true"==value || "false"==value) {
                    parser.literalParser.parseNumber(parent);
                    return;
                }
                if("null"==value) {
                    parseNullLiteral(parent);
                    return;
                }

                // One of:
                //      Identifier
                //      Type
                //      Identifier { ... }  --> UnresolvedInitialiser
                //      Type       { ... }  --> UnresolvedInitialiser
                //      Identifier ( ... )  --> Call
                //

                if(parser.value().isABuiltinType()) {
                    parser.typeParser.parse(parent);
                } else if(parser.peek(1).kind==TokenKind.LBR) {
                    parseCall(parent);
                } else {
                    parseIdentifier(parent);
                }
                return;
            case NUMBER:
                parser.literalParser.parseNumber(parent);
                return;
            case LBR:
                // Could be a Parens or a wrapped TypeExpression
                auto rbr = parser.findRBR(0);
                if(rbr!=-1 && parser.peek(rbr-1).kind==TokenKind.ASTERISK) {
                    parseTypeExpression(parent);
                } else {
                    parseParens(parent);
                }
                return;
            case STRING:
                todo();
                return;
            default:
                break;
        }
        flushLog();
        flushConsole();
        parser.spindle.addProblem(parser.module_, "Syntax error at %s".format(parser.get()), parent);
        //assert(false, "%s".format(parser.get()));
    }
private:
    void parseSecond(ASTNode parent) {
        //writefln("parseSecond parent=%s %s", parent.id(), parser.get());
        while(true) {
            switch(parser.kind()) with(TokenKind) {
                case NONE:
                case RCURLY:
                case RBR:
                case RSQUARE:
                case COMMA:
                case NUMBER:
                case STRING:
                case RT_ARROW:
                    //writefln("end of expr %s", parser.get());
                    /* end of expression */
                    return;
                case PLUS:
                case HYPHEN:
                case ASTERISK:
                case RSLASH:
                case PERCENT:
                case PIPE:
                case HAT:
                case AMPERSAND:
                case PLUS_EQ:
                case HYPHEN_EQ:
                case RSLASH_EQ:
                case STAR_EQ:
                case PERCENT_EQ:
                case PIPE_EQ:
                case AMPERSAND_EQ:
                case HAT_EQ:
                case EQUALS:        // =
                case EQUALS2:       // ==
                case EXCLAIM_EQ:    // !=
                case COLON_EQ:      // :=
                case LANGLE:        // <
                case RANGLE:        // >
                case LANGLE_EQ:     // <=
                case RANGLE_EQ:     // >=
                case LANGLE2_EQ:    // <<=
                case RANGLE2_EQ:    // >>=
                case RANGLE3_EQ:    // >>>=
                    parent = attach(parent, parseBinary());
                    break;
                case LCURLY:
                    parent = attach(parent, parseInitialiser(), false);
                    break;
                case ID:
                    switch(parser.value()) {
                        case "and":
                        case "or":
                            parent = attach(parent, parseBinary());
                            break;
                        case "is":
                            todo();
                            break;
                        default:
                            /* end of expression */
                            return;
                    }
                    break;
                default:
                    assert(false, "%s".format(parser.get()));
            }
        }
    }
/** */
    ASTNode attach(ASTNode parent, Expression newExpr, bool andRead = true) {
        ASTNode prev = parent;

        //writefln("attach newExpr = %s parent=", newExpr);
        //parent.dumpToConsole();

        if(prev.isA!Expression) {
            /* Adjust to account for operator precedence */
            auto prevExpr = prev.as!Expression;
            while(prevExpr.parent && newExpr.precedence() < prevExpr.precedence()) {

                if(!prevExpr.parent.isA!Expression) {
                    prev = prevExpr.parent;
                    break;
                }

                prevExpr = prevExpr.parent.as!Expression;
                prev     = prevExpr;
            }
        }

        newExpr.add(prev.lastChild());
        prev.add(newExpr);

        if(andRead) {
            parseFirst(newExpr);
        }

        return newExpr;
    }
/** */
    Expression parseBinary() {
        auto n = new Binary().at(parser);

        if("and"==parser.value()) {
            parser.skip();
            n.op = Operator.BOOL_AND;
        } else if("or"==parser.value()) {
            parser.skip();
            n.op = Operator.BOOL_OR;
        } else {
            n.op = parser.operatorParser.parse();
            if(n.op==Operator.NONE) {
            //     module_.addError(t, "Invalid operator", true);
                assert(false);
            }
        }

        return n;
    }
    // Expression parseIs() {
    //     auto i = new Is().at(parser);

    //     t.skip("is");

    //     if(t.value=="not") {
    //         t.skip("not");
    //         i.negate = true;
    //     }

    //     return i;
    // }
    /**
     * '(' Expression ')'
     */
    void parseParens(ASTNode parent) {

        auto p = new Parens().at(parser);
        parent.add(p);

        parser.skip(TokenKind.LBR);

        parse(p);

        parser.skip(TokenKind.RBR);
    }
    /**
     *  '(' Expression { '*' } ')'
     */
    void parseTypeExpression(ASTNode parent) {
        auto te = new TypeExpression().at(parser);
        parent.add(te);

        if(parser.kind==TokenKind.LBR) {
            parser.skip(TokenKind.LBR);

            parseFirst(te);

            /* Collect asterisks */
            while(parser.kind()==TokenKind.ASTERISK) {
                parser.skip();
                te.ptrDepth++;
            }

            parser.skip(TokenKind.RBR);
        } else {
            todo();
        }
    }
    /**
     * name
     */
    void parseIdentifier(ASTNode parent) {
        auto id = new Identifier(parser.getValueAndSkip()).at(parser);
        parent.add(id);
    }
    void parseNullLiteral(ASTNode parent) {
        auto n = new NullLiteral().at(parser);
        parent.add(n);
        parser.skip("null");

        n.add(new TypeDecl(TypeKind.UNKNOWN));
    }
    /**
     * name '(' [ Expression { ',' Expression } ] ')'
     */
    void parseCall(ASTNode parent) {
        auto n = new Call().at(parser);
        parent.add(n);

        n.name = parser.getValueAndSkip();

        parser.skip(TokenKind.LBR);

        while(parser.kind() != TokenKind.RBR) {

            /* name : */
            if(parser.peek(1).kind==TokenKind.COLON) {
                n.argNames ~= parser.getValueAndSkip(2);
            }
            /* Expression */
            parseIsolated(n);

            parser.expectOneOf(TokenKind.COMMA, TokenKind.RBR);
            parser.skipIf(TokenKind.COMMA);
        }

        if(n.hasNamedArguments()) {
            if(n.argNames.length != n.numArguments()) {
                parser.addProblem("If named arguments are used, they must all be named", n);
                n.argNames = null;
            }
        }

        parser.skip(TokenKind.RBR);
    }
    /**
     * '{' [ Expression { ',' Expression } ] '}'
     * '{' { Statement } '}'
     * '{' [ name ':' Expression { ',' name ':' Expression } ] '}'
     */
    UnresolvedInitialiser parseInitialiser() {

        auto ini = new UnresolvedInitialiser().at(parser);

        parser.skip(TokenKind.LCURLY);

        while(parser.kind() != TokenKind.RCURLY) {

            if(parser.peek(1).kind==TokenKind.COLON) {
                /* name : Expression */
                auto v = new VariableDecl().at(parser);
                ini.add(v);
                v.name = parser.getValueAndSkip();
                parser.skip(TokenKind.COLON);

                parser.exprParser.parse(v);
            } else {
                /* Allow Statements for now. Later, check whether a Statement is valid here */
                parser.stmtParser.parse(ini);
            }

            parser.expectOneOf(TokenKind.COMMA, TokenKind.RCURLY);
            parser.skipIf(TokenKind.COMMA);
        }
        parser.skip(TokenKind.RCURLY);

        return ini;
    }
}