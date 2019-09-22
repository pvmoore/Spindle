module main;

import spindle.all;
import std.stdio;

void main(string[] args) {
    writefln("\nSpindle %s", VERSION);

    auto c = new Config;
    with(c) {
        srcDirectory = "test";
        mainFilename = "test.spin";
    }
    writefln("%s", c);

    auto spindle  = new Spindle(c);
    auto problems = spindle.process();

    if(problems.length==0) {
        writefln("\nOk");
    } else if(problems.length==1) {
        writefln("\nThere was an error:\n");

        writefln("%s", problems[0].toDetailedString());

    } else {
        writefln("\nThere were errors:\n");

        foreach(prob; problems) {
                writefln("%s", prob.toShortString());
            }
    }
}