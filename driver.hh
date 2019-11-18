#ifndef DRIVER_HH
#define DRIVER_HH

#include <fstream>
#include <iostream>
#include <memory>
#include "location.hh"

class Lexer;
namespace yy {
    class Parser;
};

using Parser = yy::Parser;
using location = yy::location;

class Driver {
private:
    std::shared_ptr<Lexer> m_lexer;
    std::shared_ptr<Parser> m_parser;
    std::string m_ifname;
    std::ifstream m_ifile;
    friend Parser;
public:
    explicit Driver(std::istream& in = std::cin, std::ostream& out = std::cout);
    explicit Driver(const std::string& ifname, std::ostream& out = std::cout);
    ~Driver();
    void error(const location& loc, const std::string& msg);
    void setDebugging(int level);
    bool parse();
};

#endif
