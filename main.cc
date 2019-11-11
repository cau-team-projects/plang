#include <memory>
#include "driver.hh"

int main() {
    auto driver = std::make_unique<Driver>();
    driver->parse();
    return 0;
}
