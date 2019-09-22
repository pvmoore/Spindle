module spindle.ast.expr.types.enum_type_kind;

import spindle.all;

enum TypeKind : uint {
    UNKNOWN,

    VOID,

    BOOL,
    BYTE,
    SHORT,
    INT,
    LONG,
    FLOAT,
    DOUBLE,

    ARRAY,
    STRUCT,
    FUNCTION
}

TypeKind toTypeKind(string s) {
    switch(s) with(TypeKind) {
        case "void": return VOID;
        case "bool": return BOOL;
        case "byte": return BYTE;
        case "short": return SHORT;
        case "int": return INT;
        case "long": return LONG;
        case "float": return FLOAT;
        case "double": return DOUBLE;
        case "struct": return STRUCT;
        case "fn": return FUNCTION;
        case "array": return ARRAY;
        default: return UNKNOWN;
    }
}

bool isUnknown(TypeKind k) {
    return k == TypeKind.UNKNOWN;
}
bool isBool(TypeKind k) {
    return k==TypeKind.BOOL;
}
bool isVoid(TypeKind k) {
    return k==TypeKind.VOID;
}
bool isInteger(TypeKind k) {
    switch(k) with(TypeKind) {
        case BYTE:
        case SHORT:
        case INT:
        case LONG:
            return true;
        default: return false;
    }
}
bool isReal(TypeKind k) {
    switch(k) with(TypeKind) {
        case FLOAT:
        case DOUBLE:
            return true;
        default: return false;
    }
}
bool isStruct(TypeKind k) {
    return k==TypeKind.STRUCT;
}
bool isFunction(TypeKind k) {
    return k==TypeKind.FUNCTION;
}
bool isABuiltinType(string s) {
    switch(s) {
        case "void":
        case "bool":
        case "byte":
        case "short":
        case "int":
        case "long":
        case "float":
        case "double":
        case "fn":
        case "struct":
        case "array":
            return true;
        default: return false;
    }
}