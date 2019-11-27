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

bool Driver::varValid(std::string name) {
    return (vstack.empty() || vstack.back().find(name) != vstack.back().end());
}


VarValue::VarValue(){ value.dval = 0;}
VarValue::VarValue(int i) {value.ival = i;}
VarValue::VarValue(double d){value.dval = d;}



RValue::RValue(int type, VarValue val){
    this->type = type;
    this->val = val;
}
RValue::~RValue(){}

RValue operator+(RValue& me, RValue& other){
    RValue ret = me;
    return me;
}

RValue operator-(RValue& me, RValue& other){
    RValue ret = me;
    return me;
}

RValue operator*(RValue& me, RValue& other){
    RValue ret = me;
    return me;
}

RValue operator/(RValue& me, RValue& other){
    RValue ret = me;
    return me;
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
