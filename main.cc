#include <cstdlib>
#include <fstream>
#include <memory>
#include "driver.hh"

int main(int argc, const char* argv[]) {
    if(argc < 3)
        return EXIT_FAILURE;
    std::ifstream in{argv[1]};
    std::ofstream out{argv[2]};
    auto driver = std::make_unique<Driver>(in, out);
    driver->parse();
    return 0;
}
