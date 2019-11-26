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

using Type = std::pair<int, int>; //<타입{token::INT, token::FLOAT}, list일 경우 변수 갯수. 아닐 경우 0>
using Variable = std::pair<Type, VarValue*>; //type, length(if array, else 0), list of value
using VariableMap = std::unordered_map<std::string, Variable>; //name, variable

class Driver {
private:
    std::shared_ptr<Lexer> m_lexer;
    std::shared_ptr<Parser> m_parser;
    std::string m_ifname;
    std::ifstream m_ifile;
    std::vector<std::string> id_list;
    VariableMap vmap;
    std::vector<VariableMap> vstack;
	/*
	vstack
	   Variable을 하나하나 넣는 방식이 아니라 Variable 덩어리--VariableMap를 집어넣고 빼는 스택으로 고안했습니다.
	   스택 가장 아래에는 mainproc에서 선언된 변수들, 즉 전역 변수를 집어넣었고
	   그 위에는 함수 선언을 할 때마다 그 위에 arguments 덩어리, 그 위에 지역변수 순으로 집어넣었습니다.
	   그리고 스택에서 변수를 찾을 때는 위쪽 덩어리부터 각각의 덩어리에 대해 변수를 찾아서 만약 겹치는 이름이 있을 경우에는 가장 '안쪽'의 변수를 찾아올 수 있게 했습니다.
	   함수 선언이 종료될 때 스택을 빼지 않으면 그 다음 함수에서도 이전 함수의 지역변수를 접근할 수 있기 때문에 함수가 종료될 때는 반드시 스택에서 제거해야 합니다.
	*/
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
