#include <memory>
#include "driver.hh"
#include "lexer.hh"
#include "parser.tab.hh"

Driver::Driver() {
    m_lexer = std::make_shared<Lexer>();
    m_parser = std::make_shared<Parser>(this);
}

bool Calc::Driver::parse() {
    return m_parser->parse() == 0;
}
