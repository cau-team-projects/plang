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
#include <unordered_map>
#include <stack>
#include "driver.hh"
union varValue{
    int ivalue;
    double dvalue;
};
using Type        = std::pair<int, int>;
using Variable    = std::pair<Type, varValue*>;    //type, length(if array, else 0), list of value
using VariableMap = std::unordered_map<std::string, Variable>; //name, variable
}

%{
#include <iostream>
#include "lexer.hh"
#undef yylex
#define yylex driver->m_lexer->lex
using Parser = yy::Parser;
#define YYDEBUG 1

int data = 0;
int func = 0;
std::vector<std::string> id_list;
VariableMap vmap;
std::stack<VariableMap> vstack;
%}

%type<int> standard_type                   "type in {INT, FLOAT}. uses token::INT, token::FLOAT itself."
%type<Type> type

%%
program: MAIN ID declaration_list subprogram_declaration_list compound_statement FIN {std::cout << "vmap size == " <<vmap.size() << std::endl; vmap.clear(); vstack.pop(); vstack.pop(); return 0; }

declaration_list: declarations {vstack.push(vmap);}
declarations: declaration declarations
            | %empty

declaration: type identifier_list {for(auto& i : id_list) { vmap.insert(std::pair<std::string, Variable>(i, Variable($1, NULL))); } id_list.clear();}

identifier_list: ID {id_list.push_back($1);}
               | ID COMMA identifier_list{id_list.push_back($1);}

type: standard_type {$$ = std::pair<int, int>($1, 0);}
    | standard_type OSB INTVAL CSB{$$ = std::pair<int, int>($1, $3);}

standard_type: INT {$$ = token::INT;}
             | FLOAT {$$ = token::FLOAT;}

subprogram_declaration_list: subprogram_declarations
subprogram_declarations: subprogram_declaration subprogram_declarations
                       | %empty

subprogram_declaration: subprogram_head declaration_list compound_statement {std::cout << "data=" << data << std::endl; func = 0;}

subprogram_head: FUNC ID arguments COLON standard_type {func = 5;}
               | PROC ID arguments

arguments: OP declaration_list CP
         | %empty

compound_statement: BEG statement_list END{std::cout << "func=" << func << std::endl;}

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
