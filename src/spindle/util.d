module spindle.util;

import spindle.all;
import std.path : baseName, asNormalizedPath;

/**
 * Converts a path to it's canonical form and appends a trailing '/' if required.
 */
string toCanonicalDirectory(string dir) {
    auto s = asNormalizedPath(dir).array.as!string;
    s = From!"std.array".replace(s, "\\", "/");
    if(!s.endsWith("/")) s ~= "/";
    return s;
}
string simpleClassName(Object instance) {
    auto fqn = typeid(instance).name;
    auto i   = From!"std.string".lastIndexOf(fqn, '.');
    if(i!=-1) {
        fqn = fqn[i+1..$];
    }
    return fqn;
}
bool isDigit(char ch) {
    return ch>='0' && ch<='9';
}
long toLong(string s, int base = 10) {
    assert(s.length>0);

    if(s.endsWith("L")) s = s[0..$-1];
    if(s.endsWith("u")) s = s[0..$-1];

    if(base==2) return binaryToLong(s);
    if(base==16) return hexToLong(s);

    return From!"std.conv".to!long(s);
}
double toDouble(string s) {
    assert(s.length>0);

    if(s.endsWith("d")) s = s[0..$-1];
    return From!"std.conv".to!double(s);
}
long hexToLong(string hex) {
    long total;
    foreach(c; From!"std.string".toLower(hex)) {
        if(c=='_') continue;

        int n;
        if(c>='0' && c<='9') n = c-'0';
        else n = (c-'a')+10;
        total <<= 4;
        total |= n;
    }
    return total;
}
long binaryToLong(string binary) {
    long total;
    foreach(c; binary) {
        if(c=='_') continue;

        int n = c-'0';
        total <<= 1;
        total |= n;
    }
    return total;
}
