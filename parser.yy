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
%token FIN                                            "EOF"
%token<std::string> ID                                "name of variable"
%token<int> INTVAL                                    "int value"
%token<double> FLOATVAL                               "float value"
%token<int> INT FLOAT                                 "int, float"
%token PLUS MINUS MUL DIV                             "+, -, *, /"
%token LT LE GT GE EQ NE NOT                          "< <= > >= == != !"
%token COMMA ASMT COLON                               ", = :"
%token OP CP                                          "(   )"
%token OSB CSB                                        "[   ]"
%token MAIN FUNC PROC                                 "mainprog function procedure"
%token BEG END                                        "begin end"
%token IF ELIF ELSE THEN                              "if elif else then"
%token NOP                                            "nop--- no execution"
%token WHILE DO                                       "while do"
%token RETURN                                         "return"
%token PRINT                                          "print"
%token FOR IN                                         "for in"
%token SEMI DOT                                       "; ."
%left MUL DIV
%left PLUS MINUS
%left LT LE GT GE EQ NE IN

%parse-param { Driver* driver }

%code requires {
#include <memory>
#include "driver.hh"
}

%{
#include <iostream>
#include "lexer.hh"
#include "driver.hh"
#undef yylex
#define yylex driver->m_lexer->lex
using Parser = yy::Parser;
#define YYDEBUG 1

%}

%type<int> standard_type "type in {INT, FLOAT}. uses token::INT, token::FLOAT itself."
%type<Type> type

%%
program: program_head subprogram_declaration_list compound_statement FIN {
    std::cout << driver->vstack << std::endl;
    return 0;
}
program_head: MAIN ID declaration_list {
    driver->vstack.push_back(driver->vmap);
    driver->vmap.clear();
}

declaration_list: declaration declaration_list | %empty

declaration: type identifier_list {
    for(auto& i : driver->id_list) {
        driver->vmap.insert(std::pair<std::string, Variable>(i, Variable($1, nullptr)));
    }
    driver->id_list.clear();
}

identifier_list: ID                                    {driver->id_list.push_back($1);}
               | ID COMMA identifier_list              {driver->id_list.push_back($1);}

type: standard_type                                    {$$ = std::pair<int, int>($1, 0);}
    | standard_type OSB INTVAL CSB                     {$$ = std::pair<int, int>($1, $3);}

standard_type: INT                                     {$$ = token::INT;}
             | FLOAT                                   {$$ = token::FLOAT;}

subprogram_declaration_list: subprogram_declaration subprogram_declaration_list
                           | %empty

subprogram_declaration: subprogram_head compound_statement {
    driver->vstack.pop_back();
    driver->vstack.pop_back();
}

subprogram_head: FUNC ID arguments COLON standard_type declaration_list {
    driver->vstack.push_back(driver->vmap);
    driver->vmap.clear();
} | PROC ID arguments declaration_list {
    driver->vstack.push_back(driver->vmap);
    driver->vmap.clear();
}

arguments: OP declaration_list CP {
    driver->vstack.push_back(driver->vmap);
    driver->vmap.clear();
} | %empty

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

variable:
    ID {
        if(!driver->varValid($1)) {
            std::cerr << $1 << " is not valid in this scope." << std::endl;
            return -1;
        }
    } | ID OSB expression CSB

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
