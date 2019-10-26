%{
#include <iostream>
#include <string>
#include <vector>
#include <sstream>

#include <unordered_map>

#define YYSTYPE atributos

#define TESTE cout << "teste" << endl;

using namespace std;

typedef struct {
	string flagInicio;
	string flagFim;
	string flagContadorFor;
} flagsBloco;

typedef struct {
	string conteudo;
	string codigo;
	string tipo;
} atributos;

typedef struct {
	string temporaria;
	string tipo;
	bool atribuido;
} caracteristicas;

int ProxVariavelTemp = 0;
int numeroLinhas = 1;
int proxLabelLoop = 0;
int proxLabel = 0;
int mapAtual = -1;

vector<string> bufferDeclaracoes;
vector< unordered_map<string, caracteristicas> > pilhaMaps;
vector< flagsBloco > pilhaFlagsBlocos;

string criaInstanciaTabela(string, string = "");
void criaFlagLoop(string&, string&, string&);
string criaVariavelTemp(void);
string criaFlag(void);
void yyerror(string);
int yylex(void);

void inicializaPilhaBlocoAtual();

string regraCoercao(string, string, string);
string verificaExistencia(string, int);
void checaLoopsPossiveis(int);
string pegaTipo(string, int);

void imprimeBuffers(void);
void adicionaNoMap(void);
void retiraDoMap(void);

atributos geraCodigoOperacoes(atributos, atributos, string );
atributos geraCodigoCoercaoExplicita(atributos , string );
atributos geraCodigoRelacional(atributos, atributos, string );
atributos geraCodigoDeclaComExp(atributos, atributos, string);
atributos geraCodigoValores(atributos);
atributos geraCodigoAtribuicao(atributos, atributos);
atributos geraCodigoIf(atributos, atributos);
atributos geraCodigoElse(atributos, atributos);
atributos geraCodigoLogico(atributos, atributos, string);
atributos geraCodigoLogicoNot(atributos, string);
atributos geraCodigoOutput(atributos);
atributos geraCodigoInput(atributos);
atributos geraCodigoWhile(atributos, atributos);
atributos geraCodigoFor(atributos, atributos, atributos, atributos);
atributos geraCodigoContinue(string);
atributos geraCodigoBreak(string);
atributos geraCodigoAtribuicaoComposta(atributos, atributos, string);

%}

%token TK_INT TK_FLOAT TK_EXP TK_OCTAL TK_HEX TK_BOOL
%token TK_TIPO_INT TK_TIPO_BOOL TK_TIPO_DOUBLE TK_TIPO_FLOAT
%token TK_IF TK_ELSE TK_INPUT TK_OUTPUT TK_WHILE TK_FOR TK_CONTINUE TK_BREAK
%token TK_ID TK_REL TK_LOGI TK_NOT TK_ATR
%token TK_FIM_LINHA TK_ESPACE TK_TABULACAO
%token TK_FIM TK_ERROR

%start S

%left TK_LOGI
%left TK_NOT
%left TK_REL
%left '+' '-'
%left '*' '/'
%left '(' ')'

%%

S 			: AUX_S COMANDOS
			{
				cout << "/*Compilador Kek*/\n#include <iostream>\n#include <string.h>\n#include <stdio.h>\n#define true 1\n#define false 0\nint main(void)\n{\n";
				imprimeBuffers();
				cout << $2.codigo << "\treturn 0;\n}" << endl;
			}
			;
AUX_S       :
			{
				adicionaNoMap();

				$$.codigo = "";
			}
			;

BLOCO		: AUX_BLOCO '{' COMANDOS '}'
			{
				$$.codigo = $3.codigo;
			}
			;

AUX_BLOCO   : 
			{
				adicionaNoMap();
				
				$$.codigo = "";
			}

BLOCO_LOOP	: AUXBLOCOLO '{' COMANDOS '}'
			{
				$$.codigo = $3.codigo;
			}
			;

AUXBLOCOLO	: 
			{
				adicionaNoMap();
				inicializaPilhaBlocoAtual();
				$$.codigo = "";
			}
			;

CONDI_IF	: TK_IF '(' E ')' BLOCO
			{
				$$ = geraCodigoIf($3,$5);
				retiraDoMap();
			}
			| TK_IF '(' E ')' COMANDO
			{
				$$ = geraCodigoIf($3,$5);
			} 
			;

CONDI_ELSE  : CONDI_IF TK_ELSE BLOCO
			{
				$$ = geraCodigoElse($1, $3);
				retiraDoMap();
			}
			| CONDI_IF TK_ELSE COMANDO
			{
				$$ = geraCodigoElse($1, $3);
			}
			;

WHILE       : TK_WHILE '(' E ')' BLOCO_LOOP
			{
				$$ = geraCodigoWhile($3, $5);
				retiraDoMap();
			}
			;

FOR         : TK_FOR '(' ATRI ';' E ';' E ')' BLOCO_LOOP
			{
				$$ = geraCodigoFor($3, $5, $7, $9);
				retiraDoMap();
			}
			| TK_FOR '(' DECLARA ';' E ';' E ')' BLOCO_LOOP
			{
				$$ = geraCodigoFor($3, $5, $7, $9);
				retiraDoMap();
			}
			;
BREAK		: TK_BREAK '(' TK_INT ')'
			{
				$$ = geraCodigoBreak($3.codigo);
			}
			| TK_BREAK
			{
				$$ = geraCodigoBreak("");
			}
			;
CONTINUE	: TK_CONTINUE '(' TK_INT ')'
			{
				$$ = geraCodigoContinue($3.codigo);
			}
			| TK_CONTINUE
			{
				$$ = geraCodigoContinue("");
			}
			;
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
			| CONDI_IF
			{
				$$ = $1;
			}
			| CONDI_ELSE
			{
				$$ = $1;
			}
			| WHILE
			{
				$$ = $1;
			}
			| FOR
			{
				$$ = $1;
			}
			| INPUT ';'
			{
				$$ = $1;
			}
			| OUTPUT ';'
			{
				$$ = $1;
			}
			| CONTINUE ';'
			{
				$$ = $1;
			}
			| BREAK ';'
			{
				$$ = $1;
			}
			;

ATRI		: TK_ID '=' E
			{
				$$ = geraCodigoAtribuicao($1,$3);
			}
			| TK_ID TK_ATR E
			{
				$$ = geraCodigoAtribuicaoComposta($1,$3,$2.codigo);
			}
			;

INPUT		: TK_ID '=' TK_INPUT '(' ')'
			{
				$$ = geraCodigoInput($1);
			}
			;

OUTPUT		: TK_OUTPUT '(' TK_ID ')'
			{
				$$ = geraCodigoOutput($3);
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
				criaInstanciaTabela($2.codigo, "bool");
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
				$$ = $2;
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
				$$.conteudo = verificaExistencia($1.codigo, mapAtual);
				$$.tipo = pegaTipo($1.codigo, mapAtual);
				$$.codigo = "";
			}
			| E TK_LOGI E
			{
				$$ = geraCodigoLogico($1, $3, $2.codigo);
			}
			| TK_NOT E
			{
				$$ = geraCodigoLogicoNot($2, $1.codigo);
			}
			| E TK_REL E
			{
				$$ = geraCodigoRelacional($1, $3, $2.codigo);	
			}
			| ATRI 
			{
				$$ = $1;
			}
			| DECLARA
			{
				$$ = $1;
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

void criaFlagLoop(string &inicio, string &fim, string &aux) {
	inicio = "INICIO";
	fim = "FIM";
	aux = "CONTADOR";

	int sufixo = proxLabelLoop++;
	inicio += to_string(sufixo);
	fim += to_string(sufixo);
	aux += to_string(sufixo);
}

string criaFlag(void) {
	string prefixoRetornar = "CONDI";
	int sufixoRetornar = proxLabel++;

	prefixoRetornar += to_string(sufixoRetornar);

	return prefixoRetornar;
}

string verificaExistencia(string variavel, int mapBusca){
	// unordered_map<string, caracteristicas> table = (pilhaMaps[mapBusca]);

	if(mapBusca == 0) {
		unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (pilhaMaps[mapBusca]).find(variavel);

		if ( linhaDaVariavel == (pilhaMaps[mapBusca]).end() ){
			yyerror("Variavel \""+ variavel +"\" não declarada");
		} else {
			return (pilhaMaps[mapBusca])[variavel].temporaria;
		}
		yyerror("Erro na função de verificação do ID");
	} else {
		unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (pilhaMaps[mapBusca]).find(variavel);
		if ( linhaDaVariavel == (pilhaMaps[mapBusca]).end() ){
			return verificaExistencia(variavel, mapBusca - 1);
		}
		else {
			return (pilhaMaps[mapBusca])[variavel].temporaria;
		}
		yyerror("Erro na função de verificação do ID");
	}
	yyerror("Erro na função de verificação do ID");
}

string criaInstanciaTabela(string variavel, string tipo) {
	// unordered_map<string, caracteristicas> table = (pilhaMaps[mapAtual]);

	unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (pilhaMaps.back()).find(variavel);

	if ( linhaDaVariavel == (pilhaMaps.back()).end() ){
		caracteristicas novaVariavel;

		novaVariavel.temporaria = criaVariavelTemp();

		novaVariavel.tipo = tipo;
		novaVariavel.atribuido = false;

		(pilhaMaps.back())[variavel] = novaVariavel;

		if(tipo == "bool")
			bufferDeclaracoes.push_back("\tint " + (pilhaMaps.back())[variavel].temporaria + ";\n");
		else
			bufferDeclaracoes.push_back("\t" + tipo + " " + (pilhaMaps.back())[variavel].temporaria + ";\n");

		return (pilhaMaps.back())[variavel].temporaria;
	}
	else {
		return (pilhaMaps.back())[variavel].temporaria;
	}
	return "";
}

void imprimeBuffers(void) {
	for (auto declaracao : bufferDeclaracoes)
	{
		cout << declaracao;
	}
	cout << "\n\n";
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
		if(tipoUm == "bool" && tipoDois != "bool" && tipoDois != "int")
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
	if(operador == "or" || operador == "and" || operador == "not") {
		if(tipoUm != "bool" || tipoDois != "bool"){
			yyerror("operações logicas só podem ser feitas entre booleanos.");
		} else {
			return "bool";
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

	string aux = verificaExistencia(elementoUm.codigo, mapAtual);
	
	string tipoAux = pegaTipo(elementoUm.codigo, mapAtual);

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

atributos geraCodigoAtribuicaoComposta(atributos elementoUm, atributos elementoDois, string tipo) {
	atributos structRetorno;

	string aux = verificaExistencia(elementoUm.codigo, mapAtual);
	
	string tipoAux = pegaTipo(elementoUm.codigo, mapAtual);

	if(elementoDois.tipo == tipoAux)
	{
		structRetorno.codigo = elementoDois.codigo + "\t" + aux + "=" + aux + tipo[0] + elementoDois.conteudo + ";\n";
		structRetorno.conteudo = aux;
		structRetorno.tipo = "ope";
	}
	else
	{
		string tempTipo = regraCoercao(tipoAux,elementoDois.tipo,"=");
		structRetorno.codigo = elementoDois.codigo + "\t" + aux + "=" + aux + tipo[0] + "(" + tempTipo + ")" + elementoDois.conteudo + ";\n";
		structRetorno.conteudo = aux;
		structRetorno.tipo = "ope";
	}

	return structRetorno;
}

atributos geraCodigoIf(atributos exprecao, atributos bloco) {
	atributos structRetorno;
	
	structRetorno.tipo = "condicional";

	string auxCondicao = criaVariavelTemp();
	
	structRetorno.conteudo = auxCondicao;

	bufferDeclaracoes.push_back("\tint " + auxCondicao + ";\n");

	string auxFlag = criaFlag();

	string tipo = regraCoercao("bool",exprecao.tipo,"=");

	structRetorno.codigo = exprecao.codigo + "\t" + auxCondicao + "=" + exprecao.conteudo + ";\n\t" + auxCondicao + "=!" + auxCondicao + ";\n";
	
	structRetorno.codigo += "\tif(" + auxCondicao + ")\n\t  goto " + auxFlag + ";\n" + bloco.codigo + auxFlag + ":\n"; 

	return structRetorno;
}

atributos geraCodigoElse(atributos atriIf, atributos bloco) {
	atributos structRetorno;
	
	structRetorno.tipo = "condicional";
	structRetorno.conteudo = "";

	string auxCondicao = atriIf.conteudo;

	string auxFlag = criaFlag();

	int localCondi = atriIf.codigo.rfind("CONDI");

	structRetorno.codigo = atriIf.codigo;

	structRetorno.codigo.insert(localCondi, "\tgoto " + auxFlag + ";\n");

	structRetorno.codigo += bloco.codigo + auxFlag + ":\n";

	return structRetorno;
}

void retiraDoMap(void) {
	pilhaMaps.pop_back();

	pilhaFlagsBlocos.pop_back();

	mapAtual--;
}

void adicionaNoMap(void) {
	unordered_map<string, caracteristicas> auxMapGlobal;
	pilhaMaps.push_back(auxMapGlobal);

	flagsBloco auxFlagMaps;
	pilhaFlagsBlocos.push_back(auxFlagMaps);

	mapAtual++;
}

string pegaTipo(string variavel, int mapBusca) {
	if(mapBusca == 0) {
		unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (pilhaMaps[mapBusca]).find(variavel);

		if ( linhaDaVariavel == (pilhaMaps[mapBusca]).end() ){
			yyerror("Variavel \""+ variavel +"\" não declarada");
		} else {
			return (pilhaMaps[mapBusca])[variavel].tipo;
		}
		yyerror("Erro na função de verificação do ID");
	} else {
		unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (pilhaMaps[mapBusca]).find(variavel);

		if ( linhaDaVariavel == (pilhaMaps[mapBusca]).end() ){
			return pegaTipo(variavel, mapBusca - 1);
		}
		else {
			return (pilhaMaps[mapBusca])[variavel].tipo;
		}
		yyerror("Erro na função de verificação do ID");
	}
	yyerror("Erro na função de verificação do ID");
}

atributos geraCodigoLogico(atributos elementoUm, atributos elementoDois, string operacao) {
	atributos structRetorno;

	structRetorno.tipo = regraCoercao(elementoUm.tipo, elementoDois.tipo, operacao);
	structRetorno.conteudo = criaVariavelTemp();

	bufferDeclaracoes.push_back("\tint " + structRetorno.conteudo + ";\n");

	if(operacao =="or")
		structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + "||" + elementoDois.conteudo + ";\n";
	else
		structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + "&&" + elementoDois.conteudo + ";\n";
	
	return structRetorno;
}

atributos geraCodigoLogicoNot(atributos elemento, string operacao) {
	atributos structRetorno;

	structRetorno.tipo = regraCoercao(elemento.tipo, "bool", operacao);
	structRetorno.conteudo = criaVariavelTemp();

	bufferDeclaracoes.push_back("\tint " + structRetorno.conteudo + ";\n");

	structRetorno.codigo = elemento.codigo + "\t" + structRetorno.conteudo + "=!" + elemento.conteudo + ";\n";
	
	return structRetorno;
}

atributos geraCodigoInput(atributos variavel) {
	atributos structRetorno;

	structRetorno.tipo = "input";
	structRetorno.conteudo = "";
	structRetorno.codigo = "\tstd::cin >> " + verificaExistencia(variavel.codigo, mapAtual) + ";\n";

	return structRetorno;
}

atributos geraCodigoOutput(atributos variavel) {
	atributos structRetorno;

	structRetorno.tipo = "output";
	structRetorno.conteudo = "";
	structRetorno.codigo = "\tstd::cout << " + verificaExistencia(variavel.codigo, mapAtual) + " << std::endl;\n";

	return structRetorno;
}

atributos geraCodigoWhile(atributos exprecao, atributos bloco) {
	atributos structRetorno;
	
	structRetorno.tipo = "loop";

	string auxCondicao = criaVariavelTemp();
	
	structRetorno.conteudo = auxCondicao;

	bufferDeclaracoes.push_back("\tint " + auxCondicao + ";\n");

	string flagInicio = pilhaFlagsBlocos[mapAtual].flagInicio;
	string flagFim = pilhaFlagsBlocos[mapAtual].flagFim;
	
	string tipo = regraCoercao("bool",exprecao.tipo,"=");

	structRetorno.codigo = exprecao.codigo + "\t" + auxCondicao + "=" + exprecao.conteudo + ";\n\t" + auxCondicao + "=!" + auxCondicao + ";\n";

	structRetorno.codigo += flagInicio + ":\n\tif(" + auxCondicao + ")\n\t  goto " + flagFim + ";\n" + bloco.codigo + "\tgoto " + flagInicio + ";\n" + flagFim + ":\n"; 

	return structRetorno;
}

atributos geraCodigoFor(atributos exprecaoUm, atributos exprecaoDois, atributos exprecaoTres, atributos bloco) {
	atributos structRetorno;
	
	structRetorno.tipo = "loop";

	string auxCondicao = criaVariavelTemp();
	
	structRetorno.conteudo = auxCondicao;

	bufferDeclaracoes.push_back("\tint " + auxCondicao + ";\n");

	string flagInicio = pilhaFlagsBlocos[mapAtual].flagInicio;
	string flagFim = pilhaFlagsBlocos[mapAtual].flagFim;
	string flagContadorFor = pilhaFlagsBlocos[mapAtual].flagContadorFor;

	string tipo = regraCoercao("bool",exprecaoDois.tipo,"=");

	structRetorno.codigo = exprecaoUm.codigo + "\tgoto " + flagContadorFor + ";\n" + flagInicio + ":\n" + exprecaoTres.codigo + flagContadorFor + ":\n";

	structRetorno.codigo += exprecaoDois.codigo + "\t" + auxCondicao + "=" + exprecaoDois.conteudo + ";\n\t" + auxCondicao + "=!" + auxCondicao + ";\n"; 

	structRetorno.codigo += "\tif(" + auxCondicao + ")\n\t  goto " + flagFim + ";\n" + bloco.codigo +"\tgoto " + flagInicio + ";\n" + flagFim + ":\n"; 

	return structRetorno;
}

void inicializaPilhaBlocoAtual(void) {
	string flagInicio, flagFim, flagContadorFor;

	criaFlagLoop(flagInicio, flagFim, flagContadorFor);

	pilhaFlagsBlocos[mapAtual].flagInicio = flagInicio;
	pilhaFlagsBlocos[mapAtual].flagFim = flagFim;
	pilhaFlagsBlocos[mapAtual].flagContadorFor = flagContadorFor;
}

atributos geraCodigoContinue(string qualLoop) {
	atributos structRetorno;

	structRetorno.tipo = "";
	structRetorno.conteudo = "";
	
	if (qualLoop != "") {
		int quantosLoops = stoi(qualLoop);	
		
		checaLoopsPossiveis(quantosLoops);
		
		structRetorno.codigo = "\tgoto " + pilhaFlagsBlocos[mapAtual - quantosLoops + 1].flagInicio + ";\n";
	} else {
		checaLoopsPossiveis(1);
		structRetorno.codigo = "\tgoto " + pilhaFlagsBlocos[mapAtual].flagInicio + ";\n";
	}

	return structRetorno;
}

atributos geraCodigoBreak(string qualLoop) {
	atributos structRetorno;

	structRetorno.tipo = "";
	structRetorno.conteudo = "";
	
	if (qualLoop != "") {
		int quantosLoops = stoi(qualLoop);	
		
		checaLoopsPossiveis(quantosLoops);
		
		structRetorno.codigo = "\tgoto " + pilhaFlagsBlocos[mapAtual - quantosLoops + 1].flagFim + ";\n";
	} else {
		checaLoopsPossiveis(1);
		structRetorno.codigo = "\tgoto " + pilhaFlagsBlocos[mapAtual].flagFim + ";\n";
	}

	return structRetorno;
}

void checaLoopsPossiveis(int quantosLoops) {

	int quantosLoopsPossiveis = 0;

	for(int i = mapAtual; i >= 0 ; i--) {
		if (pilhaFlagsBlocos[i].flagInicio != "" && pilhaFlagsBlocos[i].flagFim != "") {
			
			quantosLoopsPossiveis++;

		} else {
			break;
		}
	}

	if ( quantosLoops <= 0  || quantosLoops > quantosLoopsPossiveis) {
		yyerror("Não é possivel realizar essa operação nessa quantidade de loops");
	}
}

