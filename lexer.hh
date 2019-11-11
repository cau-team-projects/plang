#ifndef LEXER_HH
#define LEXER_HH

#ifndef yyFlexLexerOnce
#include <FlexLexer.h>
#endif
#include "parser.tab.hh"

class Lexer: public yyFlexLexer {
public:
    explicit Lexer();
    virtual ~Lexer();
    yy::Parser::token_type lex(
        yy::Parser::semantic_type* yylval,
        yy::Parser::location_type* yylloc
    );
};

#endif
