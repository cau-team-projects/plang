#include <cstdlib>
#include <fstream>
#include <memory>
#include "driver.hh"

int main(int argc, const char* argv[]) {
    std::unique_ptr<Driver> driver{};
    std::ofstream out{};
    switch(argc) {
    case 1:
        driver = std::make_unique<Driver>(std::cin, std::cout);
        break;
    case 2:
        driver = std::make_unique<Driver>(argv[1], std::cout);
        break;
    case 3:
        out.open(argv[2]);
        driver = std::make_unique<Driver>(argv[1], out);
        break;
    }
#ifdef DEBUG
    driver->setDebugging(1);
#endif
    return driver->parse();
}
