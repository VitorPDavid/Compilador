%{
#include <iostream>
#include <string>
#include <vector>
#include <sstream>

#include <unordered_map>

#define YYSTYPE atributos

using namespace std;

struct atributos
{
	string conteudo;
	string codigo;
};

int ProxVariavelTemp = 0;

typedef struct{
	string temporaria;
	string tipo;
} caracteristicas;

typedef caracteristicas* Ptrcarac;

unordered_map<string, caracteristicas> table;

vector<string> bufferDeclaracoes;

int yylex(void);
void yyerror(string);
string criaVariavelTemp(void);
string criaCaracteristicas(string, string = "");
void imprimeBufferDeclaracoes(void);
Ptrcarac instanciaCaracteristicas(void);

%}

%token TK_INT TK_FLOAT TK_EXP TK_OCTAL TK_HEX TK_BOOL
%token TK_TIPO_INT TK_TIPO_BOOL TK_TIPO_DOUBLE TK_TIPO_FLOAT
%token TK_MAIN TK_ID
%token TK_FIM_LINHA TK_ESPACE TK_TABULACAO
%token TK_FIM TK_ERROR

%start S

%left '+' '-'
%left '*' '/'
%left '(' ')'

%%

S 			: COMANDOS
			{
				cout << "/*Compilador Kek*/\n#include <iostream>\n#include <string.h>\n#include <stdio.h>\n#define TRUE 1\n#define FALSE 0\nint main(void)\n{\n";
				imprimeBufferDeclaracoes();
				cout << $1.codigo << "\treturn 0;\n}" << endl;
			}
			;

/*BLOCO		: '{' COMANDOS '}'
			{
				$$.codigo = $2.codigo;
			}
			;
*/
COMANDOS	: COMANDO COMANDOS
			{
				$$.codigo = $1.codigo + $2.codigo;
			}
			|
			{
				$$.codigo = "";
			}
			;

COMANDO 	: E ';'
			{
				$$ = $1;
			}
			| ATRI ';'
			{
				$$ = $1;
			}
			| DECLARA ';'
			{
			    $$ = $1;
			}
			;

DECLARA		: TK_TIPO_INT TK_ID
			{
				string aux = criaCaracteristicas($2.codigo);
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				$$.codigo = "";
			}
			| TK_TIPO_FLOAT TK_ID
			{
				string aux = criaCaracteristicas($2.codigo);
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				$$.codigo = "";
			}
			| TK_TIPO_DOUBLE TK_ID
			{
				string aux = criaCaracteristicas($2.codigo);
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				$$.codigo = "";
			}
			| TK_TIPO_BOOL TK_ID
			{
				string aux = criaCaracteristicas($2.codigo);
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				$$.codigo = "";
			}
			;

E 			: E '+' E
			{
				$$.conteudo = criaVariavelTemp();
				$$.codigo = $1.codigo + $3.codigo + "\t" + $$.conteudo + "=" + $1.conteudo + "+" + $3.conteudo + ";\n";
			}
			| E '*' E
			{
			    $$.conteudo = criaVariavelTemp();
			    $$.codigo = $1.codigo + $3.codigo + "\t" + $$.conteudo + "=" + $1.conteudo + "*" + $3.conteudo + ";\n";
			}
			| E '/' E
			{
			    $$.conteudo = criaVariavelTemp();
			    $$.codigo = $1.codigo + $3.codigo + "\t" + $$.conteudo + "=" + $1.conteudo + "/" + $3.conteudo + ";\n";
			}
			| E '-' E
			{
			    $$.conteudo = criaVariavelTemp();
			    $$.codigo = $1.codigo + $3.codigo + "\t" + $$.conteudo + "=" + $1.conteudo + "-" + $3.conteudo + ";\n";
			}
			| '(' E ')'
			{
				$$.conteudo = $2.conteudo;
				$$.codigo = $2.codigo;
			}
			| TK_INT
			{
				$$.conteudo = criaVariavelTemp();
				$$.codigo = "\t" + $$.conteudo + "=" + $1.codigo + ";\n";
			}
			| TK_FLOAT
			{
				$$.conteudo = criaVariavelTemp();
				$$.codigo = "\t" + $$.conteudo + "=" + $1.codigo + ";\n";
			}
			| TK_ID
			{
				$$.conteudo = criaCaracteristicas($1.codigo);
				$$.codigo = "";
			}
			;

ATRI		: TK_ID '=' E
			{
				string aux = criaCaracteristicas($1.codigo);
				$$.codigo = $3.codigo + "\t" + aux + "=" + $3.conteudo + ";\n";
			}
			;
%%

#include "lex.yy.c"

int yyparse();


int main( int argc, char* argv[] ) {
	yyparse();

	return 0;
}

void yyerror( string MSG ) {
	cout << MSG << endl;
	exit (0);
}

string criaVariavelTemp(void) {
	string prefixoRetornar = "tmp";
	int sufixoRetornar = ProxVariavelTemp++;

	prefixoRetornar += to_string(sufixoRetornar);

	return prefixoRetornar;
}

string criaCaracteristicas(string variavel, string tipo) {
	unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = table.find(variavel);

	if ( linhaDaVariavel == table.end() ){
		caracteristicas novaVariavel;
		novaVariavel.temporaria = criaVariavelTemp();
		novaVariavel.tipo = tipo;
		table[variavel] = novaVariavel;
		return table[variavel].temporaria;
	}
	else {
		return table[variavel].temporaria;
	}

	return "";
}

void imprimeBufferDeclaracoes(void) {
	for (auto declaracao : bufferDeclaracoes)
	{
		cout << declaracao;
	}
}

/*Ptrcarac instanciaCaracteristicas(void) {
	Ptrcarac instancia = (Ptrcarac)malloc(sizeof(caracteristicas));

	instancia->temporaria = criaVariavelTemp();
	instancia->tipo = "";

	return instancia;
}

int tamanhoCaracteristicas(void) {
	return sizeof()
}*/
