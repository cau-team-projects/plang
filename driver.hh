#ifndef DRIVER_HH
#define DRIVER_HH

#include <fstream>
#include <iostream>
#include <memory>
#include <vector>
#include <unordered_map>
#include <utility>
#include "location.hh"

class Lexer;
namespace yy {
    class Parser;
};

union VarValue{
    int ivalue;
    double dvalue;
};

using Parser = yy::Parser;
using location = yy::location;
using Type = std::pair<int, int>;
using Variable = std::pair<Type, VarValue*>; //type, length(if array, else 0), list of value
using VariableMap = std::unordered_map<std::string, Variable>; //name, variable
class Driver {
private:
    std::shared_ptr<Lexer> m_lexer;
    std::shared_ptr<Parser> m_parser;
    std::string m_ifname;
    std::ifstream m_ifile;
    int data = 0;
    int func = 0;
    std::vector<std::string> id_list;
    VariableMap vmap;
    std::vector<VariableMap> vstack;
    bool varValid(std::string name);

    friend Parser;
public:
    explicit Driver(std::istream& in = std::cin, std::ostream& out = std::cout);
    explicit Driver(const std::string& ifname, std::ostream& out = std::cout);
    ~Driver();
    void error(const location& loc, const std::string& msg);
    void setDebugging(int level);
    bool parse();
};

std::ostream& operator<<(std::ostream& os, const VariableMap& vmap);
std::ostream& operator<<(std::ostream& os, const std::vector<VariableMap> vstack);

#endif
