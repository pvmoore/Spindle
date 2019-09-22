module spindle.operator;

import spindle.all;

enum Operator {
    NONE,

    NEG,            // - (expression)
    BIT_NOT,        // ~
    BOOL_NOT,       // not

    MUL,            // *
    DIV,            // /
    MOD,            // %

    ADD,            // +
    SUB,            // -

    SHL,            // <<
    SHR,            // >>
    USHR,           // >>>

    LT,             // <
    LTE,            // <=
    GT,             // >
    GTE,            // >=

    BOOL_EQ,        // ==
    BOOL_NE,        // !=

    BIT_AND,        // &
    BIT_XOR,        // ^
    BIT_OR,         // |

    BOOL_AND,       // and
    BOOL_OR,        // or

    ASSIGN,         // =
    REASSIGN,       // :=
    MUL_ASSIGN,     // *=
    DIV_ASSIGN,     // /=
    MOD_ASSIGN,     // %=
    ADD_ASSIGN,     // +=
    SUB_ASSIGN,     // -=
    SHL_ASSIGN,     // <<=
    SHR_ASSIGN,     // >>=
    USHR_ASSIGN,    // >>>=
    BIT_AND_ASSIGN, // &=
    BIT_XOR_ASSIGN, // ^=
    BIT_OR_ASSIGN,  // |=
}
/**
 *  Higher is better
 */
int precedence(Operator o) {
    final switch(o) with(Operator) {
        //case INDEX: return 30;
        //case DOT: return 30;
        //case CALL: return 30;
        //case AS: return 25;
        //case ADDRESS_OF: return 20;
        //case VALUE_OF: return 20;
        case NEG: return 20;
        case BIT_NOT: return 20;
        case BOOL_NOT: return 20;
        case MUL: return 17;
        case DIV: return 17;
        case MOD: return 17;
        case ADD: return 14;
        case SUB: return 14;
        case SHL: return 12;
        case SHR: return 12;
        case USHR: return 12;
        case LT: return 10;
        case LTE: return 10;
        case GT: return 10;
        case GTE: return 10;
        case BOOL_EQ: return 9;
        //case IS: return 9;
        case BOOL_NE: return 9;
        case BIT_AND: return 7;
        case BIT_XOR: return 6;
        case BIT_OR: return 5;
        case BOOL_AND: return 4;
        case BOOL_OR: return 3;
        case ASSIGN: return 2;
        case REASSIGN: return 2;
        case MUL_ASSIGN: return 2;
        case DIV_ASSIGN: return 2;
        case MOD_ASSIGN: return 2;
        case ADD_ASSIGN: return 2;
        case SUB_ASSIGN: return 2;
        case SHL_ASSIGN: return 2;
        case SHR_ASSIGN: return 2;
        case USHR_ASSIGN: return 2;
        case BIT_AND_ASSIGN: return 2;
        case BIT_XOR_ASSIGN: return 2;
        case BIT_OR_ASSIGN: return 2;
        case NONE: return 0;
        //case LITERAL: return 0;
    }
}
string stringOf(Operator o) {
    final switch(o) with(Operator) {
        case NONE: return "NONE";
        case NEG: return "-";
        case BIT_NOT: return "~";
        case BOOL_NOT: return "not";
        case MUL: return "*";
        case DIV: return "/";
        case MOD: return "%";
        case ADD: return "+";
        case SUB: return "-";
        case SHL: return "<<";
        case SHR: return ">>";
        case USHR: return ">>>";
        case LT: return "<";
        case LTE: return "<=";
        case GT: return ">";
        case GTE: return ">=";
        case BOOL_EQ: return "==";
        case BOOL_NE: return "!=";
        case BIT_AND: return "&";
        case BIT_XOR: return "^";
        case BIT_OR: return "|";
        case BOOL_AND: return "and";
        case BOOL_OR: return "or";
        case ASSIGN: return "=";
        case REASSIGN: return ":=";
        case MUL_ASSIGN: return "*=";
        case DIV_ASSIGN: return "/=";
        case MOD_ASSIGN: return "%=";
        case ADD_ASSIGN: return "+=";
        case SUB_ASSIGN: return "-=";
        case SHL_ASSIGN: return "<<=";
        case SHR_ASSIGN: return ">>=";
        case USHR_ASSIGN: return ">>>=";
        case BIT_AND_ASSIGN: return "&=";
        case BIT_XOR_ASSIGN: return "^=";
        case BIT_OR_ASSIGN: return "|=";
    }
}