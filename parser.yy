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
%token SEMI DOT COMMA ASMT COLON
%token OP CP
%token OSB CSB
%token MAIN FUNC PROC
%token BEG END
%token IF ELIF ELSE
%token NOP
%token WHILE
%token RETURN
%token PRINT
%token FOR IN
%token SP TAB
%token LF

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
program: MAIN ID SEMI declarations subprogram_declarations compound_statement FIN { return 0; }

declarations: declaration SEMI declarations
            | %empty

declaration: type identifier_list

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

compound_statement: BEG statement_list END

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

if_statement: IF expression COLON statement elifs ELSE COLON statement END
            | IF expression COLON statement elifs END

elifs: elif elifs
     | %empty

elif: ELIF expression COLON statement

while_statement: WHILE expression COLON statement

for_statement: FOR type ID IN expression COLON statement

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
