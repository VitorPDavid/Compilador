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
	string tipo;
};

int ProxVariavelTemp = 0;

typedef struct{
	string temporaria;
	string tipo;
} caracteristicas;

unordered_map<string, caracteristicas> table;

vector<string> bufferDeclaracoes;

int count = 0;

int yylex(void);
void yyerror(string);
string criaVariavelTemp(void);
string criaInstanciaTabela(string, string = "");
bool verificaTiposEmOperacoes(string,string,string&);
void imprimeBuffers(void);
string regraCoercao(string, string, string);

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
				imprimeBuffers();
				cout << $1.codigo << "\treturn 0;\n}" << endl;
			}
			;

/*
BLOCO		: '{' COMANDOS '}'
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

ATRI		: TK_ID '=' E
			{
				string aux = criaInstanciaTabela($1.codigo);
				$$.codigo = $3.codigo + "\t" + aux + "=" + $3.conteudo + ";\n";
				$$.conteudo = aux;
			}
			;

DECLARA		: TK_TIPO_INT TK_ID
			{
				string aux = criaInstanciaTabela($2.codigo, string("int"));
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				$$.codigo = "";
			}
			| TK_TIPO_INT TK_ID '=' E
			{
				string aux = criaInstanciaTabela($2.codigo, string("int"));
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				if($1.tipo == $4.tipo)
				{
					$$.tipo = $1.tipo;
					$$.codigo = $4.codigo + "\t" + aux + "=" + $4.conteudo + ";\n";
				}
				else
				{
					string tipo = regraCoercao($1.tipo,$4.tipo,string("="));
					string variavelCoercao = criaVariavelTemp();
					string codigoCoercao;

					$$.tipo = tipo;

					bufferDeclaracoes.push_back("\t" + tipo + " " + variavelCoercao + ";\n");
					$$.codigo = $4.codigo + "\t" + aux + "=(" + tipo + ")" + $4.conteudo + ";\n";

				}
			}
			| TK_TIPO_FLOAT TK_ID
			{
				string aux = criaInstanciaTabela($2.codigo, string("float"));
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				$$.codigo = "";
			}
			| TK_TIPO_FLOAT TK_ID '=' E
			{
				string aux = criaInstanciaTabela($2.codigo, string("float"));
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				if($1.tipo == $4.tipo)
				{
					$$.tipo = $1.tipo;
					$$.codigo = $4.codigo + "\t" + aux + "=" + $4.conteudo + ";\n";
				}
				else
				{
					string tipo = regraCoercao($1.tipo,$4.tipo,string("="));

					$$.tipo = tipo;

					$$.codigo = $4.codigo + "\t" + aux + "=(" + tipo + ")" + $4.conteudo + ";\n";
				}
			}
			| TK_TIPO_DOUBLE TK_ID
			{
				string aux = criaInstanciaTabela($2.codigo, string("double"));
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				$$.codigo = "";
			}
			| TK_TIPO_DOUBLE TK_ID '=' E
			{
				string aux = criaInstanciaTabela($2.codigo, string("double"));
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				if($1.tipo == $4.tipo)
				{
					$$.tipo = $1.tipo;
					$$.codigo = $4.codigo + "\t" + aux + "=" + $4.conteudo + ";\n";
				}
				else
				{
					string tipo = regraCoercao($1.tipo,$4.tipo,string("="));

					$$.tipo = tipo;

					$$.codigo = $4.codigo + "\t" + aux + "=(" + tipo + ")" + $4.conteudo + ";\n";
				}
			}
			| TK_TIPO_BOOL TK_ID
			{
				string aux = criaInstanciaTabela($2.codigo, string("bool"));
				bufferDeclaracoes.push_back("\tint " + aux + ";\n");
				$$.codigo = "";
			}
			| TK_TIPO_BOOL TK_ID '=' E
			{
				string aux = criaInstanciaTabela($2.codigo, string("bool"));
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				if($1.tipo == $4.tipo)
				{
					$$.tipo = $1.tipo;
					$$.codigo = $4.codigo + "\t" + aux + "=" + $4.conteudo + ";\n";
				}
				else
				{
					string tipo = regraCoercao($1.tipo,$4.tipo,string("="));

					$$.tipo = tipo;

					$$.codigo = $4.codigo + "\t" + aux + "=(" + tipo + ")" + $4.conteudo + ";\n";
				}
			}
			;

E 			: E '+' E
			{
				$$.conteudo = criaVariavelTemp();

				if($1.tipo == $3.tipo)
				{
					$$.tipo = $1.tipo;
					bufferDeclaracoes.push_back("\t" + $$.tipo + " " + $$.conteudo + ";\n");
					$$.codigo = $1.codigo + $3.codigo + "\t" + $$.conteudo + "=" + $1.conteudo + "+" + $3.conteudo + ";\n";
				}
				else
				{
					string tipo = regraCoercao($1.tipo,$3.tipo,string("+"));
					string variavelCoercao = criaVariavelTemp();
					string codigoCoercao;
					$$.tipo = tipo;
					bufferDeclaracoes.push_back("\t" + tipo + " " + $$.conteudo + ";\n");
					bufferDeclaracoes.push_back("\t" + tipo + " " + variavelCoercao + ";\n");
					if($1.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $1.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao + "\t" + $$.conteudo + "=" + variavelCoercao + "+" + $3.conteudo + ";\n";
					}
					else if($3.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $3.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao +"\t" + $$.conteudo + "=" + $1.conteudo + "+" + variavelCoercao + ";\n";
					}
				}

			}
			| E '*' E
			{
				$$.conteudo = criaVariavelTemp();

				if($1.tipo == $3.tipo)
				{
					$$.tipo = $1.tipo;
					bufferDeclaracoes.push_back("\t" + $$.tipo + " " + $$.conteudo + ";\n");
					$$.codigo = $1.codigo + $3.codigo + "\t" + $$.conteudo + "=" + $1.conteudo + "*" + $3.conteudo + ";\n";
				}
				else
				{
					string tipo = regraCoercao($1.tipo,$3.tipo,string("*"));
					string variavelCoercao = criaVariavelTemp();
					string codigoCoercao;
					$$.tipo = tipo;
					bufferDeclaracoes.push_back("\t" + tipo + " " + $$.conteudo + ";\n");
					bufferDeclaracoes.push_back("\t" + tipo + " " + variavelCoercao + ";\n");
					if($1.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $1.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao + "\t" + $$.conteudo + "=" + variavelCoercao + "*" + $3.conteudo + ";\n";
					}
					else if($3.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $3.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao +"\t" + $$.conteudo + "=" + $1.conteudo + "*" + variavelCoercao + ";\n";
					}
				}
			}
			| E '/' E
			{
			    $$.conteudo = criaVariavelTemp();

				if($1.tipo == $3.tipo)
				{
					$$.tipo = $1.tipo;
					bufferDeclaracoes.push_back("\t" + $$.tipo + " " + $$.conteudo + ";\n");
					$$.codigo = $1.codigo + $3.codigo + "\t" + $$.conteudo + "=" + $1.conteudo + "/" + $3.conteudo + ";\n";
				}
				else
				{
					string tipo = regraCoercao($1.tipo,$3.tipo,string("/"));
					string variavelCoercao = criaVariavelTemp();
					string codigoCoercao;
					$$.tipo = tipo;
					bufferDeclaracoes.push_back("\t" + tipo + " " + $$.conteudo + ";\n");
					bufferDeclaracoes.push_back("\t" + tipo + " " + variavelCoercao + ";\n");
					if($1.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $1.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao + "\t" + $$.conteudo + "=" + variavelCoercao + "/" + $3.conteudo + ";\n";
					}
					else if($3.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $3.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao +"\t" + $$.conteudo + "=" + $1.conteudo + "/" + variavelCoercao + ";\n";
					}
				}
			}
			| E '-' E
			{
			    $$.conteudo = criaVariavelTemp();

				if($1.tipo == $3.tipo)
				{
					$$.tipo = $1.tipo;
					bufferDeclaracoes.push_back("\t" + $$.tipo + " " + $$.conteudo + ";\n");
					$$.codigo = $1.codigo + $3.codigo + "\t" + $$.conteudo + "=" + $1.conteudo + "-" + $3.conteudo + ";\n";
				}
				else
				{
					string tipo = regraCoercao($1.tipo,$3.tipo,string("-"));
					string variavelCoercao = criaVariavelTemp();
					string codigoCoercao;
					$$.tipo = tipo;
					bufferDeclaracoes.push_back("\t" + tipo + " " + $$.conteudo + ";\n");
					bufferDeclaracoes.push_back("\t" + tipo + " " + variavelCoercao + ";\n");
					if($1.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $1.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao + "\t" + $$.conteudo + "=" + variavelCoercao + "-" + $3.conteudo + ";\n";
					}
					else if($3.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $3.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao +"\t" + $$.conteudo + "=" + $1.conteudo + "-" + variavelCoercao + ";\n";
					}
				}

			}
			| '(' E ')'
			{
				$$.conteudo = $2.conteudo;
				$$.codigo = $2.codigo;
				$$.tipo = $2.tipo;
			}
			| TK_INT
			{
				$$.conteudo = criaVariavelTemp();
				$$.tipo = $1.tipo;
				bufferDeclaracoes.push_back("\tint " + $$.conteudo + ";\n");
				$$.codigo = "\t" + $$.conteudo + "=" + $1.codigo + ";\n";
			}
			| TK_FLOAT
			{
				$$.conteudo = criaVariavelTemp();
				$$.tipo = $1.tipo;
				bufferDeclaracoes.push_back("\tfloat " + $$.conteudo + ";\n");
				$$.codigo = "\t" + $$.conteudo + "=" + $1.codigo + ";\n";
			}
			| TK_ID
			{
				$$.conteudo = criaInstanciaTabela($1.codigo);
				$$.codigo = "";
				/*if(table[$$.conteudo].tipo == "")
				{
					yyerror("Variavel não declarada");
				}*/
				$$.tipo = table[$1.codigo].tipo;
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

string criaInstanciaTabela(string variavel, string tipo) {
	unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = table.find(variavel);

	if ( linhaDaVariavel == table.end() ){
		caracteristicas novaVariavel;

		novaVariavel.temporaria = criaVariavelTemp();

		novaVariavel.tipo = tipo;
		table[variavel] = novaVariavel;

		return table[variavel].temporaria;
	}
	else
		return table[variavel].temporaria;

	return "";
}

bool verificaTiposEmOperacoes(string variavelUm, string variavelDois,string& erro) {
	if(table[variavelUm].tipo == table[variavelDois].tipo)
		return true;

	erro = string("Erro de tipo, realize coerção: foi tentado realizar uma operação com: "+ table[variavelUm].tipo + " e " + table[variavelDois].tipo);
	return false;
}

void imprimeBuffers(void) {
	for (auto declaracao : bufferDeclaracoes)
	{
		cout << declaracao;
	}
}

string regraCoercao(string tipoUm, string tipoDois, string operador) {
	if(operador == string("+") || operador == string("-") || operador == string("/") || operador == string("*"))
	{
		if(tipoUm == string("bool") || tipoDois == string("bool"))
		{
			yyerror(string("operadores: soma, subtração, divisão e multiplicação não aceitam tipo booleano"));
			return string("erro");
		}
		else if(tipoUm == string("double") || tipoDois == string("double"))
		{
			return string("double");
		}
		else if(tipoUm == string("float") || tipoDois == string("float"))
		{
			return string("float");
		}
	}
	if(operador == "=")
	{
		if(tipoUm != "bool" && tipoDois == "bool")
		{
			yyerror(string("operador \"=\" não aceita coerção automatica de ") + tipoDois + string(" para bool"));
			return "erro";
		}
		return tipoUm;
	}
}
