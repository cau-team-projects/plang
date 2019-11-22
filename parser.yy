%require "3.2"
%defines
%skeleton "lalr1.cc"
%language "c++"
%define api.parser.class {Parser}
%define api.value.type variant
%define parse.error verbose
%define parse.trace
%locations
%initial-action {
    @$.begin.filename = @$.end.filename = &driver->m_ifname;
}

%start program
%token FIN
%token<std::string> ID
%token<int> INTVAL
%token<double> FLOATVAL
%token INT FLOAT
%token PLUS MINUS MUL DIV
%token LT LE GT GE EQ NE NOT
%token COMMA ASMT COLON
%token OP CP
%token OSB CSB
%token MAIN FUNC PROC
%token BEG END
%token IF ELIF ELSE THEN
%token NOP
%token WHILE DO
%token RETURN
%token PRINT
%token FOR IN
%token SEMI DOT
%left MUL DIV
%left PLUS MINUS
%left LT LE GT GE EQ NE IN

%parse-param { Driver* driver }

%code requires {
#include <memory>
#include "driver.hh"
}

%{
#include "lexer.hh"
#undef yylex
#define yylex driver->m_lexer->lex
using Parser = yy::Parser;
#define YYDEBUG 1
%}

%%
program: MAIN ID declaration_list subprogram_declaration_list compound_statement FIN { return 0; }

declaration_list: declaration declaration_list
                | %empty

declaration: type identifier_list

identifier_list: ID
               | ID COMMA identifier_list

type: standard_type
    | standard_type OSB INTVAL CSB

standard_type: INT
             | FLOAT

subprogram_declaration_list: subprogram_declaration subprogram_declaration_list
                       | %empty

subprogram_declaration: subprogram_head declaration_list compound_statement

subprogram_head: FUNC ID arguments COLON standard_type
               | PROC ID arguments

arguments: OP declaration_list CP
         | %empty

compound_statement: BEG statement_list END

statement_list: statement
              | statement statement_list

statement: variable ASMT expression
         | print_statement
         | procedure_statement
         | compound_statement
         | if_statement
         | while_statement
         | for_statement
         | RETURN expression
         | NOP

if_statement: IF expression THEN statement elifs ELSE statement END
            | IF expression THEN statement elifs END

elifs: elif elifs
     | %empty

elif: ELIF expression THEN statement

while_statement: WHILE expression DO statement END

for_statement: FOR type ID IN expression DO statement END

print_statement: PRINT
               | PRINT OP expression CP

variable: ID
        | ID OSB expression CSB

procedure_statement: ID OP actual_parameter_expression CP

actual_parameter_expression: %empty
                           | expression_list

expression_list: expression
               | expression COMMA expression_list

expression: simple_expression
          | simple_expression relop expression

simple_expression: term
                 | term addop simple_expression

term: factor
    | factor mulop term

factor: INTVAL
      | FLOATVAL
      | variable
      | procedure_statement
      | NOT factor
      | sign factor

sign: PLUS
    | MINUS

relop: GT
     | GE
     | LT
     | LE
     | EQ
     | NE
     | IN

addop: PLUS
     | MINUS

mulop: MUL
     | DIV
%%

void Parser::error(const Parser::location_type& loc, const std::string& msg) {
    driver->error(loc, msg);
}
