module spindle.emit.emitter;

import spindle.all;

final class Emitter {
private:
    Spindle spindle;
    Module module_;
public:
    this(Spindle p, Module m) {
        this.spindle = p;
        this.module_ = m;
    }
    void transpile() {
        log("Transpiling %s", module_);


    }
}