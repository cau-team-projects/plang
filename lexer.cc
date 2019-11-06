#include "lexer.hh"

Lexer::Lexer():
yyFlexLexer{std::cin, std::cout}
{}

Lexer::~Lexer()
{}
