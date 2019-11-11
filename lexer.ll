%{
#include <memory>
#include <string>
#include "lexer.hh"
#include "parser.tab.hh"
#undef YY_DECL
#define YY_DECL \
yy::Parser::token_type \
Lexer::lex( \
  yy::Parser::semantic_type* yylval, \
  yy::Parser::location_type* yylloc \
)

using Token = yy::Parser::token;
#define yyterminate() return Token::END
%}
%option nodefault
%option noyywrap
%option nounput
%option c++
%option yyclass="Lexer"
%%

%{
    yylval = lval;
%}
([\n\t\r ]+|"//".*[\n]+|"/*"([^\*]|\*[^/])*"*/") {}
[a-zA-Z][a-zA-Z0-9_]* {
    yylval->emplace<std::string>(yytext);
    return Token::ID;
}

[+-]?[0-9]+ {
    yylval->emplace<int>(std::stoi(yytext));
    return Token::INTVAL
}

[+-]?([0-9]*\.?[0-9]+|[0-9]+\.) {
    yylval->emplace<double>(std::stod(yytext));
    return Token::FLOATVAL;
}

"int" { return Token::INT; }
"float" { return Token::FLOAT; }

"+" { return Token::PLUS; }
"-" { return Token::MINUS; }
"*" { return Token::MUL; }
"/" { return Token::DIV; }
"<" { return Token::LT; }
"<=" { return Token::LE; }
">=" { return Token::GE; }
">" { return Token::GT; }
"==" { return Token::EQ; }
"!=" { return Token::NE; }
"!" { return Token::NOT; }
";" { return Token::SEMI; }
"." { return Token::DOT; }
"," { return Token::COMMA; }
"=" { return Token::ASMT; }
"(" { return Token::OP; }
")" { return Token::CP; }
"[" { return Token::OSB; }
"]" { return Token::CSB; }
":" { return Token::COLON; }
" " { return Token::SP; }
"\n" { return Token::NL; }

"mainprog" { return Token::MAIN; }
"function" { return Token::FUNC; }
"procedure" { return Token::PROC; }
"begin" { return Token::BEGIN; }
"end" { return Token::END; }
"if" { return Token::IF; }
"then" { return Token::THEN; }
"elif" { return Token::ELIF; }
"else" { return Token::ELSE; }
"nop" { return Token::NOP; }
"while" { return Token::WHILE; }
"return" { return Token::RETURN; }
"print" { return Token::PRINT; }
"for" { return Token::FOR; }
"in" { return Token::IN; }
%%
#ifdef yylex
#undef yylex
#endif
