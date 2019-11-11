#ifndef DRIVER_HH
#define DRIVER_HH

#include <memory>

class Lexer;
namespace yy {
    class Parser;
};

using Parser = yy::Parser;

class Driver {
private:
    std::shared_ptr<Lexer> m_lexer;
    std::shared_ptr<Parser> m_parser;
    friend Parser;
public:
    explicit Driver();
    ~Driver();
    bool parse();
};

#endif
