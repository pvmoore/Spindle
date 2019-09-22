module spindle.config;

import spindle.all;

final class Config {
    mixin(property!(string, "mainFilename", true, true));
    mixin(property!(string, "srcDirectory", true));

    /** Setters */
    void srcDirectory(string v) {
        this._srcDirectory = toCanonicalDirectory(v);
    }

    string entryFunctionName() { return "main"; }

    override string toString() {
        return
            ("srcDirectory ... %s\n"~
             "mainFilename ... %s")
            .format(
                _srcDirectory,
                _mainFilename
            );
    }

    string getModuleNameFromPath(string path) {
        log("getModuleNameFromPath(%s)", path);

        string name = path[_srcDirectory.length..$];
        name = From!"std.path".stripExtension(name);
        name = From!"std.array".replace(name, "/", ".");
        log("name = '%s'", name);
        return name;
    }
    string getPathFromModuleName(string name) {
        string path = From!"std.array".replace(name, ".", "/");
        return srcDirectory ~ path ~ ".pup";
    }
}