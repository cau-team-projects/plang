#include <cstdlib>
#include <fstream>
#include <memory>
#include "driver.hh"

int main(int argc, const char* argv[]) {
    std::unique_ptr<Driver> driver{};
    std::ifstream in{};
    std::ofstream out{};
    switch(argc) {
    case 1:
        driver = std::make_unique<Driver>(std::cin, std::cout);
        break;
    case 2:
        in.open(argv[1]);
        driver = std::make_unique<Driver>(in, std::cout);
        break;
    case 3:
        in.open(argv[1]);
        out.open(argv[2]);
        driver = std::make_unique<Driver>(in, out);
        break;
    }
    return driver->parse();
}
