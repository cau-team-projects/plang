CXXFLAGS += -g -pg
CXXFLAGS += -fsanitize=address,leak
BFLAGS += -v

all: plang

plang: main.cc lexer.yy.cc lexer.cc lexer.hh parser.tab.cc parser.tab.hh driver.cc driver.hh
	${CXX} ${CXXFLAGS} -o $@ $^

lexer.yy.cc: lexer.ll
	${LEX} ${LFLAGS} -o $@ $^

parser.tab.cc: parser.yy
	bison ${BFLAGS} $^

.PHONY: clean
clean:
	rm -rf *.o *.yy.cc *.tab.hh *.tab.cc *.out location.hh
