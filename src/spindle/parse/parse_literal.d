module spindle.parse.parse_literal;

import spindle.all;

final class ParseLiteral {
  private:
    Parser parser;
public:
    this(Parser parser) {
        this.parser = parser;
    }
    /**
     * 0xffu
     * 105L
     * 3.14
     * 3.14d
     */
    void parseNumber(ASTNode parent) {
        string value = parser.value();
        NumberLiteral literal;

        parser.skip();

        if(value.length==1) {
            literal = new NumberLiteral(value.toLong(), TypeKind.INT).at(parser);
        } else if("true"==value) {
            literal = new NumberLiteral(true).at(parser);
        } else if("false"==value) {
            literal = new NumberLiteral(false).at(parser);
        } else if(value[0]=='\'') {
            todo();
        } else if(value.endsWith("d")) {
            literal = new NumberLiteral(value.toDouble(), TypeKind.DOUBLE).at(parser);
        } else if(value.contains('.')) {
            literal = new NumberLiteral(value.toDouble(), TypeKind.FLOAT).at(parser);
        } else {
            /* Some sort of integer */
            TypeKind kind = TypeKind.INT;
            long longValue;

            if(value.endsWith("L")) {
                kind = TypeKind.LONG;
                value = value[0..$-1];
            }
            if(value.endsWith("u")) {
                value = value[0..$-1];
            }

            if(value.startsWith("0x")) {
                longValue = value[2..$].toLong(16);
            } else if(value.startsWith("0b")) {
                longValue = value[2..$].toLong(2);
            } else {
                longValue = value.toLong();
            }

            literal = new NumberLiteral(longValue, kind).at(parser);
        }

        parent.add(literal);
    }
    /**
     * TypeDecl '{' Expression '}'
     * int{3}
     * A{b,c}
     *
     * fn(...) '{' { Statement } '}'
     * struct(...) '{' { [name ':'] Expression [ ',' [name ':'] Expression] } '}'
     */
    // void parseInitialiser(ASTNode parent) {

    //     auto ini = new UnresolvedInitialiser().at(parser);
    //     parent.add(ini);

    //     parser.exprParser.parse(ini);

    //     assert(ini.numChildren==1);

    //     parser.skip(TokenKind.LCURLY);

    //     while(parser.kind() != TokenKind.RCURLY) {

    //         if(parser.peek(1).kind==TokenKind.COLON) {
    //             /* name : Expression */
    //             auto v = new VariableDecl().at(parser);
    //             ini.add(v);
    //             v.name = parser.getValueAndSkip();
    //             parser.skip(TokenKind.COLON);

    //             parser.exprParser.parse(v);
    //         } else {
    //             /* Allow Statements for now. Later, check whether a Statement is valid here */
    //             parser.stmtParser.parse(ini);
    //         }

    //         parser.expectOneOf(TokenKind.COMMA, TokenKind.RCURLY);
    //         parser.skipIf(TokenKind.COMMA);
    //     }
    //     parser.skip(TokenKind.RCURLY);
    // }
}