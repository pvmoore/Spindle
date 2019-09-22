module spindle.parse.parse_type;

import spindle.all;

final class ParseType {
private:
    Parser parser;
public:
    this(Parser parser) {
        this.parser = parser;
    }
    /**
     * A primitive type or struct(...) or fn(...)
     */
    void parse(ASTNode parent) {
        TypeDecl type;
        switch(parser.value()) {
            case "bool":
                type = new TypeDecl(TypeKind.BOOL).at(parser);
                parent.add(type);
                parser.skip();
                break;
            case "byte":
                type = new TypeDecl(TypeKind.BYTE).at(parser);
                parent.add(type);
                parser.skip();
                break;
            case "short":
                type = new TypeDecl(TypeKind.SHORT).at(parser);
                parent.add(type);
                parser.skip();
                break;
            case "int":
                type = new TypeDecl(TypeKind.INT).at(parser);
                parent.add(type);
                parser.skip();
                break;
            case "long":
                type = new TypeDecl(TypeKind.LONG).at(parser);
                parent.add(type);
                parser.skip();
                break;
            case "float":
                type = new TypeDecl(TypeKind.FLOAT).at(parser);
                parent.add(type);
                parser.skip();
                break;
            case "double":
                type = new TypeDecl(TypeKind.DOUBLE).at(parser);
                parent.add(type);
                parser.skip();
                break;
            case "void":
                type = new TypeDecl(TypeKind.VOID).at(parser);
                parent.add(type);
                parser.skip();
                break;
            case "array":
                type = parseArrayDecl(parent);
                break;
            case "struct":
                type = parseStructDecl(parent);
                break;
            case "fn":
                type = parseFunctionDecl(parent);
                break;
            default:
                assert(false, "shouldn't get here");
                // type = new TypeExpression(parser.value()).at(parser);
                // parent.add(type);
                // parser.skip();
                // break;
        }
        /* Collect asterisks */
        while(parser.kind()==TokenKind.ASTERISK) {
            parser.skip();
            type.ptrDepth++;
        }
    }
private:
    /**
     * 'array' '(' Expression [ ',' Expression ] ')'
     */
    ArrayDecl parseArrayDecl(ASTNode parent) {
        auto array = new ArrayDecl().at(parser);
        parent.add(array);

        parser.skip("array");
        parser.skip(TokenKind.LBR);

        /* Type */
        parser.exprParser.parse(array);

        if(parser.kind() == TokenKind.COMMA) {
            parser.skip();

            /* Count (optional) */
            parser.exprParser.parse(array);
        }

        parser.skip(TokenKind.RBR);

        return array;
    }
    /**
     * 'struct' '('  name ':' TypeExpression { ',' name ':'  TypeExpression } ] ')'
     */
    StructDecl parseStructDecl(ASTNode parent) {
        auto struct_ = new StructDecl().at(parser);
        parent.add(struct_);

        parser.skip("struct");
        parser.skip(TokenKind.LBR);

        while(parser.kind() != TokenKind.RBR) {
            auto v = new VariableDecl().at(parser);
            struct_.add(v);

            if(parser.peek(1).kind == TokenKind.COLON) {
                /* name ':' */
                v.name = parser.getValueAndSkip(2);

                if(parser.value()=="pub") {
                    parser.skip();
                    v.isPublic = true;
                }
                /* type */
                parser.exprParser.parseFirst(v);

            } else if(parser.peek(1).kind == TokenKind.EQUALS) {
                /* name '=' */

                v.name = parser.getValueAndSkip();

                v.add(new TypeDecl(TypeKind.UNKNOWN).at(parser));

            } else {
                parser.spindle.addProblem(parser.module_, "Missing property name", v);
            }

            if(parser.kind() == TokenKind.EQUALS) {
                parser.skip();

                parser.exprParser.parse(v);
            } else {
                v.add(new DefaultValue().at(parser));
            }

            parser.expectOneOf(TokenKind.COMMA, TokenKind.RBR);
            parser.skipIf(TokenKind.COMMA);
        }
        parser.skip(TokenKind.RBR);

        assert(struct_.properyNames().length==0 || struct_.properyNames().length == struct_.numChildren);
        return struct_;
    }
    /**
     * 'fn' '(' [ VariableDecl { , VariableDecl } ] [ '->' Expression ] ')'
     */
    FunctionDecl parseFunctionDecl(ASTNode parent) {

        auto func = new FunctionDecl().at(parser);
        parent.add(func);

        parser.skip("fn");
        parser.skip(TokenKind.LBR);

        bool hasReturnType;

        /* Handle (void) and (void->) */
        if(parser.value()=="void") {
            if(parser.peek(1).kind==TokenKind.RBR ||
               parser.peek(1).kind==TokenKind.RT_ARROW)
            {
                parser.skip();
            }
        }

        while(parser.kind() != TokenKind.RBR) {

            if(parser.kind() != TokenKind.RT_ARROW) {
                auto v = new VariableDecl().at(parser);
                func.add(v);

                if(parser.peek(1).kind == TokenKind.COLON) {
                    /* name */
                    v.name = parser.getValueAndSkip();
                    parser.skip(TokenKind.COLON);

                    /* Type */
                    parser.exprParser.parse(v);
                } else {
                    /* name */
                    v.name = parser.getValueAndSkip();

                    /* Type */
                    v.add(TypeDecl.UNKNOWN);
                }

                if(parser.kind() == TokenKind.EQUALS) {
                    todo("handle default parameters");
                } else {
                    v.add(new NoValue().at(parser));
                }
                func.numParams++;
            }

            if(parser.kind() == TokenKind.RT_ARROW) {
                /* Return type */
                parser.skip();
                parser.exprParser.parse(func);

                parser.expectOneOf(TokenKind.RBR);
                hasReturnType = true;
                break;
            }

            parser.expectOneOf(TokenKind.COMMA, TokenKind.RBR);
            parser.skipIf(TokenKind.COMMA);
        }

        if(!hasReturnType) {
            /* Add unknown return type */
            func.add(new TypeDecl(TypeKind.UNKNOWN).at(parser));
        }

        parser.skip(TokenKind.RBR);

        //writefln("function %s %s", func, parser.get());
        return func;
    }
}