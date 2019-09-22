module spindle.lex.token;

import spindle.all;

__gshared const NO_TOKEN = Token(TokenKind.NONE, null, 0, 0);

struct Token {
    TokenKind kind;
    string value;
    int line;
    int column;

    uint length() {
        auto len = kind.lengthOf();
        return len == 0 ? value.length.as!int : len;
    }
    string toShortString() {
        auto len = kind.lengthOf();
        if(len>0) return kind.stringOf();
        return value;
    }
    string toString() {
        auto len = kind.lengthOf();
        auto s   = len>0 ? kind.stringOf() : "%s (%s)".format(value, kind.stringOf);
        return "[%s:%s %s]".format(line, column, s);
    }
}

string toShortString(Token[] tokens) {
    auto buf = appender!(string);
    foreach(i, t; tokens) {
        if(i>0) buf ~= ",";
        buf ~= "\n";
        buf ~= t.toShortString();
    }
    return buf.data;
}
string toLongString(Token[] tokens) {
    auto buf = appender!(string);
    foreach(i, t; tokens) {
        if(i>0) buf ~= ",";
        buf ~= "\n";
        buf ~= t.toString();
    }
    return buf.data;
}