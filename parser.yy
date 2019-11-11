
%require "3.2"
%defines
%skeleton "lalr1.cc"
%language "c++"
%debug
%define api.parser.class {Parser}
%define api.value.type variant
%define parse.error verbose
%locations

%start program

%token <std::string> ID
%token <int> INTVAL
%token <float> FLOATVAL
%token INT FLOAT
%token PLUS MINUS MUL DIV
%token LT LE GT GE EQ NE NOT
%token SEMI DOT COMMA ASMT COLON
%token OP CP
%token OSB CSB
%token SP NL

%token MAIN FUNC PROC BEGIN END
%token IF THEN ELIF ELSE
%token NOP
%token WHILE RETURN
%token PRINT
%token FOR IN
%parse-param { Driver* driver }
%code requires {
#include <memry>
#include "driver.hh"
}
%{
#include "lexer.hh"
#undef yylex
#define yylex driver->lexer->lex
%}

%%

program: MAIN ID SEMI declaration subprogram_declarations compound_statement END

declaration: type identifier_list SEMI declaration
   | %empty
   
identifier_list: ID 
    | ID COMMA identifier_list

type: standard_type
    | standard_type OSB INTVAL CSB

standard_type: INT
    | FLOAT

subprogram_declarations: subprogram_declaration subprogram_declarations
    | %empty

subprogram_declaration: subprogram_head declarations compound_statement

subprogram_head: FUNC ID arguments COLON standard_type SEMI
    | PROC ID arguments SEMI

arguments: OP parameter_list CP
    | %empty

parameter_list: identifier_list COLON type
    | identifier_list COLON type SEMI parameter_list

compound_statement: BEGIN statement_list END

statement_list: statement
    | statement SEMI statement_list

statement: variable ASMT expression
    | print_statement
    | procedure_statement
    | compound_statement
    | if_statement
    | while_statement
    | for_statement
    | RETURN expression
    | NOP

if_statement: IF expression COLON statement elifs else
    | IF expression COLON statement elifs

elifs: elif elifs
    | %empty

elif: ELIF expression COLON statement

while_statement: WHILE expression COLON statement
    | WHILE expression COLON statement ELSE COLON statement

for_statement: FOR expression IN expression COLON statement
    | FOR expression IN expression COLON statement ELSE COLON statement

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
    | simple_expression relop simple_expression

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
