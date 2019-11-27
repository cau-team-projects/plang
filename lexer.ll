%{
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
#define YY_USER_ACTION yylloc->columns(yyleng);
using Token = Parser::token;
#define yyterminate() return Token::FIN
%}
%option nodefault
%option noyywrap
%option nounput
%option stack
%option batch
%option verbose
%option debug
%option warn
%option c++
%option yyclass="Lexer"
%%

%{
    yylloc->step();
%}

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
"\t" { yylloc->step(); /*return Token::TAB;*/ }
" " { yylloc->step(); /*return Token::SP;*/ }
\r {}
\n+ { yylloc->lines(yyleng); yylloc->step(); /*return Token::LF;*/ }

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
"do" { return Token::DO; }
"return" { return Token::RETURN; }
"print" { return Token::PRINT; }
"for" { return Token::FOR; }
"in" { return Token::IN; }

[A-Za-z_][A-Za-z0-9_]* {
    yylval->emplace<std::string>(yytext);
    return Token::ID;
}

[+-]?[0-9]+ {
    try {
        yylval->emplace<int>(std::stoi(yytext));
        return Token::INTVAL;
    } catch(std::out_of_range& e) {
        std::cerr << "INTVAL too large!" << std::endl;
        yyterminate();
    }
}

[+-]?([0-9]+\.[0-9]+|\.[0-9]+|[0-9]+\.) {
    try {
        yylval->emplace<double>(std::stod(yytext));
        return Token::FLOATVAL;
    } catch(std::out_of_range& e) {
        std::cerr << "FLOATVAL too large!" << std::endl;
        yyterminate();
    }
}

"//"(.*)"\n" {
    //do nothing
}
. {
    std::cerr << "Invalid Token" << yytext << std::endl;
    yyterminate();
}

%%
#ifdef yylex
#undef yylex
#endif
