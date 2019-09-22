module spindle.lex.token_kind;

import spindle.all;

enum TokenKind : uint {
    NONE,
    ID,
    NUMBER,
    STRING,

    EQUALS,         // =
    ASTERISK,       // *
    PLUS,           // +
    HYPHEN,         // -
    RSLASH,         // /
    PERCENT,        // %
    PIPE,           // |
    HAT,            // ^
    AMPERSAND,      // &
    TILDE,          // ~

    EQUALS2,        // ==
    COLON_EQ,       // :=
    EXCLAIM_EQ,     // !=
    LANGLE_EQ,      // <=
    RANGLE_EQ,      // >=
    STAR_EQ,        // *=
    RSLASH_EQ,      // /=
    PLUS_EQ,        // +=
    HYPHEN_EQ,      // -=
    PERCENT_EQ,     // %=
    PIPE_EQ,        // |=
    AMPERSAND_EQ,   // &=
    HAT_EQ,         // ^=

    LANGLE2,        // <<
    LANGLE2_EQ,     // <<=
    RANGLE2_EQ,     // >>=
    RANGLE3_EQ,     // >>>=

    //RANGLE2,        // >>   These two are done in code to allow for Type<Type<Type>> <-- here
    //RANGLE3,        // >>>

    COLON,          // :
    SEMICOLON,      // ;
    COMMA,          // ,
    EXCLAIM,        // !
    DOT,            // .
    HASH,           // #
    QUESTION,       // ?
    RT_ARROW,       // ->

    LBR,            // (
    RBR,            // )
    LCURLY,         // {
    RCURLY,         // }
    LANGLE,         // <
    RANGLE,         // >
    LSQUARE,        // [
    RSQUARE,        // ]
}

string stringOf(TokenKind k) {
    final switch(k) with(TokenKind) {
        case NONE : return "NONE";
        case ID: return "ID";
        case NUMBER: return "NUMBER";
        case STRING: return "STRING";
        case EQUALS: return "=";
        case ASTERISK: return "*";
        case PLUS: return "+";
        case HYPHEN: return "-";
        case RSLASH: return "/";
        case PERCENT: return "%";
        case PIPE: return "|";
        case HAT: return "^";
        case AMPERSAND: return "&";
        case TILDE: return "~";
        case EQUALS2: return "==";
        case COLON_EQ: return ":=";
        case EXCLAIM_EQ: return "!=";
        case LANGLE_EQ: return "<=";
        case RANGLE_EQ: return ">=";
        case STAR_EQ: return "*=";
        case RSLASH_EQ: return "/=";
        case PLUS_EQ: return "+=";
        case HYPHEN_EQ: return "-=";
        case PERCENT_EQ: return "%=";
        case PIPE_EQ: return "|=";
        case AMPERSAND_EQ: return "&=";
        case HAT_EQ: return "^=";
        case LANGLE2:    return "<<";
        case LANGLE2_EQ: return "<<=";
        case RANGLE2_EQ: return ">>=";
        case RANGLE3_EQ: return ">>>=";
        case COLON: return ":";
        case SEMICOLON: return ";";
        case COMMA: return ",";
        case EXCLAIM: return "!";
        case DOT: return ".";
        case HASH: return "#";
        case QUESTION: return "?";
        case RT_ARROW: return "->";
        case LBR: return "(";
        case RBR: return ")";
        case LCURLY: return "{";
        case RCURLY: return "}";
        case LANGLE: return "<";
        case RANGLE: return ">";
        case LSQUARE: return "[";
        case RSQUARE: return "]";
    }
}
uint lengthOf(TokenKind k) {
    final switch(k) with(TokenKind) {
        case NONE :
        case ID:
        case NUMBER:
        case STRING:
            return 0;
        case EQUALS:
        case ASTERISK:
        case PLUS:
        case HYPHEN:
        case RSLASH:
        case PERCENT:
        case PIPE:
        case HAT:
        case AMPERSAND:
        case TILDE:
        case COLON:
        case SEMICOLON:
        case COMMA:
        case EXCLAIM:
        case DOT:
        case HASH:
        case QUESTION:
        case LBR:
        case RBR:
        case LCURLY:
        case RCURLY:
        case LANGLE:
        case RANGLE:
        case LSQUARE:
        case RSQUARE:
            return 1;
        case EQUALS2:
        case COLON_EQ:
        case EXCLAIM_EQ:
        case LANGLE_EQ:
        case RANGLE_EQ:
        case STAR_EQ:
        case RSLASH_EQ:
        case PLUS_EQ:
        case HYPHEN_EQ:
        case PERCENT_EQ:
        case PIPE_EQ:
        case AMPERSAND_EQ:
        case HAT_EQ:
        case LANGLE2:
        case RT_ARROW:
            return 2;
        case LANGLE2_EQ:
        case RANGLE2_EQ:
            return 3;
        case RANGLE3_EQ:
            return 4;
    }
}
Operator toOperator(TokenKind k) {
    final switch(k) with(TokenKind) {
        case NONE :
        case ID:
        case NUMBER:
        case STRING:
             return Operator.NONE;
        case EQUALS: return Operator.ASSIGN;
        case ASTERISK: return Operator.MUL;
        case PLUS:  return Operator.ADD;
        case HYPHEN: return Operator.SUB;
        case RSLASH: return Operator.DIV;
        case PERCENT: return Operator.MOD;
        case PIPE: return Operator.BIT_OR;
        case HAT: return Operator.BIT_XOR;
        case AMPERSAND: return Operator.BIT_AND;
        case TILDE: return Operator.BIT_NOT;
        case EQUALS2: return Operator.BOOL_EQ;
        case COLON_EQ: return Operator.REASSIGN;
        case EXCLAIM_EQ: return Operator.BOOL_NE;
        case LANGLE_EQ: return Operator.LTE;
        case RANGLE_EQ: return Operator.GTE;
        case STAR_EQ: return Operator.MUL_ASSIGN;
        case RSLASH_EQ: return Operator.DIV_ASSIGN;
        case PLUS_EQ: return Operator.ADD_ASSIGN;
        case HYPHEN_EQ: return Operator.SUB_ASSIGN;
        case PERCENT_EQ: return Operator.MOD_ASSIGN;
        case PIPE_EQ: return Operator.BIT_OR_ASSIGN;
        case AMPERSAND_EQ: return Operator.BIT_AND_ASSIGN;
        case HAT_EQ: return Operator.BIT_XOR_ASSIGN;
        case LANGLE2: return Operator.SHL;
        case LANGLE2_EQ: return Operator.SHL_ASSIGN;
        case RANGLE2_EQ: return Operator.SHR_ASSIGN;
        case RANGLE3_EQ: return Operator.USHR_ASSIGN;
        case COLON: return Operator.NONE;
        case SEMICOLON: return Operator.NONE;
        case COMMA: return Operator.NONE;
        case EXCLAIM: return Operator.NONE;
        case DOT: return Operator.NONE;
        case HASH: return Operator.NONE;
        case QUESTION: return Operator.NONE;
        case RT_ARROW: return Operator.NONE;
        case LBR: return Operator.NONE;
        case RBR: return Operator.NONE;
        case LCURLY: return Operator.NONE;
        case RCURLY: return Operator.NONE;
        case LANGLE: return Operator.LT;
        case RANGLE: return Operator.GT;
        case LSQUARE: return Operator.NONE;
        case RSQUARE: return Operator.NONE;
    }
}