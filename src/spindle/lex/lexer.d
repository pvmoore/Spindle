module spindle.lex.lexer;

import spindle.all;

final class Lexer {
private:
    enum MAX_IDENTIFIER_LENGTH = 1024;
    enum State {
        NORMAL,
        WHITESPACE_START,
        WHITESPACE,
        LINE_COMMENT,
        MULTILINE_COMMENT,
        STRING_START,
        STRING,
        NUMBER_START,
        NUMBER,
        CHAR_START,
        CHAR
    }
    Spindle spindle;
    Module module_;
public:
    this(Spindle s, Module m) {
        this.spindle = s;
        this.module_ = m;
    }
    Token[] lex(string filename) {
        log("Lexing %s", filename);

        auto chars = From!"std.file".read(filename).as!(char[]);

        auto tokens = appender!(Token[]);

        auto pos        = 0;
        auto line       = 0;
        auto lineStart  = 0;
        State state     = State.NORMAL;
        auto buf        = new char[MAX_IDENTIFIER_LENGTH];
        auto bufpos     = 0;

        char _peek(int offset) {
            if(pos+offset<chars.length) return chars[pos+offset];
            return 0;
        }
        void _appendBuffer(char ch) {
            if(bufpos==MAX_IDENTIFIER_LENGTH) throw new Error("Maximum identifier length reached");
            buf[bufpos++] = ch;
        }
        string _getBuffer() {
            string s = buf[0..bufpos].idup;
            bufpos = 0;
            return s;
        }
        void _addToken(TokenKind k = TokenKind.NONE) {
            if(bufpos>0) {
                auto s      = _getBuffer();
                auto column = (pos-lineStart)-s.length.as!int;
                auto kind   = k==TokenKind.NUMBER || k==TokenKind.STRING ? k : TokenKind.ID;
                tokens ~= Token(kind, s, line, column);

                if(kind!=TokenKind.ID) return;
            }
            if(k != TokenKind.NONE) {
                tokens ~= Token(k, k.stringOf(), line, pos-lineStart);
            }
        }
        bool _handleNewLine() {
            if(_peek(0)==13) { pos++; }
            if(_peek(0)==10) {
                line++;
                lineStart = pos;
                return true;
            }
            return false;
        }

loop:   while(pos<chars.length) {

            auto ch = _peek(0);

            final switch(state) with(State) {
                case LINE_COMMENT:
                    if(_handleNewLine()) {
                        state = NORMAL;
                        pos++;
                        continue loop;
                    }
                    pos++;
                    break;
                case MULTILINE_COMMENT:
                    if(ch=='*' && _peek(1)=='/') {
                        pos+=2;
                        state = NORMAL;
                        continue loop;
                    }
                    _handleNewLine();
                    pos++;
                    break;
                case WHITESPACE_START:
                    _addToken();
                    state = WHITESPACE;
                    goto case WHITESPACE;
                case WHITESPACE:
                    _handleNewLine();
                    if(ch<33) {
                        pos++;
                    } else {
                        state = NORMAL;
                        continue loop;
                    }
                    break;
                case NUMBER_START:
                    _addToken();
                    state = NUMBER;
                    goto case NUMBER;
                case NUMBER:
                    if(ch.isDigit() || (ch=='.' && _peek(1).isDigit()) ) {
                        _appendBuffer(ch);
                        pos++;
                        break;
                    } else {
                        _addToken(TokenKind.NUMBER);
                        state = NORMAL;
                        continue loop;
                    }
                case STRING_START:
                    _addToken();
                    state = STRING;
                    goto case STRING;
                case STRING:


                    break;
                case CHAR_START:
                    _addToken();
                    state = CHAR;
                    goto case CHAR;
                case CHAR:

                    break;
                case NORMAL:
                    switch(ch) {
                        case '\0':..case ' ':
                            state = WHITESPACE_START;
                            continue loop;
                        case '0':..case '9':
                            if(bufpos==0) {
                                state = NUMBER_START;
                                continue loop;
                            }
                             _appendBuffer(ch);
                            break;
                        case '\'':
                            state = CHAR_START;
                            continue loop;
                        case '\"':
                            state = STRING_START;
                            continue loop;
                        case '=':
                            if(_peek(1)=='=') {
                                 _addToken(TokenKind.EQUALS2);
                                 pos++;
                            } else {
                                _addToken(TokenKind.EQUALS);
                            }
                            break;
                        case '*':
                            if(_peek(1)=='=') {
                                _addToken(TokenKind.STAR_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.ASTERISK);
                            }
                            break;
                        case '/':
                            if(_peek(1)=='/') {
                                state = LINE_COMMENT;
                                continue loop;
                            } else if(_peek(1)=='*') {
                                state = MULTILINE_COMMENT;
                                continue loop;
                            } else {
                                _addToken(TokenKind.RSLASH);
                            }
                            break;
                        case '+':
                            if(_peek(1)=='=') {
                                _addToken(TokenKind.PLUS_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.PLUS);
                            }
                            break;
                        case '-':
                            if(_peek(1)=='=') {
                                _addToken(TokenKind.HYPHEN_EQ);
                                pos++;
                            } else if(_peek(1)=='>') {
                                _addToken(TokenKind.RT_ARROW);
                                pos++;
                            } else {
                                _addToken(TokenKind.HYPHEN);
                            }
                            break;
                        case '%':
                            if(_peek(1)=='=') {
                                _addToken(TokenKind.PERCENT_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.PERCENT);
                            }
                            break;
                        case '|':
                            if(_peek(1)=='=') {
                                _addToken(TokenKind.PIPE_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.PIPE);
                            }
                            break;
                        case '^':
                            if(_peek(1)=='=') {
                                _addToken(TokenKind.HAT_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.HAT);
                            }
                            break;
                        case '&':
                            if(_peek(1)=='=') {
                                _addToken(TokenKind.AMPERSAND_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.AMPERSAND);
                            }
                            break;
                        case '~':
                            _addToken(TokenKind.TILDE);
                            break;
                        case ':':
                            if(_peek(1)=='=') {
                                _addToken(TokenKind.COLON_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.COLON);
                            }
                            break;
                        case ';':
                            _addToken(TokenKind.SEMICOLON);
                            break;
                        case ',':
                            _addToken(TokenKind.COMMA);
                            break;
                        case '!':
                            if(_peek(1)=='=') {
                                _addToken(TokenKind.EXCLAIM_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.EXCLAIM);
                            }
                            break;
                        case '(':
                            _addToken(TokenKind.LBR);
                            break;
                        case ')':
                            _addToken(TokenKind.RBR);
                            break;
                        case '{':
                            _addToken(TokenKind.LCURLY);
                            break;
                        case '}':
                            _addToken(TokenKind.RCURLY);
                            break;
                        case '[':
                            _addToken(TokenKind.LSQUARE);
                            break;
                        case ']':
                            _addToken(TokenKind.RSQUARE);
                            break;
                        case '<':
                            // <<=
                            // <<
                            // <=
                            // <
                            if(_peek(1)=='<' && _peek(2)=='=') {
                                _addToken(TokenKind.LANGLE2_EQ);
                                pos+=2;
                            } else if(_peek(1)=='<') {
                                _addToken(TokenKind.LANGLE2);
                                pos++;
                            } else if(_peek(1)=='=') {
                                _addToken(TokenKind.LANGLE_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.LANGLE);
                            }
                            break;
                        case '>':
                            // >>>  // handled in parse_operator.d
                            // >>   // handled in parse_operator.d
                            // >>>=
                            // >>=
                            // >=
                            // >
                            if(_peek(1)=='>' && _peek(2)=='>' && _peek(3)=='=') {
                                _addToken(TokenKind.RANGLE3_EQ);
                                pos+=3;
                            } else if(_peek(1)=='>' && _peek(2)=='=') {
                                _addToken(TokenKind.RANGLE2_EQ);
                                pos+=2;
                            } else if(_peek(1)=='=') {
                                _addToken(TokenKind.RANGLE_EQ);
                                pos++;
                            } else {
                                _addToken(TokenKind.RANGLE);
                            }
                            break;
                        case '.':
                            _addToken(TokenKind.DOT);
                            break;
                        case '#':
                            _addToken(TokenKind.HASH);
                            break;
                        case '?':
                            _addToken(TokenKind.QUESTION);
                            break;
                        default:
                            _appendBuffer(ch);
                            break;
                    }
                    pos++;
                    break;
            }
        }

        log("tokens (%s) = %s", tokens.data.length, tokens.data.toLongString());
        flushLog();

        return tokens.data;
    }
}