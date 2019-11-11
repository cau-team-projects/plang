#ifndef DRIVER_HH
#define DRIVER_HH

#include <memory>

class Lexer;
namespace yy {
    class Parser;
};

class Driver {
private:
    std::shared_ptr<Lexer> m_lexer;
    std::shared_ptr<yy::Parser> m_parser;
    friend class yy::Parser;
public:
    explicit Driver();
    ~Driver();
    bool parse();
};

#endif
