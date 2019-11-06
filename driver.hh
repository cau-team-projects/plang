#ifndef DRIVER_HH
#define DRIVER_HH

#include <memory>

class Driver {
private:
    std::shared_ptr<Lexer> m_lexer;
    std::shared_ptr<Parser> m_parser;
    friend Parser;
public:
    explicit Driver();
    ~Driver();
    int parse();
}

#endif
