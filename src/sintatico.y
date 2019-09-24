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

int numeroLinhas = 1;

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
%token TK_TIPO_IF
%token TK_ID TK_REL
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
CONDI		: TK_IF BLOCO
			{

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
				string tipoAux = table[$1.codigo].tipo;
				
				if($3.tipo == tipoAux)
				{
					$$.codigo = $3.codigo + "\t" + aux + "=" + $3.conteudo + ";\n";
					$$.conteudo = aux;
					$$.tipo = "ope";
				}
				else
				{
					string tempTipo = regraCoercao(tipoAux,$3.tipo,"=");
					$$.codigo = $3.codigo + "\t" + aux + "=(" + tempTipo + ")" + $3.conteudo + ";\n";
					$$.conteudo = aux;
					$$.tipo = "ope";
				}
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
				$2.tipo = "int";
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				if($2.tipo == $4.tipo)
				{
					$$.tipo = $2.tipo;
					$$.codigo = $4.codigo + "\t" + aux + "=" + $4.conteudo + ";\n";
				}
				else
				{
					$$.tipo = regraCoercao($2.tipo,$4.tipo,string("="));
					$$.codigo = $4.codigo + "\t" + aux + "=(" + $$.tipo + ")" + $4.conteudo + ";\n";
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
				$2.tipo = "float";
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				if($2.tipo == $4.tipo)
				{
					$$.tipo = $2.tipo;
					$$.codigo = $4.codigo + "\t" + aux + "=" + $4.conteudo + ";\n";
				}
				else
				{
					$$.tipo = regraCoercao($2.tipo,$4.tipo,string("="));
					$$.codigo = $4.codigo + "\t" + aux + "=(" + $$.tipo + ")" + $4.conteudo + ";\n";
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
				string aux = criaInstanciaTabela($2.codigo, "double");
				$2.tipo = "double";
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				if($2.tipo == $4.tipo)
				{
					$$.tipo = $2.tipo;
					$$.codigo = $4.codigo + "\t" + aux + "=" + $4.conteudo + ";\n";
				}
				else
				{
					$$.tipo = regraCoercao($2.tipo,$4.tipo,string("="));
					$$.codigo = $4.codigo + "\t" + aux + "=(" + $$.tipo + ")" + $4.conteudo + ";\n";
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
				//MUDAR AQUI PARA FICAR CERTO O BOOLEAN
				string aux = criaInstanciaTabela($2.codigo, "bool");
				$2.tipo = "bool";
				bufferDeclaracoes.push_back("\t" + $1.codigo + " " + aux + ";\n");
				if($2.tipo == $4.tipo)
				{
					$$.tipo = $2.tipo;
					$$.codigo = $4.codigo + "\t" + aux + "=" + $4.conteudo + ";\n";
				}
				else
				{
					$$.tipo = regraCoercao($2.tipo,$4.tipo,string("="));
					$$.codigo = $4.codigo + "\t" + aux + "=(" + $$.tipo + ")" + $4.conteudo + ";\n";
				}
			}
			;

E 			: E '+' E
			{
				$$.conteudo = criaVariavelTemp();

				if($1.tipo == "bool" || $3.tipo == "bool")
					yyerror("operação de soma não permitida entre bools");

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

				if($1.tipo == "bool" || $3.tipo == "bool")
					yyerror("operação de multiplicação não permitida entre bools");

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

				if($1.tipo == "bool" || $3.tipo == "bool")
					yyerror("operação de divisão não permitida entre bools");

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

				if($1.tipo == "bool" || $3.tipo == "bool")
					yyerror("operação de subtração não permitida entre bools");

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
			| '(' TK_TIPO_INT ')' E
			{
				$$.conteudo = criaVariavelTemp();
				$$.tipo = "int";
				bufferDeclaracoes.push_back("\t" + $$.tipo + " " + $$.conteudo + ";\n");
				$$.codigo = $4.codigo + "\t" + $$.conteudo + "=(" + $$.tipo + ")" + $4.conteudo + ";\n";
			}
			| '(' TK_TIPO_FLOAT ')' E
			{
				$$.conteudo = criaVariavelTemp();
				$$.tipo = "float";
				bufferDeclaracoes.push_back("\t" + $$.tipo + " " + $$.conteudo + ";\n");
				$$.codigo = $4.codigo + "\t" + $$.conteudo + "=(" + $$.tipo + ")" + $4.conteudo + ";\n";
			}
			| '(' TK_TIPO_DOUBLE ')' E
			{
				$$.conteudo = criaVariavelTemp();
				$$.tipo = "double";
				bufferDeclaracoes.push_back("\t" + $$.tipo + " " + $$.conteudo + ";\n");
				$$.codigo = $4.codigo + "\t" + $$.conteudo + "=(" + $$.tipo + ")" + $4.conteudo + ";\n";
			}
			| '(' TK_TIPO_BOOL ')' E
			{
				$$.conteudo = criaVariavelTemp();
				$$.tipo = "int";
				bufferDeclaracoes.push_back("\tint " + $$.conteudo + ";\n");
				//MUDAR AQUI PARA FICAR CERTO O BOOLEAN
				$$.codigo = $4.codigo + "\t" + $$.conteudo + "=(" + $$.tipo + ")" + $4.conteudo + ";\n";
			}
			| TK_BOOL
			{
				$$.conteudo = criaVariavelTemp();
				$$.tipo = $1.tipo;
				
				if($1.codigo == "true")
					$1.codigo = "TRUE";
				else
					$1.codigo = "FALSE";
				
				bufferDeclaracoes.push_back("\tint " + $$.conteudo + ";\n");
				$$.codigo = "\t" + $$.conteudo + "=" + $1.codigo + ";\n";
			}
			| TK_INT
			{
				$$.conteudo = criaVariavelTemp();
				$$.tipo = $1.tipo;
				bufferDeclaracoes.push_back("\t" + $$.tipo + " " + $$.conteudo + ";\n");
				$$.codigo = "\t" + $$.conteudo + "=" + $1.codigo + ";\n";
			}
			| TK_FLOAT
			{
				$$.conteudo = criaVariavelTemp();
				$$.tipo = $1.tipo;
				bufferDeclaracoes.push_back("\t" + $$.tipo + " " + $$.conteudo + ";\n");
				$$.codigo = "\t" + $$.conteudo + "=" + $1.codigo + ";\n";
			}
			| TK_ID
			{
				$$.conteudo = criaInstanciaTabela($1.codigo);
				$$.codigo = "";
				if(table[$1.codigo].tipo == "")
				{
					yyerror("Variavel \"" + $1.codigo + "\" não declarada");
				}
				$$.tipo = table[$1.codigo].tipo;
			}
			| E TK_REL E
			{
				if($1.tipo == "bool" || $3.tipo == "bool")
					yyerror(string("operação \"") + to_string(TK_REL) + string("\" não permitida com o tipo bool"));

				$$.conteudo = criaVariavelTemp();
				$$.tipo = "bool";

				bufferDeclaracoes.push_back("\tint " + $$.conteudo + ";\n");

				if($1.tipo == $3.tipo)
				{	
					$$.codigo = $1.codigo + $3.codigo + "\t" + $$.conteudo + "=" + $1.conteudo + $2.codigo + $3.conteudo + ";\n";
				}
				else
				{
					string tipo = regraCoercao($1.tipo, $3.tipo, $2.codigo);
					string variavelCoercao = criaVariavelTemp();
					string codigoCoercao;

					bufferDeclaracoes.push_back("\t" + tipo + " " + variavelCoercao + ";\n");

					if($1.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $1.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao + "\t" + $$.conteudo + "=" + variavelCoercao + $2.codigo + $3.conteudo + ";\n";
					}
					else if($3.tipo != tipo)
					{
						codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + $3.conteudo + ";\n";
						$$.codigo = $1.codigo + $3.codigo + codigoCoercao +"\t" + $$.conteudo + "=" + $1.conteudo + $2.codigo + variavelCoercao + ";\n";
					}
				}
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
	cout << "Erro na linha "<< numeroLinhas << ": " << MSG << endl;
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
	if(operador == string("+") || operador == string("-") || operador == string("/") || operador == string("*")
	|| operador == ">" || operador == "<" || operador == "<=" || operador == ">=")
	{
		if(tipoUm == string("bool") || tipoDois == string("bool"))
		{
			yyerror(string("Operador dessa linha não aceita tipo booleano"));
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
		if(tipoUm == "bool" && tipoDois!= "bool")
		{
			yyerror(string("Não é aceito coerção automatica de ") + tipoDois + " para " + tipoUm);
		}
		else if(tipoUm == "int" && tipoDois!= "bool")
		{
			yyerror(string("Não é aceito coerção automatica de ") + tipoDois + " para " + tipoUm);
		}
		else if(tipoUm == "float" && tipoDois== "double")
		{
			yyerror(string("Não é aceito coerção automatica de ") + tipoDois + " para " + tipoUm);
		}

		return tipoUm;
	}
	if(operador == "==" || operador == "!=")
	{
		if(tipoUm == string("bool") || tipoDois == string("bool"))
		{
			yyerror(string("operadores: soma, subtração, divisão e multiplicação não aceitam tipo booleano"));
			return string("erro");
		}
		else if(tipoUm == string("double") || tipoDois == string("double"))
		{
			//TODO Colocar warning aqui
			return string("double");
		}
		else if(tipoUm == string("float") || tipoDois == string("float"))
		{
			//TODO Colocar warning aqui
			return string("float");
		}
	}
}
