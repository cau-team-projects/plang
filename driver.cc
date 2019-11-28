#include <iostream>
#include <fstream>
#include <memory>
#include "driver.hh"
#include "lexer.hh"
#include "parser.tab.hh"

Driver::Driver(std::istream& in, std::ostream& out) {
    m_ifname = "anon";
    m_lexer = std::make_shared<Lexer>(in, out);
    m_parser = std::make_shared<Parser>(this);
}

Driver::Driver(const std::string& ifname, std::ostream& out) {
    m_ifname = ifname;
    m_ifile.open(m_ifname);
    m_lexer = std::make_shared<Lexer>(m_ifile, out);
    m_parser = std::make_shared<Parser>(this);
}

Driver::~Driver() {}

void Driver::setDebugging(int level) {
    m_lexer->set_debug(1);
    m_parser->set_debug_level(1);
}

bool Driver::parse() {
    return m_parser->parse() == 0;
}

void Driver::error(const Parser::location_type& loc, const std::string& msg) {
    std::cerr << loc << ": " << msg << std::endl;
}

bool Driver::varValid(std::string name, Variable* v) {
    for(auto i = vstack.rbegin();i != vstack.rend();i++){
        if(i->find(name) != i->end()) {
            if(v) *v = i->find(name)->second;
            return true;
        }
    }
    return false;
}

VarValue::VarValue(){ value.dval = 0;}
VarValue::VarValue(int i) {value.ival = i;}
VarValue::VarValue(double d){value.dval = d;}



RValue::RValue(int type, VarValue val){
    this->type = type;
    this->value = val;
}
RValue::~RValue(){}

int RValue::getType() const{ return type; }

VarValue RValue::getValue() const{ return value; }

int RValue::getInt() const { return value.getInt(); }

double RValue::getFloat() const { return value.getFloat(); }

RValue operator+(RValue& me, RValue& other){
    int type = Parser::token::FLOAT;
    VarValue v;
    if(me.getType() == Parser::token::INT){
        if(other.getType() == Parser::token::INT){
            v.setInt(me.getInt() + other.getInt());
            type = Parser::token::INT;
        }
        else{
            v.setFloat((double)me.getInt() + other.getFloat());
        }
    }
    else{
        if(other.getType() == Parser::token::INT){
            v.setFloat(me.getFloat() + (double)other.getInt());
        }
        else{
            v.setFloat(me.getFloat() + other.getFloat());
        }
    }
    return RValue(type, v);
}

RValue operator-(RValue& me, RValue& other){
    int type = Parser::token::FLOAT;
    VarValue v;
    if(me.getType() == Parser::token::INT){
        if(other.getType() == Parser::token::INT){
            v.setInt(me.getInt() - other.getInt());
            type = Parser::token::INT;
        }
        else{
            v.setFloat((double)me.getInt() - other.getFloat());
        }
    }
    else{
        if(other.getType() == Parser::token::INT){
            v.setFloat(me.getFloat() - (double)other.getInt());
        }
        else{
            v.setFloat(me.getFloat() - other.getFloat());
        }
    }
    return RValue(type, v);
}

RValue operator*(RValue& me, RValue& other){
    int type = Parser::token::FLOAT;
    VarValue v;
    if(me.getType() == Parser::token::INT){
        if(other.getType() == Parser::token::INT){
            v.setInt(me.getInt() * other.getInt());
            type = Parser::token::INT;
        }
        else{
            v.setFloat((double)me.getInt() * other.getFloat());
        }
    }
    else{
        if(other.getType() == Parser::token::INT){
            v.setFloat(me.getFloat() * (double)other.getInt());
        }
        else{
            v.setFloat(me.getFloat() * other.getFloat());
        }
    }
    return RValue(type, v);
}

RValue operator/(RValue& me, RValue& other){
    int type = Parser::token::FLOAT;
    VarValue v;

    if(other.getType() == Parser::token::INT && other.getInt() == 0 ||
	   other.getType() == Parser::token::FLOAT && other.getFloat() == 0.0){
	   std::cerr << "Divided by zero Error." << std::endl;
	}
    if(me.getType() == Parser::token::INT){
        if(other.getType() == Parser::token::INT){
            v.setInt(me.getInt() / other.getInt());
            type = Parser::token::INT;
        }
        else{
            v.setFloat((double)me.getInt() / other.getFloat());
        }
    }
    else{
        if(other.getType() == Parser::token::INT){
            v.setFloat(me.getFloat() / (double)other.getInt());
        }
        else{
            v.setFloat(me.getFloat() / other.getFloat());
        }
    }
    return RValue(type, v);
}






std::ostream& operator<<(std::ostream& os, const VariableMap& vmap) {
    os << "vmap:" << std::endl;
    for(auto &i : vmap){
        os << "    " << i.first << ": " << i.second.first.first << "[" << i.second.first.second << "]" << std::endl;
    }
    return os;
}

std::ostream& operator<<(std::ostream& os, const std::vector<VariableMap> vstack) {
    os << "vstack:" << std::endl;
    for(auto &i : vstack){
        os << "  " << i << std::endl;
    }
    return os;
}

std::ostream& operator<<(std::ostream& os, const RValue& rval){
    if(rval.type == Parser::token::INT) os << rval.value.getInt();
    else                                os << rval.value.getFloat();
    return os;
}
