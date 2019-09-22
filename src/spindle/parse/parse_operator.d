module spindle.parse.parse_operator;

import spindle.all;

final class ParseOperator {
private:
    Parser parser;
public:
    this(Parser parser) {
        this.parser = parser;
    }
    Operator parse() {
        /// '>' is tokenised to separate tokens to ease parsing of nested parameterised templates.
        /// Account for this here:
        // >   = GT
        // >>  = SHR
        // >>> = USHR
        if(parser.kind()==TokenKind.RANGLE) {
            if(parser.peek(1).kind==TokenKind.RANGLE) {
                if(parser.peek(2).kind==TokenKind.RANGLE) {
                    parser.skip(3);
                    return Operator.USHR;
                }
                parser.skip(2);
                return Operator.SHR;
            }
        }

        // if(parser.kind()==TokenKind.LSQUARE) {
        //     if(parser.peek(1).kind()==TokenKind.RSQUARE) {
        //         t.skip(2);
        //         return Operator.INDEX;
        //     }
        // }

        if(parser.kind()==TokenKind.ID) {
            switch(parser.value()) {
                case "and":
                    parser.skip();
                    return Operator.BOOL_AND;
                case "or":
                    parser.skip();
                    return Operator.BOOL_OR;
                case "neg":
                    parser.skip();
                    return Operator.NEG;
                default: return Operator.NONE;
            }
        }

        auto op = parser.kind().toOperator();
        if(op!=Operator.NONE) {
            parser.skip();
        }
        return op;
    }
}
