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
    std::ifstream in{m_ifname};
    m_lexer = std::make_shared<Lexer>(in, out);
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
