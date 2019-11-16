#include "lexer.hh"

Lexer::Lexer(std::istream& in, std::ostream& out):
yyFlexLexer{in, out}
{}

Lexer::~Lexer()
{}
