#include <iostream>
#include <memory>
#include "driver.hh"
#include "lexer.hh"
#include "parser.tab.hh"

Driver::Driver(std::istream& in, std::ostream& out) {
    m_lexer = std::make_shared<Lexer>(in, out);
    m_parser = std::make_shared<Parser>(this);
    m_parser->set_debug_level(1);
}

Driver::~Driver() {}

bool Driver::parse() {
    return m_parser->parse() == 0;
}
