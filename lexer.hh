#ifndef LEXER_HH
#define LEXER_HH

#ifndef yyFlexLexerOnce
#include <FlexLexer.h>
#endif
#include <iostream>
#include "parser.tab.hh"

using Parser = yy::Parser;

class Lexer: public yyFlexLexer {
public:
    explicit Lexer(std::istream& in = std::cin, std::ostream& out = std::cout);
    virtual ~Lexer();
    Parser::token_type lex(
        Parser::semantic_type* yylval,
        Parser::location_type* yylloc
    );
};

#endif
