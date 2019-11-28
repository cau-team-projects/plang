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
%token FIN "EOF"
%token<std::string> ID
%token<int> INTVAL
%token<double> FLOATVAL
%token<int> INT FLOAT
%token PLUS MINUS MUL DIV
%token LT LE GT GE EQ NE NOT
%token COMMA
%token COLON
%token ASMT "="
%token OP "OPEN BRACKET"
%token CP "CLOSE BRACKET"
%token OSB "OPEN SPACE BRACKET"
%token CSB "CLOSE SPACE BRACKET"
%token MAIN FUNC PROC
%token BEG "BEGIN"
%token END "END"
%token IF ELIF ELSE THEN
%token NOP
%token WHILE DO
%token RETURN
%token PRINT
%token FOR IN
%token SEMI "SEMICOLON"
%token DOT
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
%type<int> addop mulop
%type<RValue> expression simple_expression term factor

%%
program: program_head subprogram_declaration_list compound_statement FIN { driver->vstack.pop_back(); return 0; }
program_head: MAIN ID declaration_list {
    driver->vstack.push_back(driver->vmap);
    driver->vmap.clear();
}

declaration_list: declaration declaration_list | %empty

declaration: type identifier_list {
    if($1.second < 0){
        std::cerr << "invalid case: Array with length " << $1.second << "  ";
        for(auto& i: driver->id_list) { std::cerr << i << " ";}
        std::cerr << "had been declared." << std::endl;
        return -1;
    }
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

for_statement: FOR type ID IN expression DO statement END {
                   if($5.getType() == token::FLOAT) {
                       std::cerr << "invalid case: 'for' structure try to run " << $5.getFloat() <<" times(non-integer times)" << std::endl;
                       return -1;
                   }
               }

print_statement: PRINT {/*std::cout << driver->vstack << std::endl;*/}
               | PRINT OP expression CP {/*std::cout << $3 << std::endl;*/}

variable:
    ID {
        Variable v;
        if(!driver->varValid($1, &v)) {
            std::cerr << "invalid case: " << $1 << " is not declared." << std::endl;
            return -1;
        }
        if(v.first.second != 0){
            std::cerr << "invalid case: " << $1 << " is not a array type." << std::endl;
        }
    } | ID OSB expression CSB{
        Variable v;
        if(!driver->varValid($1, &v)) {
            std::cerr << "invalid case: " << $1 << " is not declared." << std::endl;
            return -1;
        }
        if($3.getType() != token::INT){
            std::cerr << "invalid case: Invalid array access " << $1 << "[" << $3.getInt() << "]" << std::endl;
            return -1;
        }
        if($3.getInt() >= v.first.second || $3.getInt() < 0){
            std::cerr << "invalid case: Invalid array access " << $1 << "[" << $3.getInt() << "]" << std::endl;
            return -1;
        }
    }

procedure_statement: ID OP actual_parameter_expression CP

actual_parameter_expression: %empty
                           | expression_list

expression_list: expression
               | expression COMMA expression_list

expression: simple_expression {$$ = $1;}
          | simple_expression relop expression {$$ = $1;}

simple_expression: term {$$ = $1;}
                 | term addop simple_expression {
                   if($2 == token::PLUS) {$$ = $1 + $3;}
                   else                  {$$ = $1 - $3;}
                   }

term: factor {$$ = $1;}
    | factor mulop term {
                         if($2 == token::MUL) {$$ = $1 * $3;}
                         else                 {
                                               if(($3.getType() == token::INT && $3.getInt() == 0) || ($3.getType() == token::FLOAT && $3.getFloat() == 0.0f)){
                                                   std::cerr << "invalid case: Divided by zero Error." << std::endl; return -1;
                                               }
                                               else {$$ = $1 / $3;}
                                              }
                        }

factor: INTVAL {$$ = RValue(token::INT, VarValue($1));}
      | FLOATVAL {$$ = RValue(token::FLOAT, VarValue($1));}
      | variable {$$ = RValue(token::INT, VarValue(0));}
      | procedure_statement {$$ = RValue(token::INT, VarValue(0));}
      | NOT factor {$$ = $2;}
      | sign factor {$$ = $2;}

sign: PLUS
    | MINUS

relop: GT
     | GE
     | LT
     | LE
     | EQ
     | NE
     | IN

addop: PLUS {$$ = token::PLUS;}
     | MINUS {$$ = token::MINUS;}

mulop: MUL {$$ = token::MUL;}
     | DIV {$$ = token::DIV;}
%%
void Parser::error(const Parser::location_type& loc, const std::string& msg) {
    driver->error(loc, msg);
}
