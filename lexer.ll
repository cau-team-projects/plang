%{
#include <cstdio>
#include <memory>
#include <string>
#include "lexer.hh"
#include "parser.tab.hh"
#undef YY_DECL
#define YY_DECL \
Parser::token_type \
Lexer::lex( \
  Parser::semantic_type* yylval, \
  Parser::location_type* yylloc \
)

using Token = Parser::token;
#define yyterminate() return Token::END
%}
%option nodefault
%option noyywrap
%option nounput
%option c++
%option yyclass="Lexer"
%%

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
"\n" { return Token::LF; }

"int" { return Token::INT; }
"float" { return Token::FLOAT; }
"mainprog" { return Token::MAIN; }
"function" { return Token::FUNC; }
"procedure" { return Token::PROC; }
"begin" { return Token::BEG; }
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

[A-z_][A-z0-9_]* {
    printf("ID: %s\n", yytext);
    yylval->emplace<std::string>(yytext);
    return Token::ID;
}

[+-]?[0-9]+ {
    printf("INTVAL: %s\n", yytext);
    yylval->emplace<int>(std::stoi(yytext));
    return Token::INTVAL;
}

[+-]?([0-9]+\.[0-9]+|\.[0-9]+|[0-9]+\.) {
    printf("FLOATVAL: %s\n", yytext);
    yylval->emplace<double>(std::stod(yytext));
    return Token::FLOATVAL;
}

. { printf("ANY: %s\n", yytext); }

%%
#ifdef yylex
#undef yylex
#endif
