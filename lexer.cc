#include "lexer.hh"

Lexer::Lexer(std::istream& in, std::ostream& out):
yyFlexLexer{in, out}
{
    yy_flex_debug = true;
}

Lexer::~Lexer()
{}
