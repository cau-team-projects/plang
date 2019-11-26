CXXFLAGS += -g -pg
CXXFLAGS += -fsanitize=address,leak,undefined
CXXFLAGS += -std=c++17
BFLAGS += -v

all: plang

plang: main.cc lexer.yy.cc lexer.cc lexer.hh parser.tab.cc parser.tab.hh driver.cc driver.hh
	${CXX} ${CXXFLAGS} -o $@ $^

lexer.yy.cc: lexer.ll
	${LEX} ${LFLAGS} -o $@ $^

parser.tab.cc: parser.yy
	bison ${BFLAGS} $^

.PHONY: clean, run
clean:
	rm -rf *.o *.yy.cc *.tab.hh *.tab.cc *.out location.hh

run:
	./plang test/good/t1.plang
