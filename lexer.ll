/*
    김명승 작성
    tab대신 space 4번
*/

%{
#include <cstring>
#define yyterminate() return token::END

using token yy::parser::token;
%}

%option c++

%%

%{
    yylval = lval;
%}

([\n\t\r ]+|"//".*[\n]+|"/*"([^\*]|\*[^/])*"*/") {}

[a-zA-Z][a-zA-Z0-9_]* {
    strcpy(yylval.id, yytext);
    return token::ID;
}

[+-]?[0-9]+ {
    yylval.intval = atoi(yytext);
    return token::INTVAL
}

[+-]?([0-9]*\.?[0-9]+|[0-9]+\.) {
    yylval.floatval = atoi(yytext);
    return token::FLOATVAL;
}

"int" { return token::INT; }
"float" { return token::FLOAT; }

"+" { return token::PLUS; }
"-" { return token::MINUS; }
"*" { return token::MUL; }
"/" { return token::DIV; }
"<" { return token::LT; }
"<=" { return token::LE; }
">=" { return token::GE; }
">" { return token::GT; }
"==" { return token::EQ; }
"!=" { return token::NE; }
"!" { return token::NOT; }
";" { return token::SEMI; }
"." { return token::DOT; }
"," { return token::COMMA; }
"=" { return token::ASMT; }
"(" { return token::OP; }    //Open Parentheses
")" { return token::CP; }    //Close Parentheses
"[" { return token::OS; }    //Open Square bracket
"]" { return token::CS; }    //Close Square bracket
":" { return token::COLON; }

"mainprog" { return token::MAIN; }
"function" { return token::FUNC; }
"procedure" { return token::PROC; }
"begin" { return token::BEGIN; }
"end" { return token::END; }
"if" { return token::IF; }
"then" { return token::THEN; }
"elif" { return token::ELIF; }
"else" { return token::ELSE; }
"nop" { return token::NOP; }
"while" { return token::WHILE; }
"return" { return token::RETURN; }
"print" { return token::PRINT; }
"for" { return token::FOR; }
"in" { return token::IN; }

%%
