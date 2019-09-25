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

typedef struct atributos atributos;

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
string verificaExistencia(string );
bool verificaTiposEmOperacoes(string,string,string&);
void imprimeBuffers(void);
string regraCoercao(string, string, string);
atributos geraCodigoOperacoes(atributos, atributos, string );
atributos geraCodigoCoercaoExplicita(atributos , string );
atributos geraCodigoRelacional(atributos, atributos, string );
atributos geraCodigoDeclaComExp(atributos, atributos, string);
atributos geraCodigoValores(atributos);
atributos geraCodigoAtribuicao(atributos, atributos);

%}

%token TK_INT TK_FLOAT TK_EXP TK_OCTAL TK_HEX TK_BOOL
%token TK_TIPO_INT TK_TIPO_BOOL TK_TIPO_DOUBLE TK_TIPO_FLOAT
%token TK_TIPO_IF
%token TK_ID TK_REL
%token TK_FIM_LINHA TK_ESPACE TK_TABULACAO
%token TK_FIM TK_ERROR

%start S

%left TK_REL
%left '+' '-'
%left '*' '/'
%left '(' ')'


%%

S 			: COMANDOS
			{
				cout << "/*Compilador Kek*/\n#include <iostream>\n#include <string.h>\n#include <stdio.h>\n#define true 1\n#define false 0\nint main(void)\n{\n";
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
				$$ = geraCodigoAtribuicao($1,$3);
			}
			;

DECLARA		: TK_TIPO_INT TK_ID
			{
				criaInstanciaTabela($2.codigo, "int");
				$$.codigo = "";
			}
			| TK_TIPO_INT TK_ID '=' E
			{
				$$ = geraCodigoDeclaComExp($2,$4,"int");
			}
			| TK_TIPO_FLOAT TK_ID
			{
				criaInstanciaTabela($2.codigo, "float");
				$$.codigo = "";
			}
			| TK_TIPO_FLOAT TK_ID '=' E
			{
				$$ = geraCodigoDeclaComExp($2,$4,"float");
			}
			| TK_TIPO_DOUBLE TK_ID
			{
				criaInstanciaTabela($2.codigo, "double");
				$$.codigo = "";
			}
			| TK_TIPO_DOUBLE TK_ID '=' E
			{
				$$ = geraCodigoDeclaComExp($2,$4,"double");
			}
			| TK_TIPO_BOOL TK_ID
			{
				criaInstanciaTabela($2.codigo, "float");
				$$.codigo = "";
			}
			| TK_TIPO_BOOL TK_ID '=' E
			{
				$$ = geraCodigoDeclaComExp($2,$4,"bool");
			}
			;

E 			: E '+' E
			{
				$$ = geraCodigoOperacoes($1,$3,"+");
			}
			| E '*' E
			{
				$$ = geraCodigoOperacoes($1,$3,"*");
			}
			| E '/' E
			{
			    $$ = geraCodigoOperacoes($1,$3,"/");
			}
			| E '-' E
			{
			    $$ = geraCodigoOperacoes($1,$3,"-");
			}
			| '(' E ')'
			{
				$$.conteudo = $2.conteudo;
				$$.codigo = $2.codigo;
				$$.tipo = $2.tipo;
			}
			| '(' TK_TIPO_INT ')' E
			{
				$$ = geraCodigoCoercaoExplicita($4,"int");
			}
			| '(' TK_TIPO_FLOAT ')' E
			{
				$$ = geraCodigoCoercaoExplicita($4,"float");
			}
			| '(' TK_TIPO_DOUBLE ')' E
			{
				$$ = geraCodigoCoercaoExplicita($4,"double");
			}
			| '(' TK_TIPO_BOOL ')' E
			{
				$$ = geraCodigoCoercaoExplicita($4,"bool");
			}
			| TK_BOOL
			{
				$$ = geraCodigoValores($1);
			}
			| TK_INT
			{
				$$ = geraCodigoValores($1);
			}
			| TK_FLOAT
			{
				$$ = geraCodigoValores($1);
			}
			| TK_ID
			{
				$$.conteudo = verificaExistencia($1.codigo);
				$$.tipo = table[$1.codigo].tipo;
				$$.codigo = "";
			}
			| E TK_REL E
			{
				$$ = geraCodigoRelacional($1,$3,$2.codigo);
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

string verificaExistencia(string variavel){
	unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = table.find(variavel);

	if ( linhaDaVariavel == table.end() ){
		yyerror("Variavel \""+ variavel +"\" não declarada");
	}
	else {
		return table[variavel].temporaria;
	}
	return "";
}

string criaInstanciaTabela(string variavel, string tipo) {
	unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = table.find(variavel);

	if ( linhaDaVariavel == table.end() ){
		caracteristicas novaVariavel;

		novaVariavel.temporaria = criaVariavelTemp();

		novaVariavel.tipo = tipo;
		table[variavel] = novaVariavel;

		if(tipo == "bool")
			bufferDeclaracoes.push_back("\tint " + table[variavel].temporaria + ";\n");
		else
			bufferDeclaracoes.push_back("\t" + tipo + " " + table[variavel].temporaria + ";\n");

		return table[variavel].temporaria;
	}
	else {
		return table[variavel].temporaria;
	}
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
		else if(tipoUm == "int" && tipoDois != "int")
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

atributos geraCodigoOperacoes(atributos elementoUm, atributos elementoDois, string operacao) {
	atributos structRetorno;

	structRetorno.conteudo = criaVariavelTemp();

	if(elementoUm.tipo == "bool" || elementoDois.tipo == "bool")
		yyerror("operação \"" + operacao + "\" não permitida entre bools");

	if(elementoUm.tipo == elementoDois.tipo)
	{
		structRetorno.tipo = elementoUm.tipo;
		bufferDeclaracoes.push_back("\t" + structRetorno.tipo + " " + structRetorno.conteudo + ";\n");
		structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + operacao + elementoDois.conteudo + ";\n";
	}
	else
	{
		string tipo = regraCoercao(elementoUm.tipo,elementoDois.tipo,string("+"));
		string variavelCoercao = criaVariavelTemp();
		string codigoCoercao;
		structRetorno.tipo = tipo;
		bufferDeclaracoes.push_back("\t" + tipo + " " + structRetorno.conteudo + ";\n");
		bufferDeclaracoes.push_back("\t" + tipo + " " + variavelCoercao + ";\n");
		if(elementoUm.tipo != tipo)
		{
			codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + elementoUm.conteudo + ";\n";
			structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + codigoCoercao + "\t" + structRetorno.conteudo + "=" + variavelCoercao + operacao + elementoDois.conteudo + ";\n";
		}
		else if(elementoDois.tipo != tipo)
		{
			codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + elementoDois.conteudo + ";\n";
			structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + codigoCoercao +"\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + operacao + variavelCoercao + ";\n";
		}
	}

	return structRetorno;
}

atributos geraCodigoCoercaoExplicita(atributos elemento, string tipo) {
	atributos structRetorno;
	
	structRetorno.conteudo = criaVariavelTemp();
	structRetorno.tipo = tipo;

	if(tipo == "bool")
	{
		bufferDeclaracoes.push_back("\tint" + structRetorno.conteudo + ";\n");
		structRetorno.codigo = elemento.codigo + "\t" + structRetorno.conteudo + "=(int)" + elemento.conteudo + ";\n";
	}
	else
	{
		bufferDeclaracoes.push_back("\t" + tipo + " " + structRetorno.conteudo + ";\n");
		structRetorno.codigo = elemento.codigo + "\t" + structRetorno.conteudo + "=(" + structRetorno.tipo + ")" + elemento.conteudo + ";\n";
	}
	return structRetorno;
}

atributos geraCodigoRelacional(atributos elementoUm, atributos elementoDois, string operacao) {
	atributos structRetorno;

	if(elementoUm.tipo == "bool" || elementoDois.tipo == "bool")
		yyerror(string("operação \"") + operacao + ("\" não permitida com o tipo bool"));

	structRetorno.conteudo = criaVariavelTemp();
	structRetorno.tipo = "bool";

	bufferDeclaracoes.push_back("\tint " + structRetorno.conteudo + ";\n");

	if(elementoUm.tipo == elementoDois.tipo)
	{	
		structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + operacao + elementoDois.conteudo + ";\n";
	}
	else
	{
		string tipo = regraCoercao(elementoUm.tipo, elementoDois.tipo, operacao);
		string variavelCoercao = criaVariavelTemp();
		string codigoCoercao;

		bufferDeclaracoes.push_back("\t" + tipo + " " + variavelCoercao + ";\n");

		if(elementoUm.tipo != tipo)
		{
			codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + elementoUm.conteudo + ";\n";
			structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + codigoCoercao + "\t" + structRetorno.conteudo + "=" + variavelCoercao + operacao + elementoDois.conteudo + ";\n";
		}
		else if(elementoDois.tipo != tipo)
		{
			codigoCoercao = "\t" + variavelCoercao + "=(" + tipo + ")" + elementoDois.conteudo + ";\n";
			structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + codigoCoercao +"\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + operacao + variavelCoercao + ";\n";
		}
	}

	return structRetorno;
}

atributos geraCodigoDeclaComExp(atributos elementoUm, atributos elementoDois, string tipo) {
	atributos structRetorno;

	elementoUm.tipo = tipo;
	
	string aux = criaInstanciaTabela(elementoUm.codigo, tipo);
	
	if(elementoUm.tipo == elementoDois.tipo)
	{
		structRetorno.tipo = elementoUm.tipo;
		structRetorno.codigo = elementoDois.codigo + "\t" + aux + "=" + elementoDois.conteudo + ";\n";
	}
	else
	{
		structRetorno.tipo = regraCoercao(elementoUm.tipo,elementoDois.tipo,"=");
		structRetorno.codigo = elementoDois.codigo + "\t" + aux + "=(" + structRetorno.tipo + ")" + elementoDois.conteudo + ";\n";
	}

	return structRetorno;
}

atributos geraCodigoValores(atributos elemento) {
	atributos structRetorno;

	structRetorno.conteudo = criaVariavelTemp();
	structRetorno.tipo = elemento.tipo;
	if(structRetorno.tipo == "bool")
	{
		bufferDeclaracoes.push_back("\tint " + structRetorno.conteudo + ";\n");
		structRetorno.codigo = "\t" + structRetorno.conteudo + "=" + elemento.codigo + ";\n";
	}
	else
	{
		bufferDeclaracoes.push_back("\t" + structRetorno.tipo + " " + structRetorno.conteudo + ";\n");
		structRetorno.codigo = "\t" + structRetorno.conteudo + "=" + elemento.codigo + ";\n";
	}

	return structRetorno;
}

atributos geraCodigoAtribuicao(atributos elementoUm, atributos elementoDois) {
	atributos structRetorno;

	string aux = verificaExistencia(elementoUm.codigo);
	string tipoAux = table[elementoUm.codigo].tipo;
	
	if(elementoDois.tipo == tipoAux)
	{
		structRetorno.codigo = elementoDois.codigo + "\t" + aux + "=" + elementoDois.conteudo + ";\n";
		structRetorno.conteudo = aux;
		structRetorno.tipo = "ope";
	}
	else
	{
		string tempTipo = regraCoercao(tipoAux,elementoDois.tipo,"=");
		structRetorno.codigo = elementoDois.codigo + "\t" + aux + "=(" + tempTipo + ")" + elementoDois.conteudo + ";\n";
		structRetorno.conteudo = aux;
		structRetorno.tipo = "ope";
	}

	return structRetorno;
}