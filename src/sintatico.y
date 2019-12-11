%{
	#include <iostream>
	#include <string>
	#include <algorithm>
	#include <vector>
	#include <sstream>
	#include <unordered_map>
	#include <map>

	#define YYSTYPE atributos

	using namespace std;

	// Usada para modificar a maneira que o map ordena. Ele ordena string por ordem alfabetica,
	// precisamos ordenar pelo numero da temporaria.
	class compare_map_tmp {
		public:
			bool operator() (const string& chaveUm, const string& chaveDois) const {
				int numUm = stoi(chaveUm.substr(3));
				int numDois = stoi(chaveDois.substr(3));

				return numUm < numDois;
			}
	};

	typedef struct {
		string flagInicio;
		string flagFim;
		string flagContadorFor;
	} flagsBloco;

	typedef struct {
		string conteudo;
		string codigo;
		string tipo;
		string tamanho;
	} atributos;

	typedef struct {
		string temporaria;
		string tipo;
		string tamanho;
	} caracteristicas;

	typedef struct {
		string temporaria;
		string tipo;
		string tamanho;
		string flagFim;
	} informacoesSwitch;

	typedef struct {
		vector<string> tipoParametros;

		vector<atributos> valoresParaParametros;

		int posicaoInicioOpcionais = -1;
		string tipoRetorno;
		string temporaria;
	} identificadorFuncao;

	typedef struct {
		unordered_map<string, vector< identificadorFuncao >> mapFuncoes;
		vector<atributos> valoresParaParametros;
		vector<string> parametrosOpcionais;
		int posicaoInicioOpcionais = -1;
		vector<string> tipoParametros;
		vector<string> parametros;
		string tipoRetorno;

		bool semRetorno = true;


		map<string, string, compare_map_tmp> mapDeclaracoes;


		vector< unordered_map<string, caracteristicas> > pilhaMaps;
		vector< informacoesSwitch > pilhaInformacoesSwitch;
		vector< flagsBloco > pilhaFlagsBlocos;

		int informacoesSwitchAtual = -1;
		int mapAtual = -1;
	} caracteristicasFuncao;

	// ------------------------ Variaveis globais utilizadas -------------------------------------
		int numeroLinhas = 1;

		// usado para gerar variaveis e flags unicas
		int ProxVariavelTemp = 0;
		int proxLabelLoop = 0;
		int proxLabel = 0;

		vector<caracteristicasFuncao> pilhaFuncao;
		int funcaoAtual = -1;

		string declaracoesString;

		vector< vector<identificadorFuncao> > auxChamadaFuncao;
		vector< int > auxQualParametro;

		#define FUN pilhaFuncao[funcaoAtual]
	// Funcoes de utilidade ----------------------------------------------------------------------
		string criaInstanciaTabela(string, string = "", string="0");
		void criaFlagLoop(string&, string&, string&);
		void inicializaFlagsDaPilhaDeBloco();
		string criaVariavelTemp(void);
		string criaFlag(void);


		string regraCoercao(string, string, string);


		atributos geraAtributosParaId(atributos);


		int calculaTamanhoMaximoString(int);


		void checaLoopsPossiveis(int);


		//TODO refatorar ? fazem a mesma busca.
		string verificaExistencia(string, int);
		void adicionaTamanho(string, int, string);
		string pegaTamanho(string , int);
		string pegaTipo(string, int);


		bool isStructVazia(atributos);
		atributos structVazia(void);


		void imprimeDeclaracoes(map<string, string, compare_map_tmp>);

		void adicionaNoMap(void);
		void retiraDoMap(void);


		void atualizaTipoInformacoesSwitch(string);
		void empilhaInformacoesSwitch(void);
		void retiraInformacoesSwitch(void);

		void geraCodigoDeclaracaoStringOperacoes(atributos&, string , string);
		void geraCodigoDeclaracaoString(string, string);

		string geraCodigoCalculaTamanhoMaximoString(string , string);


		atributos geraCodigoDefault(atributos);


		void yyerror(string);
		int yylex(void);

	// Geradores auxiliares ----------------------------------------------------------------------
		string geraCodigoErroExecucao(string, string="0");
		string geraCodigoCoercaoStringToInt(string, string, string);
		string geraCodigoCoercaoStringToFloat(string, string, string);
		void geraCodigoCoercao(atributos&, atributos&, atributos&, string);
	
	// Geradores de atribuicao -------------------------------------------------------------------
		atributos geraCodigoAtribuicao(atributos, atributos);
		atributos geraCodigoAtribuicaoString(atributos, atributos);
		atributos geraCodigoAtribuicaoComposta(atributos, atributos, string);
	// Geradores de declaracoes ------------------------------------------------------------------
		atributos geraCodigoDeclaComExp(atributos, atributos, string);
	// Geradores de exprecoes --------------------------------------------------------------------
		atributos geraCodigoValores(atributos);

		atributos geraCodigoCoercaoExplicita(atributos , string );
		atributos geraCodigoOperacoes(atributos, atributos, string );

		atributos geraCodigoLogicoNot(atributos, string);
		atributos geraCodigoLogico(atributos, atributos, string);
		atributos geraCodigoRelacional(atributos, atributos, string );

		atributos geraCodigoOperadorTamanho(atributos);
	// Geradores de Estruturas -------------------------------------------------------------------

		atributos geraCodigoIf(atributos, atributos);
		atributos geraCodigoElse(atributos, atributos);


		atributos geraCodigoOutput(atributos);
		atributos geraCodigoParaMultiploOutput(atributos, atributos);


		atributos geraCodigoInput(atributos);
		string geraCodigoInputString(atributos);
		atributos geraCodigoParaMultiploInput(atributos, atributos, atributos);


		atributos geraCodigoWhile(atributos, atributos);
		atributos geraCodigoFor(atributos, atributos, atributos, atributos);


		atributos geraCodigoBreak(string);
		atributos geraCodigoContinue(string);


		atributos geraCodigoCase(atributos, atributos);
		atributos geraCodigoSwitch(atributos, atributos, atributos);
	// Geradores Funcao --------------------------------------------------------------------------
		void adicionaNoMapFuncoes(void);

		void retiraDoMapFuncoes(void);

		void verificaExistenciaFuncao(string, int);

		atributos geraCodigoChamadaFuncao(atributos, atributos);

		atributos geraCodigoChamadaFuncaoComando(atributos id, atributos parametros);

		atributos geraCodigoExpreDeclaraFuncao(atributos, atributos);

		atributos geraCodigoReturn(atributos);

		void setaCodigoParametros(string, atributos, atributos);

		string criaInstanciaTabelaParametro(string, string, string="0");

		string adicionaDeclaracoesFuncao(void);

		atributos geraCodigoDeclaracaoFuncao(string, atributos);

%}

%token TK_INT TK_FLOAT TK_EXP TK_OCTAL TK_HEX TK_BOOL TK_STR
%token TK_TIPO_INT TK_TIPO_BOOL TK_TIPO_DOUBLE TK_TIPO_FLOAT TK_TIPO_STR TK_TIPO_VOID
%token TK_IF TK_ELSE TK_INPUT TK_OUTPUT TK_WHILE TK_FOR TK_CONTINUE TK_BREAK TK_SWITCH TK_DEF
%token TK_ID TK_REL TK_LOGI TK_NOT TK_ATR TK_OP_LEN TK_CASE TK_DEFAULT TK_SETA TK_RETURN

%start S

%left TK_LOGI
%left TK_NOT
%left TK_REL
%left '+' '-'
%left '*' '/' '%'
%left TK_OP_LEN
%left '(' ')'

%%

S 			: AUX_S COMANDOS
			{
				cout << "/*Compilador Kek*/\n#include <iostream>\n#include <string.h>\n#include <stdio.h>\n#define true 1\n#define false 0\n\n\n";
				imprimeDeclaracoes(FUN.mapDeclaracoes);
				cout << "// --------------------------- Declaracao funcoes ----------------------------"<< endl;
				cout << declaracoesString;
				cout << "// --------------------------- Fim Declaracao funcoes ----------------------------"<< endl;
				cout << "int main(void)\n{\n" << $2.codigo << "\treturn 0;\n}" << endl;
			}
			;

AUX_S       :
			{
				adicionaNoMapFuncoes();
				adicionaNoMap();
				$$.codigo = "";
			}
			;

BLOCO		: AUX_BLOCO '{' COMANDOS '}'
			{
				$$.codigo = $3.codigo;
				retiraDoMap();
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
				retiraDoMap();
			}
			;

AUXBLOCOLO	: 
			{
				adicionaNoMap();
				inicializaFlagsDaPilhaDeBloco();
				$$.codigo = "";
			}
			;

CONDI_IF	: TK_IF '(' E ')' BLOCO
			{
				$$ = geraCodigoIf($3,$5);
			}
			| TK_IF '(' E ')' COMANDO
			{
				$$ = geraCodigoIf($3,$5);
			}
			;

CONDI_ELSE  : CONDI_IF TK_ELSE BLOCO
			{
				$$ = geraCodigoElse($1, $3);
			}
			| CONDI_IF TK_ELSE COMANDO
			{
				$$ = geraCodigoElse($1, $3);
			}
			;

SWITCH		: AUX_SWITCH TK_SWITCH '(' AUX_E_SWI ')' '{' CASES '}'
			{
				atributos defaul;
				defaul.codigo = "";
				$$ = geraCodigoSwitch($4, $7, defaul);
				retiraInformacoesSwitch();
			}
			| AUX_SWITCH TK_SWITCH '(' AUX_E_SWI ')' '{' CASES DEFAULT '}'
			{
				$$ = geraCodigoSwitch($4, $7, $8);
				retiraInformacoesSwitch();
			}
			;

AUX_E_SWI	: E
			{
				$$ = $1;
				atualizaTipoInformacoesSwitch($1.tipo);
			}
			;

AUX_SWITCH	:
			{
				empilhaInformacoesSwitch();
			}
			;

DEFAULT		: TK_DEFAULT BLOCO
			{
				$$ = geraCodigoDefault($2);
			}
			;

CASE		: TK_CASE '(' E ')' BLOCO
			{
				$$ = geraCodigoCase($3, $5);
			}
			;

CASES		: CASE CASES
			{
				$$.codigo = $1.codigo + $2.codigo;
			}
			| 
			{
				$$.codigo="";
			}
			;

WHILE       : TK_WHILE '(' E ')' BLOCO_LOOP
			{
				$$ = geraCodigoWhile($3, $5);
			}
			;

FOR         : TK_FOR '(' AUXLOOP ';' E ';' ATRIS ')' BLOCO_LOOP
			{
				$$ = geraCodigoFor($3, $5, $7, $9);
			}
			;

ATRIS		: ATRI ',' ATRIS
			{
				$$.codigo = $1.codigo + $3.codigo;
			}
			| ATRI
			{
				$$.codigo = $1.codigo;
			}
			|
			{
				$$.codigo = "";
			}
			;

AUXLOOP		: DECLARA ',' AUXLOOP
			{
				$$.codigo = $1.codigo + $3.codigo;
			}
			| ATRI ',' AUXLOOP
			{
				$$.codigo = $1.codigo + $3.codigo;
			}
			| DECLARA
			{
				$$.codigo = $1.codigo;
			}
			| ATRI
			{
				$$.codigo = $1.codigo;
			}
			|
			{
				$$.codigo = "";
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
			| SWITCH
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
			| DECLA_FUN
			{
				$$ = $1;
			}
			| AUX_F_C '(' AUX_C_FUN ')' ';'
			{
				$$ = geraCodigoChamadaFuncaoComando($1, $3);
			}
			;
			| RETURN ';'
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

INPUT		: IDS '=' TK_INPUT '(' ')'
			{
				$$ = geraCodigoInput($1);
			}
			| TK_ID '=' TK_INPUT '(' ')'
			{
				$$ = geraCodigoInput($1);
			}
			;

IDS			: TK_ID ',' TK_ID IDS
			{
				$$ = geraCodigoParaMultiploInput($1, $3, $4);
			}
			| ',' TK_ID IDS
			{
				$$ = geraCodigoParaMultiploInput($2, structVazia(), $3);
			}
			|
			{
				$$.codigo = "";
			}
			;

OUTPUT		: TK_OUTPUT '(' ES ')'
			{
				$$ = geraCodigoOutput($3);
			}
			;

ES			: E ',' ES
			{
				$$ = geraCodigoParaMultiploOutput($1, $3);
			}
			| E
			{
				$$.codigo = $1.codigo;
			}
			|
			{
				$$.codigo = "";
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
			| TK_TIPO_STR TK_ID
			{
				criaInstanciaTabela($2.codigo, "str","0");
				$$.codigo = "";
			}
			| TK_TIPO_STR TK_ID '=' E
			{
				$$ = geraCodigoDeclaComExp($2,$4,"str");
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
			| E '%' E
			{
			    $$ = geraCodigoOperacoes($1,$3,"%");
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
			| TK_STR
			{
				$$ = geraCodigoValores($1);
			}
			| TK_ID
			{
				$$ = geraAtributosParaId($1);
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
			| E TK_OP_LEN '(' ')' 
			{
				$$ = geraCodigoOperadorTamanho($1);
			}
			| AUX_F_C '(' AUX_C_FUN ')'
			{
				$$ = geraCodigoChamadaFuncao($1, $3);
			}
			;

AUX_C_FUN	: AUX_C_FUN ',' E
			{
				$$ = geraCodigoExpreDeclaraFuncao($3, $1);
			}
			| E
			{
				$$ = geraCodigoExpreDeclaraFuncao($1, structVazia());
			}
			;

AUX_F_C		: TK_ID
			{
				verificaExistenciaFuncao($1.codigo, funcaoAtual);
				$$.codigo = $1.codigo;
			}
			;

DECLA_FUN	: AUX_FUN TK_ID AUX_PARAM TK_SETA AUX_TIPO_R '{' COMANDOS '}'
			{
				$$ = geraCodigoDeclaracaoFuncao($2.codigo, $7);
				retiraDoMap();
				retiraDoMapFuncoes();
			}
			| AUX_FUN TK_ID AUX_PARAM '{' COMANDOS '}'
			{
				$$ = geraCodigoDeclaracaoFuncao($2.codigo, $5);
				retiraDoMap();
				retiraDoMapFuncoes();
			}
			;

AUX_FUN		: TK_DEF
			{
				adicionaNoMapFuncoes();
				adicionaNoMap();
			}
			;

AUX_TIPO 	: TK_TIPO_BOOL
			{
				$$.tipo = "bool";
			}
			| TK_TIPO_DOUBLE
			{
				$$.tipo = "double";
			}
			| TK_TIPO_STR
			{
				$$.tipo = "str";
			}
			| TK_TIPO_FLOAT
			{
				$$.tipo = "float";
			}
			| TK_TIPO_INT
			{
				$$.tipo = "int";
			}
			;

AUX_TIPO_R 	: AUX_TIPO
			{
				FUN.tipoRetorno = $1.tipo;
				$$.tipo = $1.tipo;
			}
			| TK_TIPO_VOID
			{
				FUN.tipoRetorno = "void";
				$$.tipo = "void";
			}
			;

AUX_PARAM	: '(' PARAM_DECLA ',' PARAM ')'
			{
				$$.codigo = $2.codigo + $4.codigo;
			}
			| '(' PARAM_DECLA ')'
			{
				$$ = $2;
			}
			| '(' PARAM ')'
			{
				$$ = $2;
			}
			|
			{
				$$.codigo = "";
			}
			;

PARAM_DECLA	: PARAM_DECLA ',' AUX_TIPO TK_ID
			{
				setaCodigoParametros($3.tipo, $4, structVazia());
			}
			| AUX_TIPO TK_ID
			{
				setaCodigoParametros($1.tipo, $2, structVazia());
			}
			;

PARAM		: PARAM ',' AUX_TIPO TK_ID '=' E_FUN
			{
				setaCodigoParametros($3.tipo, $4, $6);
			}
			| AUX_TIPO TK_ID '=' E_FUN
			{
				setaCodigoParametros($1.tipo, $2, $4);
			}
			;

E_FUN		: TK_BOOL
			{
				$$ = $1;
			}
			| TK_INT
			{
				$$ = $1;
			}
			| TK_FLOAT
			{
				$$ = $1;
			}
			| TK_STR
			{
				$$ = $1;
			}
			;

RETURN		: TK_RETURN E
			{
				$$ = geraCodigoReturn($2);
			}
			;

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] ) {
	yyparse();

	return 0;
}

// Funcoes de utilidade ---------------------------------------------------------------------

	string criaInstanciaTabela(string variavel, string tipo, string tamanho) {
		unordered_map<string, caracteristicas> auxMap = FUN.pilhaMaps.back();
		unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = auxMap.find(variavel);

		if ( linhaDaVariavel == auxMap.end() ){
			caracteristicas novaVariavel;

			novaVariavel.temporaria = criaVariavelTemp();

			novaVariavel.tipo = tipo;

			if(tipo == "bool")
				FUN.mapDeclaracoes[novaVariavel.temporaria] = "\tint " + novaVariavel.temporaria + ";\n";
			else if (tipo == "str")
			{
				string tempTamanho = criaVariavelTemp();

				FUN.mapDeclaracoes[tempTamanho] = "\tint " + tempTamanho + "=" + tamanho + ";\n";
				geraCodigoDeclaracaoString(novaVariavel.temporaria, tamanho);

				novaVariavel.tamanho = tempTamanho;
			} else
				FUN.mapDeclaracoes[novaVariavel.temporaria] = "\t" + tipo + " " + novaVariavel.temporaria + ";\n";

			(FUN.pilhaMaps.back())[variavel] = novaVariavel;

			return novaVariavel.temporaria;
		}
		else {
			return (FUN.pilhaMaps.back())[variavel].temporaria;
		}
		return "";
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

	void inicializaFlagsDaPilhaDeBloco(void) {
		string flagInicio, flagFim, flagContadorFor;

		criaFlagLoop(flagInicio, flagFim, flagContadorFor);

		FUN.pilhaFlagsBlocos[FUN.mapAtual].flagInicio = flagInicio;
		FUN.pilhaFlagsBlocos[FUN.mapAtual].flagFim = flagFim;
		FUN.pilhaFlagsBlocos[FUN.mapAtual].flagContadorFor = flagContadorFor;
	}

	string criaVariavelTemp(void) {
		string prefixoRetornar = "tmp";
		int sufixoRetornar = ProxVariavelTemp++;

		prefixoRetornar += to_string(sufixoRetornar);

		return prefixoRetornar;
	}

	string criaFlag(void) {
		string prefixoRetornar = "CONDI";
		int sufixoRetornar = proxLabel++;

		prefixoRetornar += to_string(sufixoRetornar);

		return prefixoRetornar;
	}



	string regraCoercao(string tipoUm, string tipoDois, string operador) {
		if(operador == "+" || operador == "-" || operador == "/" || operador == "*"
		|| operador == ">" || operador == "<" || operador == "<=" || operador == ">="
		|| operador == "*=" || operador == "/="	|| operador == "+=" || operador == "-="
		|| operador == "%=" || operador == "==" || operador == "!=" ) {
			if(tipoUm == "bool" || tipoDois == "bool") {
				yyerror(string("Operador dessa linha não aceita tipo booleano"));
			}
			else if(tipoUm == "double" || tipoDois == "double")	{
				return "double";
			}
			else if(tipoUm == "float" || tipoDois == "float") {
				return "float";
			}
			else if(tipoUm == "int" || tipoDois == "int") {
				return "int";
			}
			return "erro";
		} else if(operador == "=") {
			if(tipoUm == "bool" && tipoDois != "bool")	{
				yyerror("Não é aceito coerção automatica de " + tipoDois + " para " + tipoUm);
			}
			else if(tipoUm == "int" && tipoDois != "int" && tipoDois != "str") {
				yyerror("Não é aceito coerção automatica de " + tipoDois + " para " + tipoUm);
			}
			else if(tipoUm == "float" && tipoDois == "double") {
				yyerror("Não é aceito coerção automatica de " + tipoDois + " para " + tipoUm);
			}

			return tipoUm;
		} else if(operador == "or" || operador == "and" || operador == "not") {
			if(tipoUm != "bool" || tipoDois != "bool"){
				yyerror("operações logicas só podem ser feitas entre booleanos.");
			}
			
			return "bool";
		}
	}



	atributos geraAtributosParaId(atributos id) {
		
		atributos structRetorno;
		
		structRetorno.conteudo = verificaExistencia(id.codigo, FUN.mapAtual);
		string tipo = pegaTipo(id.codigo, FUN.mapAtual);
		structRetorno.tipo = tipo;
		structRetorno.codigo = "";
		if (tipo == "str") {
			string tamanho = pegaTamanho(id.codigo, FUN.mapAtual);
			structRetorno.tamanho = tamanho;
		} else {
			structRetorno.tamanho = "";
		}

		return structRetorno;
	}



	int calculaTamanhoMaximoString(int tamanhoString) {
		int escala = 4;
		int tamanhoEscala = 50;

		for(tamanhoEscala = 50; tamanhoEscala < tamanhoString; tamanhoEscala *= escala, escala *= escala);

		return tamanhoEscala;
	}



	void checaLoopsPossiveis(int quantosLoops) {

		int quantosLoopsPossiveis = 0;

		for(int i = FUN.mapAtual; i >= 0 ; i--) {
			if (FUN.pilhaFlagsBlocos[i].flagInicio != "" && FUN.pilhaFlagsBlocos[i].flagFim != "") {
				
				quantosLoopsPossiveis++;

			} else {
				break;
			}
		}

		if ( quantosLoops <= 0  || quantosLoops > quantosLoopsPossiveis) {
			yyerror("Não é possivel realizar essa operação nessa quantidade de loops");
		}
	}



	string verificaExistencia(string variavel, int mapBusca){
		if(mapBusca == 0) {
			unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (FUN.pilhaMaps[mapBusca]).find(variavel);

			if ( linhaDaVariavel == (FUN.pilhaMaps[mapBusca]).end() ){
				yyerror("Variavel \""+ variavel +"\" não declarada");
			} else {
				return (FUN.pilhaMaps[mapBusca])[variavel].temporaria;
			}
			yyerror("Erro na função de verificação do ID");
		} else {
			unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (FUN.pilhaMaps[mapBusca]).find(variavel);
			if( linhaDaVariavel == (FUN.pilhaMaps[mapBusca]).end() ){
				return verificaExistencia(variavel, mapBusca - 1);
			}
			else {
				return (FUN.pilhaMaps[mapBusca])[variavel].temporaria;
			}
			yyerror("Erro na função de verificação do ID");
		}
		yyerror("Erro na função de verificação do ID");
	}

	void adicionaTamanho(string variavel, int mapBusca, string tamanho) {

		if(mapBusca == 0) {
			unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (FUN.pilhaMaps[mapBusca]).find(variavel);

			if ( linhaDaVariavel == (FUN.pilhaMaps[mapBusca]).end() ){
				yyerror("Variavel \""+ variavel +"\" não declarada");
			} else {
				(FUN.pilhaMaps[mapBusca])[variavel].tamanho = tamanho;
			}
		} else {
			unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (FUN.pilhaMaps[mapBusca]).find(variavel);
			if ( linhaDaVariavel == (FUN.pilhaMaps[mapBusca]).end() ){
				adicionaTamanho(variavel, mapBusca - 1, tamanho);
			}
			else {
				(FUN.pilhaMaps[mapBusca])[variavel].tamanho = tamanho;
			}
		}
	}

	string pegaTamanho(string variavel, int mapBusca) {
		if(mapBusca == 0) {
			unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (FUN.pilhaMaps[mapBusca]).find(variavel);

			if ( linhaDaVariavel == (FUN.pilhaMaps[mapBusca]).end() ){
				yyerror("Variavel \""+ variavel +"\" não declarada");
			} else {
				return (FUN.pilhaMaps[mapBusca])[variavel].tamanho;
			}
			yyerror("Erro na função de verificação do ID");
		} else {
			unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (FUN.pilhaMaps[mapBusca]).find(variavel);

			if ( linhaDaVariavel == (FUN.pilhaMaps[mapBusca]).end() ){
				return pegaTamanho(variavel, mapBusca - 1);
			}
			else {
				return (FUN.pilhaMaps[mapBusca])[variavel].tamanho;
			}
			yyerror("Erro na função de verificação do ID");
		}
		yyerror("Erro na função de verificação do ID");
	}

	string pegaTipo(string variavel, int mapBusca) {
		if(mapBusca == 0) {
			unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (FUN.pilhaMaps[mapBusca]).find(variavel);

			if ( linhaDaVariavel == (FUN.pilhaMaps[mapBusca]).end() ){
				yyerror("Variavel \""+ variavel +"\" não declarada");
			} else {
				return (FUN.pilhaMaps[mapBusca])[variavel].tipo;
			}
			yyerror("Erro na função de verificação do ID");
		} else {
			unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = (FUN.pilhaMaps[mapBusca]).find(variavel);

			if ( linhaDaVariavel == (FUN.pilhaMaps[mapBusca]).end() ){
				return pegaTipo(variavel, mapBusca - 1);
			}
			else {
				return (FUN.pilhaMaps[mapBusca])[variavel].tipo;
			}
			yyerror("Erro na função de verificação do ID");
		}
		yyerror("Erro na função de verificação do ID");
	}



	bool isStructVazia(atributos structParaTeste) {
		if (
			structParaTeste.codigo == "" &&
			structParaTeste.tamanho == "" &&
			structParaTeste.conteudo == "" &&
			structParaTeste.tipo == ""
		)
			return true;

		return false;
	}

	atributos structVazia(void) {
		atributos retorno;
		
		retorno.codigo = "";
		retorno.tamanho = "";
		retorno.conteudo = "";
		retorno.tipo = "";

		return retorno;
	}



	void imprimeDeclaracoes(map<string, string, compare_map_tmp> mapDeclaracoes) {
		for (auto& declaracao : mapDeclaracoes)
		{
			cout << declaracao.second;
		}
		cout << "\n\n";
	}



	void adicionaNoMap(void) {
		unordered_map<string, caracteristicas> auxMapGlobal;

		FUN.pilhaMaps.push_back(auxMapGlobal);

		flagsBloco auxFlagMaps;
		FUN.pilhaFlagsBlocos.push_back(auxFlagMaps);

		FUN.mapAtual++;
	}

	void retiraDoMap(void) {
		FUN.pilhaMaps.pop_back();

		FUN.pilhaFlagsBlocos.pop_back();

		FUN.mapAtual--;
	}



	void atualizaTipoInformacoesSwitch(string tipo) {

		FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].tipo = tipo;
		if(tipo == "bool")
			FUN.mapDeclaracoes[FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].temporaria] = "\tint" + FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].temporaria + ";\n";
		else if(tipo == "string")
		{
			//TODO
		}
		else
			FUN.mapDeclaracoes[FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].temporaria] = "\t" + tipo + " " + FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].temporaria + ";\n";
	}

	void empilhaInformacoesSwitch(void) {
		informacoesSwitch infos;
		infos.temporaria = criaVariavelTemp();
		
		infos.flagFim = criaFlag();
		
		FUN.pilhaInformacoesSwitch.push_back(infos);

		FUN.informacoesSwitchAtual++;
	}

	void retiraInformacoesSwitch(void) {
		FUN.pilhaInformacoesSwitch.pop_back();
		
		FUN.informacoesSwitchAtual--;
	}



	void geraCodigoDeclaracaoString(string variavel, string tamanhoString) {
		
		string tamanhoDeclaracao = to_string(calculaTamanhoMaximoString( stoi(tamanhoString) ));

		FUN.mapDeclaracoes[variavel] = "\tchar* " + variavel + "=(char*)malloc(" + tamanhoDeclaracao + "*sizeof(char));\n";
	}

	void geraCodigoDeclaracaoStringOperacoes(atributos& structVariavelDeclarar , string variavelTamanho1, string variavelTamanho2) {

		string temporariaTamanho = criaVariavelTemp();

		FUN.mapDeclaracoes[temporariaTamanho] = "\tint " + temporariaTamanho + ";\n";
		FUN.mapDeclaracoes[structVariavelDeclarar.conteudo] = "\tchar* " + structVariavelDeclarar.conteudo + "=(char*)malloc(50*sizeof(char));\n";	

		structVariavelDeclarar.codigo += "\t" + temporariaTamanho + "=" + variavelTamanho1 + "+" + variavelTamanho2 + ";\n";
		structVariavelDeclarar.codigo += geraCodigoCalculaTamanhoMaximoString(temporariaTamanho, temporariaTamanho);

		structVariavelDeclarar.tamanho = temporariaTamanho;
	}



	string geraCodigoCalculaTamanhoMaximoString(string temporariaTamanho, string temporariaDestino) {
		string codigoRetorno;

		string temporariaEscala = criaVariavelTemp();
		string temporariaTamanhoEscala = criaVariavelTemp();
		string temporariaIf = criaVariavelTemp();
		string flagInicioLoop = criaFlag();
		string flagFimLoop = criaFlag();

		FUN.mapDeclaracoes[temporariaIf] = "\tint " + temporariaIf + ";\n";
		FUN.mapDeclaracoes[temporariaEscala] = "\tint " + temporariaEscala + ";\n";
		FUN.mapDeclaracoes[temporariaTamanhoEscala] = "\tint " + temporariaTamanhoEscala + ";\n";

		codigoRetorno += "\t" + temporariaEscala + "= 4;\n";
		codigoRetorno += "\t" + temporariaTamanhoEscala + "= 50;\n";

		codigoRetorno += flagInicioLoop + ":\n";

		codigoRetorno += "\t" + temporariaIf + "=" + temporariaTamanhoEscala + "<" + temporariaTamanho + ";\n";
		codigoRetorno += "\t" + temporariaIf + "=!" + temporariaIf + ";\n";

		codigoRetorno += "\tif(" + temporariaIf + ")\n\t  goto " + flagFimLoop + ";\n";

		codigoRetorno += "\t" + temporariaTamanhoEscala + "=" + temporariaTamanhoEscala + "*" + temporariaEscala + ";\n";
		codigoRetorno += "\t" + temporariaEscala + "=" + temporariaEscala + "*" + temporariaEscala + ";\n";
		codigoRetorno += "\tgoto " + flagInicioLoop + ";\n";

		codigoRetorno += flagFimLoop + ":\n";
		codigoRetorno += "\t" + temporariaDestino + "=" + temporariaTamanhoEscala + ";\n";

		return codigoRetorno;
	}



	atributos geraCodigoDefault(atributos bloco) {
		atributos structRetorno;

		structRetorno.conteudo = "";
		structRetorno.tipo = "";
		structRetorno.tamanho = "";
		
		structRetorno.codigo = bloco.codigo;

		return structRetorno;
	}


	void yyerror( string MSG ) {
		cout << "Erro na linha "<< numeroLinhas << ": " << MSG << endl;
		exit (0);
	}

// Geradores auxiliares ---------------------------------------------------------------------

	string geraCodigoErroExecucao(string msg, string codigoErro) {
		return "\tstd::cout <<\"" + msg + "\"<<std::endl;\n\texit("+ codigoErro + ");\n";
	}

	string geraCodigoCoercaoStringToInt(string variavelRecebeCoercao, string variavelParaCoercao, string tamanho) {
		
		string codigoCoercao = "// ------------Codigo de coercao string para inteiro------------\n";

		string temporarialCondicaoSinal = criaVariavelTemp();
		string temporarialComparacaoChar = criaVariavelTemp();
		string temporariaSinal = criaVariavelTemp();
		string temporariaPosicao = criaVariavelTemp();
		string temporariaIfComZero = criaVariavelTemp();
		string temporariaIfComNove = criaVariavelTemp();
		string temporariaCondicao = criaVariavelTemp();
		string temporariaIfInterno = criaVariavelTemp();
		string temporariaConta = criaVariavelTemp();
		
		

		FUN.mapDeclaracoes[temporarialCondicaoSinal] = "\tint " + temporarialCondicaoSinal + ";\n";
		FUN.mapDeclaracoes[temporarialComparacaoChar] = "\tchar " + temporarialComparacaoChar + ";\n";
		FUN.mapDeclaracoes[temporariaSinal] = "\tint " + temporariaSinal + ";\n";
		FUN.mapDeclaracoes[temporariaPosicao] = "\tint " + temporariaPosicao + ";\n";
		FUN.mapDeclaracoes[temporariaCondicao] = "\tint " + temporariaCondicao + ";\n";
		FUN.mapDeclaracoes[temporariaIfComZero] = "\tchar " + temporariaIfComZero + ";\n";
		FUN.mapDeclaracoes[temporariaIfComNove] = "\tchar " + temporariaIfComNove + ";\n"; 
		FUN.mapDeclaracoes[temporariaConta] = "\tint " + temporariaConta + ";\n";
		FUN.mapDeclaracoes[temporariaIfInterno] = "\tchar " + temporariaIfInterno + ";\n";

		string flagIfInterno = criaFlag();
		string flagCondiSinal = criaFlag();
		string flagCondiElseSinal = criaFlag();
		string flagInicio, flagFim, flagContadorFor;

		criaFlagLoop(flagInicio, flagFim, flagContadorFor);

		codigoCoercao += "\t" + variavelRecebeCoercao + "=0;\n";
		codigoCoercao += "\t" + temporariaPosicao + "=0;\n";
		codigoCoercao += "\t" + temporariaSinal + "=1;\n";

		codigoCoercao += "\t" + temporarialComparacaoChar + "=" + variavelParaCoercao + "[" + temporariaPosicao + "];\n";
		codigoCoercao += "\t" + temporarialCondicaoSinal + "=" + temporarialComparacaoChar + "==" + "'-'" + ";\n";
		codigoCoercao += "\t" + temporarialCondicaoSinal + "=!" + temporarialCondicaoSinal + ";\n";
		
		codigoCoercao += "\tif(" + temporarialCondicaoSinal + ") goto " + flagCondiSinal + ";\n";
		codigoCoercao += "\t" + temporariaSinal + "=-1;\n";
		codigoCoercao += "\t" + temporariaPosicao + "=" + temporariaPosicao + " + 1;\n";
		codigoCoercao += "\tgoto " + flagCondiElseSinal + ";\n";
		codigoCoercao += flagCondiSinal + ":\n";

		codigoCoercao += "\t" + temporarialComparacaoChar + "=" + variavelParaCoercao + "[" + temporariaPosicao + "];\n";
		codigoCoercao += "\t" + temporarialCondicaoSinal + "=" + temporarialComparacaoChar + "==" + "'+'" + ";\n";
		codigoCoercao += "\t" + temporarialCondicaoSinal + "=!" + temporarialCondicaoSinal + ";\n";

		codigoCoercao += "\tif(" + temporarialCondicaoSinal + ") goto " + flagCondiElseSinal + ";\n";
		codigoCoercao += "\t" + temporariaPosicao + "=" + temporariaPosicao + " + 1;\n";
		codigoCoercao += flagCondiElseSinal + ":\n";

		codigoCoercao += "\t" + temporariaCondicao + "=" + temporariaPosicao + ";\n";
		codigoCoercao += "\tgoto " + flagContadorFor + ";\n" + flagInicio + ":\n";
		codigoCoercao += "\t" + temporariaCondicao + "=" + temporariaCondicao + "+1;\n" + flagContadorFor + ":\n";

		codigoCoercao += "\t" + temporarialCondicaoSinal + "=" + temporariaCondicao + "<" + tamanho + ";\n";
		codigoCoercao += "\t" + temporarialCondicaoSinal + "=!" + temporarialCondicaoSinal + ";\n";
		codigoCoercao += "\tif(" + temporarialCondicaoSinal + ") goto " + flagFim + ";\n";

		codigoCoercao += "\t" + temporarialComparacaoChar + "=" + variavelParaCoercao + "[" + temporariaCondicao + "];\n";
		codigoCoercao += "\t" + temporariaIfComZero + "=" + temporarialComparacaoChar + ">='0';\n";
		codigoCoercao += "\t" + temporariaIfComNove + "=" + temporarialComparacaoChar + "<='9';\n";
		
		codigoCoercao += "\t" + temporariaIfInterno + "=" + temporariaIfComZero + " && " + temporariaIfComNove + ";\n";

		codigoCoercao += "\t" + temporariaIfInterno + "=!" + temporariaIfInterno + ";\n";
		codigoCoercao += "\tif(" + temporariaIfInterno + ") goto " + flagIfInterno + ";\n";

		codigoCoercao += "\t" + variavelRecebeCoercao + "=" + variavelRecebeCoercao + "* 10;\n";
		codigoCoercao += "\t" + temporariaConta + "=" + temporarialComparacaoChar + "- '0';\n";
		codigoCoercao += "\t" + variavelRecebeCoercao + "=" + variavelRecebeCoercao + "+" + temporariaConta + ";\n";

		
		codigoCoercao += "\tgoto " + flagInicio + ";\n";
		codigoCoercao += flagIfInterno + ":\n";
		codigoCoercao += geraCodigoErroExecucao("A string não pode ser convertida para inteiro");
		codigoCoercao += "\t" + flagFim + ":\n";

		codigoCoercao += "\t" + variavelRecebeCoercao + "=" + variavelRecebeCoercao + "*" + temporariaSinal + ";\n";

		codigoCoercao += "// ------------Fim Codigo de coercao string para inteiro------------\n";

		return codigoCoercao;
	}

	string geraCodigoCoercaoStringToFloat(string variavelRecebeCoercao, string variavelParaCoercao, string tamanho) {
		string temporariaValorInteiro = criaVariavelTemp();
		string temporariaExpoente = criaVariavelTemp();
		string temporariaPosicao = criaVariavelTemp();
		string temporariaPonto = criaVariavelTemp();
		string temporariaValorPosicao = criaVariavelTemp();
		string temporariaIfs = criaVariavelTemp();
		string temporariaIfComposto = criaVariavelTemp();
		string temporariaCoercao = criaVariavelTemp();
		string temporariaValorNumero = criaVariavelTemp();

		FUN.mapDeclaracoes[temporariaValorInteiro] = "\tfloat " + temporariaValorInteiro + ";\n";
		FUN.mapDeclaracoes[temporariaExpoente] = "\tfloat " + temporariaExpoente + ";\n";
		FUN.mapDeclaracoes[temporariaPosicao] = "\tint " + temporariaPosicao + ";\n";
		FUN.mapDeclaracoes[temporariaPonto] = "\tint " + temporariaPonto + ";\n";
		FUN.mapDeclaracoes[temporariaValorPosicao] = "\tchar " + temporariaValorPosicao + ";\n";
		FUN.mapDeclaracoes[temporariaIfs] = "\tint " + temporariaIfs + ";\n"; 
		FUN.mapDeclaracoes[temporariaIfComposto] = "\tint " + temporariaIfComposto + ";\n";
		FUN.mapDeclaracoes[temporariaCoercao] = "\tfloat " + temporariaCoercao + ";\n";
		FUN.mapDeclaracoes[temporariaValorNumero] = "\tint " + temporariaValorNumero + ";\n";

		string codigoRetorno = "// ------------Codigo de coercao string para float------------\n";

		codigoRetorno += "\t" + temporariaValorInteiro + "= 0.0f;\n";
		codigoRetorno += "\t" + temporariaExpoente + "= 0.0f;\n";
		codigoRetorno += "\t" + temporariaPosicao + "= 0;\n";
		codigoRetorno += "\t" + temporariaPonto + "= 0;\n";

		codigoRetorno += "\t" + temporariaValorPosicao + "=" + variavelParaCoercao + "[" + temporariaPosicao + "];\n";
		codigoRetorno += "\t" + temporariaIfs + "=" + temporariaValorPosicao + "== '-';\n";
		codigoRetorno += "\t" + temporariaIfs + "=!" + temporariaIfs + ";\n";
		
		string flag1 = criaFlag();
		codigoRetorno += "\tif(" + temporariaIfs + ")\n\t  goto " + flag1 + ";\n";

		codigoRetorno += "\t" + temporariaPosicao + "=" + temporariaPosicao + "+1;\n";
		codigoRetorno += "\t" + temporariaExpoente + "=-1.0f;\n";

		string flag2 = criaFlag();
		codigoRetorno += "\tgoto " + flag2 + ";\n" + flag1 + ":\n";

		codigoRetorno += "\t" + temporariaValorPosicao + "=" + variavelParaCoercao + "[" + temporariaPosicao + "];\n";
		codigoRetorno += "\t" + temporariaIfs + "=" + temporariaValorPosicao + "== '+';\n";
		codigoRetorno += "\t" + temporariaIfs + "=!" + temporariaIfs + ";\n";
		
		codigoRetorno += "\tif(" + temporariaIfs + ")\n\t  goto " + flag2 + ";\n";

		codigoRetorno += "\t" + temporariaPosicao + "=" + temporariaPosicao + "+1.0f;\n";
		codigoRetorno += "\t" + temporariaExpoente + "=1;\n";
		
		string flagInicio = criaFlag();
		string flagFim = criaFlag();
		string flagContador = criaFlag();
		string flagErro = criaFlag();

		codigoRetorno += flag2 + ":\n\tgoto " + flagContador + ";\n" + flagInicio + ":\n";
		codigoRetorno += "\t" + temporariaPosicao + "=" + temporariaPosicao + "+1;\n" + flagContador + ":\n";
		codigoRetorno += "\t" + temporariaIfs + "=" + temporariaPosicao + "<" + tamanho + ";\n";
		codigoRetorno += "\t" + temporariaIfs + "=!" + temporariaIfs + ";\n";
		codigoRetorno += "\tif(" + temporariaIfs + ")\n\t  goto " + flagFim + ";\n";

		codigoRetorno += "\t" + temporariaValorPosicao + "=" + variavelParaCoercao + "[" + temporariaPosicao + "];\n";
		codigoRetorno += "\t" + temporariaIfs + "=" + temporariaValorPosicao + "== '.';\n";
		codigoRetorno += "\t" + temporariaIfComposto + "=" + temporariaPonto + "==0;\n";

		codigoRetorno += "\t" + temporariaIfs + "=" + temporariaIfs + "&&" + temporariaIfComposto + ";\n";
		codigoRetorno += "\t" + temporariaIfs + "=!" + temporariaIfs + ";\n";
		
		string flag3 = criaFlag();

		codigoRetorno += "\tif(" + temporariaIfs + ")\n\t  goto " + flag3 + ";\n";
		codigoRetorno += "\t" + temporariaPonto + "=1;\n\tgoto " + flagInicio + ";\n" + flag3 + ":\n";

		codigoRetorno += "\t" + temporariaValorPosicao + "=" + variavelParaCoercao + "[" + temporariaPosicao + "];\n";
		codigoRetorno += "\t" + temporariaValorNumero + "=" + temporariaValorPosicao + "-'0';\n";
		codigoRetorno += "\t" + temporariaIfs + "=" + temporariaValorNumero + ">=0;\n";
		codigoRetorno += "\t" + temporariaIfComposto + "=" + temporariaValorNumero + "<=9;\n";

		codigoRetorno += "\t" + temporariaIfs + "=" + temporariaIfs + "&&" + temporariaIfComposto + ";\n";
		codigoRetorno += "\t" + temporariaIfs + "=!" + temporariaIfs + ";\n";
		codigoRetorno += "\tif(" + temporariaIfs + ")\n\t  goto " + flagErro + ";\n";
		codigoRetorno += "\t" + temporariaIfs + "=!" + temporariaPonto + ";\n";

		string flag4 = criaFlag();

		codigoRetorno += "\tif(" + temporariaIfs + ")\n\t  goto " + flag4 + ";\n";
		codigoRetorno += "\t" + temporariaExpoente + "=" + temporariaExpoente + "/10.0f;\n" + flag4 + ":\n";

		codigoRetorno += "\t" + temporariaValorInteiro + "=" + temporariaValorInteiro + "*10.0f;\n";
		codigoRetorno += "\t" + temporariaCoercao + "=(float)" + temporariaValorNumero + ";\n";
		codigoRetorno += "\t" + temporariaValorInteiro + "=" + temporariaValorInteiro + "+" + temporariaCoercao + ";\n\tgoto " + flagInicio + ";\n";
		codigoRetorno += flagErro + ":\n";
		codigoRetorno += geraCodigoErroExecucao("A string não pode ser convertida para float");
		codigoRetorno += flagFim + ":\n";
		codigoRetorno += "\t" + variavelRecebeCoercao + "=" + temporariaValorInteiro + "*" + temporariaExpoente + ";\n";

		codigoRetorno += "// ------------Fim Codigo de coercao string para float------------\n";

		return codigoRetorno;
	}

	//TODO VERIFICAR ISSO AQUI PRA AJUSTAR O TAMANHO DA STRING
	void geraCodigoCoercao(atributos& structRetorno, atributos& elementoUm, atributos& elementoDois, string operacao) {
		
		string tuplaCoercaoOrigem[3];
		string tuplaCoercaoDestino[2];

		if(operacao == "atribuicao" || operacao == "declaracao" || operacao == "declaracaoParametro" ||  operacao == "return")
			tuplaCoercaoDestino[0] = regraCoercao(elementoUm.tipo, elementoDois.tipo, "=");
		else if(operacao == "switch")
			tuplaCoercaoDestino[0] = regraCoercao(elementoUm.tipo, elementoDois.tipo, "==");
		else
			tuplaCoercaoDestino[0] = regraCoercao(elementoUm.tipo, elementoDois.tipo, operacao);
			
		string variavelRecebeCoercao = criaVariavelTemp();	
		string codigoCoercao;

		structRetorno.tipo = tuplaCoercaoDestino[0];

		if(structRetorno.conteudo != "")
			FUN.mapDeclaracoes[structRetorno.conteudo] = "\t" + tuplaCoercaoDestino[0] + " " + structRetorno.conteudo + ";\n";
		
		FUN.mapDeclaracoes[variavelRecebeCoercao] = "\t" + tuplaCoercaoDestino[0] + " " + variavelRecebeCoercao + ";\n";

		if(tuplaCoercaoDestino[0] == elementoUm.tipo) {
			tuplaCoercaoOrigem[0] = elementoDois.tipo;
			tuplaCoercaoOrigem[1] = elementoDois.conteudo;
			tuplaCoercaoOrigem[2] = elementoDois.tamanho;

			tuplaCoercaoDestino[1] = elementoUm.conteudo;
		} else {
			tuplaCoercaoOrigem[0] = elementoUm.tipo;
			tuplaCoercaoOrigem[1] = elementoUm.conteudo;
			tuplaCoercaoOrigem[2] = elementoUm.tamanho;

			tuplaCoercaoDestino[1] = elementoDois.conteudo;
		}
		
		if(tuplaCoercaoOrigem[0] == "str") {
			if(tuplaCoercaoDestino[0] == "int") {
				codigoCoercao = geraCodigoCoercaoStringToInt(variavelRecebeCoercao, tuplaCoercaoOrigem[1], tuplaCoercaoOrigem[2]);
			}
			else if(tuplaCoercaoDestino[0] == "float") {
				codigoCoercao = geraCodigoCoercaoStringToFloat(variavelRecebeCoercao, tuplaCoercaoOrigem[1], tuplaCoercaoOrigem[2]);
			}
		} else if(tuplaCoercaoDestino[0] == "bool") {
			codigoCoercao = "\t" + variavelRecebeCoercao + "=(int)" + tuplaCoercaoOrigem[1] + ";\n";
		} else {
			codigoCoercao = "\t" + variavelRecebeCoercao + "=(" + tuplaCoercaoDestino[0] + ")" + tuplaCoercaoOrigem[1] + ";\n";
		}

		if(operacao == "+" || operacao == "-" || operacao == "/" || operacao == "*"
		|| operacao == ">" || operacao == "<" || operacao == "<=" || operacao == ">="
		|| operacao == "==" || operacao == "!=") {
			structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + codigoCoercao + "\t" + structRetorno.conteudo + "=" + variavelRecebeCoercao + operacao + tuplaCoercaoDestino[1] + ";\n";
		} else if(operacao == "declaracao") {
			structRetorno.codigo = elementoDois.codigo + codigoCoercao + "\t" + criaInstanciaTabela(elementoUm.codigo, elementoUm.tipo) + "=" + variavelRecebeCoercao + ";\n";
		} else if(operacao == "declaracaoParametro"){
			string aux = criaInstanciaTabelaParametro(elementoUm.codigo, elementoUm.tipo);
			FUN.parametrosOpcionais.push_back(aux);
			structRetorno.codigo = elementoDois.codigo + codigoCoercao + "\t" + aux + "=" + variavelRecebeCoercao + ";\n";
		} else if(operacao == "atribuicao") {
			structRetorno.codigo = elementoDois.codigo + codigoCoercao + "\t" + tuplaCoercaoDestino[1] + "=" + variavelRecebeCoercao + ";\n";
		} else if(operacao == "*=" || operacao == "/=" || operacao == "+=" || operacao == "-=" || operacao == "%=") {
			structRetorno.codigo = elementoDois.codigo + codigoCoercao + "\t" + tuplaCoercaoDestino[1] + "=" + tuplaCoercaoDestino[1] + operacao[0] + variavelRecebeCoercao + ";\n";
		} else if(operacao == "switch") {
			structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + codigoCoercao + "\t" + structRetorno.conteudo + "=" + variavelRecebeCoercao + "==" + tuplaCoercaoDestino[1] + ";\n";
		} else if(operacao == "return") {
			structRetorno.codigo = elementoDois.codigo + codigoCoercao + "\treturn " + variavelRecebeCoercao + ";\n"; 
		}
		
	}

// Geradores de atribuicao ------------------------------------------------------------------

	atributos geraCodigoAtribuicao(atributos elementoUm, atributos elementoDois) {
		atributos structRetorno;

		string temporariaDaVariavel = verificaExistencia(elementoUm.codigo, FUN.mapAtual);
		string tipoTemporariaDaVariavel = pegaTipo(elementoUm.codigo, FUN.mapAtual);
		string tamanho = pegaTamanho(elementoUm.codigo, FUN.mapAtual);

		elementoUm.tipo = tipoTemporariaDaVariavel;
		elementoUm.conteudo = temporariaDaVariavel;
		elementoUm.tamanho = tamanho;

		structRetorno.conteudo = temporariaDaVariavel;
		structRetorno.tipo = "ope";

		if(elementoDois.tipo == tipoTemporariaDaVariavel)
		{
			if(tipoTemporariaDaVariavel == "str") {
				structRetorno = geraCodigoAtribuicaoString(elementoUm, elementoDois);
			} else {
				structRetorno.codigo = elementoDois.codigo + "\t" + temporariaDaVariavel + "=" + elementoDois.conteudo + ";\n";
			}
		}
		else
		{
			geraCodigoCoercao(structRetorno, elementoUm, elementoDois, "atribuicao");
		}

		return structRetorno;
	}

	atributos geraCodigoAtribuicaoString(atributos elementoDestido, atributos elementoOrigem) {
		atributos structRetorno;

		string flagIfTamanho = criaFlag();
		string temporariaIf = criaVariavelTemp();
		string temporariaTamanhoNaTabela = elementoDestido.tamanho;
		string temporariaTamanhoMaximo = criaVariavelTemp();

		FUN.mapDeclaracoes[temporariaIf] = "\tint " + temporariaIf + ";\n";
		FUN.mapDeclaracoes[temporariaTamanhoMaximo] = "\tint " + temporariaTamanhoMaximo + ";\n";

		structRetorno.codigo = elementoOrigem.codigo;
		structRetorno.codigo += geraCodigoCalculaTamanhoMaximoString(elementoDestido.tamanho, temporariaTamanhoMaximo);
		structRetorno.codigo += "\t" + temporariaIf + "=" + temporariaTamanhoMaximo + "<" + elementoOrigem.tamanho + ";\n";
		structRetorno.codigo += "\t" + temporariaIf + "=!" + temporariaIf + ";\n";
		
		structRetorno.codigo += "\tif(" + temporariaIf + ")\n\t  goto " + flagIfTamanho + ";\n";
		structRetorno.codigo += geraCodigoCalculaTamanhoMaximoString(elementoOrigem.tamanho, temporariaTamanhoMaximo);
		structRetorno.codigo +=  "\t" + elementoDestido.conteudo + "=(char*)realloc(" + elementoDestido.conteudo + ", sizeof(char)*" + temporariaTamanhoMaximo + ");\n";
		structRetorno.codigo += flagIfTamanho + ":\n";

		structRetorno.codigo += "\tstrcpy(" + elementoDestido.conteudo + "," + elementoOrigem.conteudo + ");\n";

		structRetorno.tamanho = elementoOrigem.tamanho;
		adicionaTamanho(elementoDestido.codigo, FUN.mapAtual, elementoOrigem.tamanho);

		return structRetorno;
	}

	atributos geraCodigoAtribuicaoComposta(atributos elementoUm, atributos elementoDois, string operacao) {
		atributos structRetorno;

		string aux = verificaExistencia(elementoUm.codigo, FUN.mapAtual);
		string tipoAux = pegaTipo(elementoUm.codigo, FUN.mapAtual);

		structRetorno.conteudo = aux;
		structRetorno.tipo = "ope";

		elementoUm.conteudo = aux;

		if(elementoDois.tipo == tipoAux && tipoAux != "str")
		{
			structRetorno.codigo = elementoDois.codigo + "\t" + aux + "=" + aux + operacao[0] + elementoDois.conteudo + ";\n";
		}
		else
		{
			geraCodigoCoercao(structRetorno, elementoUm, elementoDois, operacao);
		}

		return structRetorno;
	}

// Geradores de declaracoes -----------------------------------------------------------------

	atributos geraCodigoDeclaComExp(atributos elementoUm, atributos elementoDois, string tipo) {
		atributos structRetorno;

		elementoUm.tipo = tipo;
		
		string aux;

		if (tipo == "str") {
			if(elementoUm.tipo == elementoDois.tipo)
			{			
				aux = criaInstanciaTabela(elementoUm.codigo, tipo);

				structRetorno.tipo = elementoUm.tipo;

				structRetorno.tamanho = criaVariavelTemp();
				FUN.mapDeclaracoes[structRetorno.tamanho] = "\tint " + structRetorno.tamanho + ";\n";

				structRetorno.codigo += elementoDois.codigo;
				structRetorno.codigo += geraCodigoCalculaTamanhoMaximoString(elementoDois.tamanho, structRetorno.tamanho);
				structRetorno.codigo += "\tstrcpy(" + aux + "," + elementoDois.conteudo + ");\n";
				adicionaTamanho(elementoUm.codigo, FUN.mapAtual, elementoDois.tamanho);
			}
			else
			{
				//TODO COERCAO PARA STRING
				yyerror("não existe coerção para string");
				// aux = criaInstanciaTabela(elementoUm.codigo, tipo, elementoDois.tamanho);
			}
		} else {
			if(elementoUm.tipo == elementoDois.tipo)
			{
				structRetorno.conteudo = criaInstanciaTabela(elementoUm.codigo, tipo);
				structRetorno.tipo = elementoUm.tipo;
				structRetorno.codigo = elementoDois.codigo + "\t" + structRetorno.conteudo + "=" + elementoDois.conteudo + ";\n";
			}
			else
			{
				structRetorno.conteudo = "";
				geraCodigoCoercao(structRetorno, elementoUm, elementoDois, "declaracao");
			}
		}

		return structRetorno;
	}

// Geradores de exprecoes -------------------------------------------------------------------

	atributos geraCodigoValores(atributos elemento) {
		atributos structRetorno;

		structRetorno.conteudo = criaVariavelTemp();
		structRetorno.tipo = elemento.tipo;
		if(structRetorno.tipo == "bool")
		{
			FUN.mapDeclaracoes[structRetorno.conteudo] = "\tint " + structRetorno.conteudo + ";\n";
			structRetorno.codigo = "\t" + structRetorno.conteudo + "=" + elemento.codigo + ";\n";
		} else if (structRetorno.tipo == "str") {
			geraCodigoDeclaracaoString(structRetorno.conteudo, elemento.tamanho);
			
			string temporariaTamanho = criaVariavelTemp();

			FUN.mapDeclaracoes[temporariaTamanho] = "\tint " + temporariaTamanho + ";\n";
			
			structRetorno.codigo += "\t" + temporariaTamanho + "=" + elemento.tamanho + ";\n";
			structRetorno.codigo += "\tstrcpy(" + structRetorno.conteudo + "," + elemento.codigo + ");\n";
			structRetorno.tamanho = temporariaTamanho;
		} else {
			FUN.mapDeclaracoes[structRetorno.conteudo] = "\t" + structRetorno.tipo + " " + structRetorno.conteudo + ";\n";
			structRetorno.codigo = "\t" + structRetorno.conteudo + "=" + elemento.codigo + ";\n";
		}

		return structRetorno;
	}


	atributos geraCodigoCoercaoExplicita(atributos elemento, string tipo) {
		atributos structRetorno;
		
		structRetorno.conteudo = criaVariavelTemp();
		structRetorno.tipo = tipo;

		if(tipo == "bool")
		{
			FUN.mapDeclaracoes[structRetorno.conteudo] = "\tint" + structRetorno.conteudo + ";\n";
			structRetorno.codigo = elemento.codigo + "\t" + structRetorno.conteudo + "=(int)" + elemento.conteudo + ";\n";
		}
		else
		{
			FUN.mapDeclaracoes[structRetorno.conteudo] = "\t" + tipo + " " + structRetorno.conteudo + ";\n";
			structRetorno.codigo = elemento.codigo + "\t" + structRetorno.conteudo + "=(" + structRetorno.tipo + ")" + elemento.conteudo + ";\n";
		}
		return structRetorno;
	}

	atributos geraCodigoOperacoes(atributos elementoUm, atributos elementoDois, string operacao) {
		atributos structRetorno;

		structRetorno.conteudo = criaVariavelTemp();

		if(elementoUm.tipo == "bool" || elementoDois.tipo == "bool")
			yyerror("operação \"" + operacao + "\" não permitida entre bools");

		if(elementoUm.tipo == elementoDois.tipo)
		{
			structRetorno.tipo = elementoUm.tipo;
			//TODO SOMA DE STR TÁ ERRADO
			//TODO MAIS OPERACOES COM STRING E REFATORAR ISSO !!!!
			if (structRetorno.tipo == "str" && operacao == "+") {
				
				structRetorno.codigo += elementoUm.codigo + elementoDois.codigo;

				geraCodigoDeclaracaoStringOperacoes(structRetorno, elementoUm.tamanho, elementoDois.tamanho);

				structRetorno.codigo += "\tstrcpy(" + structRetorno.conteudo + "," + elementoUm.conteudo + ");\n";
				structRetorno.codigo += "\tstrcat(" + structRetorno.conteudo + "," + elementoDois.conteudo + ");\n";
			} else {
				FUN.mapDeclaracoes[structRetorno.conteudo] = "\t" + structRetorno.tipo + " " + structRetorno.conteudo + ";\n";
				structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + operacao + elementoDois.conteudo + ";\n";
			}
		}
		else
		{
			geraCodigoCoercao(structRetorno, elementoUm, elementoDois, operacao);
		}

		return structRetorno;
	}


	atributos geraCodigoLogicoNot(atributos elemento, string operacao) {
		atributos structRetorno;

		structRetorno.tipo = regraCoercao(elemento.tipo, "bool", operacao);

		structRetorno.conteudo = criaVariavelTemp();

		FUN.mapDeclaracoes[structRetorno.conteudo] = "\tint " + structRetorno.conteudo + ";\n";

		structRetorno.codigo = elemento.codigo + "\t" + structRetorno.conteudo + "=!" + elemento.conteudo + ";\n";
		
		return structRetorno;
	}

	atributos geraCodigoLogico(atributos elementoUm, atributos elementoDois, string operacao) {
		atributos structRetorno;

		structRetorno.tipo = regraCoercao(elementoUm.tipo, elementoDois.tipo, operacao);
		
		structRetorno.conteudo = criaVariavelTemp();

		FUN.mapDeclaracoes[structRetorno.conteudo] = "\tint " + structRetorno.conteudo + ";\n";

		if(operacao =="or")
			structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + "||" + elementoDois.conteudo + ";\n";
		else
			structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + "&&" + elementoDois.conteudo + ";\n";
		
		return structRetorno;
	}

	atributos geraCodigoRelacional(atributos elementoUm, atributos elementoDois, string operacao) {
		atributos structRetorno;

		if(elementoUm.tipo == "bool" || elementoDois.tipo == "bool")
			yyerror(string("operação \"") + operacao + ("\" não permitida com o tipo bool"));

		structRetorno.conteudo = criaVariavelTemp();
		structRetorno.tipo = "bool";

		FUN.mapDeclaracoes[structRetorno.conteudo] = "\tint " + structRetorno.conteudo + ";\n";

		if(elementoUm.tipo == elementoDois.tipo)
		{
			if(elementoUm.tipo != "str") {
				structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=" + elementoUm.conteudo + operacao + elementoDois.conteudo + ";\n";
			} else if(operacao == "==") {
				structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=strcmp(" + elementoUm.conteudo + "," + elementoDois.conteudo + ");\n";
				structRetorno.codigo += "\t" + structRetorno.conteudo + "=" + structRetorno.conteudo + "==0;\n";
			} else if(operacao == "<") {
				structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=strcmp(" + elementoUm.conteudo + "," + elementoDois.conteudo + ");\n";
				structRetorno.codigo += "\t" + structRetorno.conteudo + "=" + structRetorno.conteudo + "<0;\n";
			} else if(operacao == ">") {
				structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=strcmp(" + elementoUm.conteudo + "," + elementoDois.conteudo + ");\n";
				structRetorno.codigo += "\t" + structRetorno.conteudo + "=" + structRetorno.conteudo + ">0;\n";
			} else if(operacao == ">=") {
				string temporariaAuxOperacao = criaVariavelTemp();
				FUN.mapDeclaracoes[temporariaAuxOperacao] = "\tint " + temporariaAuxOperacao + ";\n";

				structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=strcmp(" + elementoUm.conteudo + "," + elementoDois.conteudo + ");\n";
				structRetorno.codigo += "\t" + temporariaAuxOperacao + "=" + structRetorno.conteudo + ">0;\n";
				structRetorno.codigo += "\t" + structRetorno.conteudo + "=" + structRetorno.conteudo + "==0;\n";
				structRetorno.codigo += "\t" + structRetorno.conteudo + "=" + structRetorno.conteudo + "||" + temporariaAuxOperacao + ";\n";
			} else if(operacao == "<=") {
				string temporariaAuxOperacao = criaVariavelTemp();
				FUN.mapDeclaracoes[temporariaAuxOperacao] = "\tint " + temporariaAuxOperacao + ";\n";
				
				structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=strcmp(" + elementoUm.conteudo + "," + elementoDois.conteudo + ");\n";
				structRetorno.codigo += "\t" + temporariaAuxOperacao + "=" + structRetorno.conteudo + "<0;\n";
				structRetorno.codigo += "\t" + structRetorno.conteudo + "=" + structRetorno.conteudo + "==0;\n";
				structRetorno.codigo += "\t" + structRetorno.conteudo + "=" + structRetorno.conteudo + "||" + temporariaAuxOperacao + ";\n";
			} else if(operacao == "!="){
				structRetorno.codigo = elementoUm.codigo + elementoDois.codigo + "\t" + structRetorno.conteudo + "=strcmp(" + elementoUm.conteudo + "," + elementoDois.conteudo + ");\n";
				structRetorno.codigo += "\t" + structRetorno.conteudo + "=" + structRetorno.conteudo + "!=0;\n";
			}
		}
		else
		{
			geraCodigoCoercao(structRetorno,elementoUm,elementoDois,operacao);
		}

		return structRetorno;
	}


	atributos geraCodigoOperadorTamanho(atributos exprecao) {
		atributos structRetorno;

		structRetorno.tipo = "int";
		structRetorno.conteudo = criaVariavelTemp();

		if(exprecao.tipo == "str") {
			FUN.mapDeclaracoes[structRetorno.conteudo] = "\tint " + structRetorno.conteudo + ";\n";
			structRetorno.codigo = "\t" + structRetorno.conteudo + "=" + exprecao.tamanho + ";\n";
		} else {
			yyerror("operador len só existe para strings");
		}

		return structRetorno;
	}

// Geradores de Estruturas ------------------------------------------------------------------

	atributos geraCodigoIf(atributos exprecao, atributos bloco) {
		atributos structRetorno;
		
		structRetorno.tipo = "condicional";

		string auxCondicao = criaVariavelTemp();
		
		structRetorno.conteudo = auxCondicao;

		FUN.mapDeclaracoes[auxCondicao] = "\tint " + auxCondicao + ";\n";

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



	atributos geraCodigoOutput(atributos exprecoes) {
		atributos structRetorno;

		structRetorno.tipo = "output";
		structRetorno.conteudo = "";
		structRetorno.codigo = exprecoes.codigo + "\tstd::cout << " + exprecoes.conteudo + " << std::endl;\n";

		return structRetorno;
	}

	atributos geraCodigoParaMultiploOutput(atributos exprecao, atributos outraExprecoes) {
		atributos structRetorno;

		structRetorno.codigo = exprecao.codigo + outraExprecoes.codigo;
		structRetorno.conteudo = exprecao.conteudo + " << \" \" << " + outraExprecoes.conteudo;

		return structRetorno;
	}


	atributos geraCodigoInput(atributos variaveis) {
		atributos structRetorno;

		structRetorno.tipo = "input";
		structRetorno.conteudo = "";
		if( variaveis.tipo == "id") {
			if(pegaTipo(variaveis.codigo, FUN.mapAtual) == "str") {
				structRetorno.codigo = geraCodigoInputString(variaveis) + ";\n";
			} else {
				structRetorno.codigo = "\tstd::cin >> " + verificaExistencia(variaveis.codigo, FUN.mapAtual) + ";\n\tgetchar();\n";
			}
		} else {
			structRetorno.codigo = variaveis.codigo;
		}

		return structRetorno;
	}

	string geraCodigoInputString(atributos variavel) {

		string temporariaVariavel = verificaExistencia(variavel.codigo, FUN.mapAtual);
		string temporariaPegarChar = criaVariavelTemp();
		string temporariaTamanho = criaVariavelTemp();
		string temporariaInterador = criaVariavelTemp();
		string temporariaLocalString = criaVariavelTemp();
		string temporariaConta = criaVariavelTemp();
		string temporariaEscalaDois = criaVariavelTemp();
		string temporariaEscala = criaVariavelTemp();
		string temporariaIf = criaVariavelTemp();
		string temporariaTamanhoMaximo = criaVariavelTemp();
		string temporariaTamanhoNaTabela = pegaTamanho(variavel.codigo, FUN.mapAtual);

		FUN.mapDeclaracoes[temporariaEscalaDois] = "\tint " + temporariaEscalaDois + ";\n";
		FUN.mapDeclaracoes[temporariaIf] = "\tint " + temporariaIf + ";\n";
		FUN.mapDeclaracoes[temporariaConta] = "\tint " + temporariaConta + ";\n";
		FUN.mapDeclaracoes[temporariaTamanho] = "\tint " + temporariaTamanho + ";\n";
		FUN.mapDeclaracoes[temporariaEscala] = "\tint " + temporariaEscala + ";\n";
		FUN.mapDeclaracoes[temporariaInterador] = "\tint " + temporariaInterador + ";\n";
		FUN.mapDeclaracoes[temporariaLocalString] = "\tint " + temporariaLocalString + ";\n";
		FUN.mapDeclaracoes[temporariaPegarChar] = "\tchar " + temporariaPegarChar + ";\n";
		FUN.mapDeclaracoes[temporariaTamanhoMaximo] = "\tint " + temporariaTamanhoMaximo + ";\n";

		string codigoLeitura = "//---------------------Codigo de input string ----------------------------\n";

		codigoLeitura += "\t" + temporariaTamanho + "=0;\n";
		codigoLeitura += geraCodigoCalculaTamanhoMaximoString(temporariaTamanhoNaTabela, temporariaTamanhoMaximo);
		codigoLeitura += "\t" + temporariaEscala + "=" + temporariaTamanhoMaximo + ";\n";
		codigoLeitura += "\t" + temporariaEscalaDois + "= 4;\n";
		string flagLoop = criaFlag();
		codigoLeitura +=  flagLoop + ":\n";
		codigoLeitura += "\t" + temporariaPegarChar + "=getchar();\n";
		codigoLeitura += "\t" + temporariaTamanho + "++;\n";
		codigoLeitura += "\t" + temporariaVariavel + "[" + temporariaLocalString + "]=" + temporariaPegarChar + ";\n";

		codigoLeitura += "\t" + temporariaConta + "=" + temporariaEscala + "-1;\n";
		codigoLeitura += "\t" + temporariaIf + "=" + temporariaTamanho + ">=" + temporariaConta + ";\n";
		codigoLeitura += "\t" + temporariaIf + "=!" + temporariaIf + ";\n";

		string flagIf = criaFlag();
		codigoLeitura += "\tif(" + temporariaIf + ")\n\t goto " + flagIf + ";\n";
		codigoLeitura += "\t" + temporariaEscala + "=" + temporariaEscala + "*" + temporariaEscalaDois + ";\n";
		codigoLeitura += "\t" + temporariaEscalaDois + "=" + temporariaEscalaDois + "*" + temporariaEscalaDois + ";\n";
		codigoLeitura += "\t" + temporariaVariavel + "= (char*)realloc(" + temporariaVariavel + ", sizeof(char)*" + temporariaEscala + ");\n";
		codigoLeitura += flagIf + ":\n";

		codigoLeitura += "\t" + temporariaLocalString + "=" + temporariaLocalString + "+1;\n";
		codigoLeitura += "\t" + temporariaIf + "=" + temporariaPegarChar + " != '\\n';\n";
		codigoLeitura += "\tif(" + temporariaIf + ")\n\t goto " + flagLoop + ";\n";
		
		codigoLeitura += "\t" + temporariaLocalString + "=" + temporariaLocalString + "-1;\n";
		codigoLeitura += "\t" + temporariaVariavel + "[" + temporariaLocalString + "]= '\\0' ;\n";

		codigoLeitura += "\t" + temporariaTamanhoNaTabela + "=" + temporariaTamanho + ";\n";

		codigoLeitura += "//---------------------Codigo de input string ----------------------------\n";
		return codigoLeitura;
	}

	atributos geraCodigoParaMultiploInput(atributos id, atributos id2, atributos outrosIds) {
		atributos structRetorno;
		
		structRetorno.tipo = "";
		structRetorno.tamanho = "";
		structRetorno.conteudo = "";

		if(isStructVazia(id2)) {
			string tipoId = pegaTipo(id.codigo, FUN.mapAtual);

			if (tipoId == "str") {
				structRetorno.codigo = geraCodigoInputString(id) + outrosIds.codigo;
			} else {
				structRetorno.codigo = "\tstd::cin >> " +  verificaExistencia(id.codigo, FUN.mapAtual) + ";\n" + "\tgetchar();\n" + outrosIds.codigo;
			}
		} else {
			string tipoId = pegaTipo(id.codigo, FUN.mapAtual);
			string tipoId2 = pegaTipo(id2.codigo, FUN.mapAtual);

			if (tipoId == "str" && tipoId2 == "str") {
				structRetorno.codigo = geraCodigoInputString(id) + geraCodigoInputString(id2) + outrosIds.codigo;
			} else if(tipoId == "str") {
				structRetorno.codigo = geraCodigoInputString(id) + "\tstd::cin >> " + verificaExistencia(id2.codigo, FUN.mapAtual) + ";\n\tgetchar();\n" + outrosIds.codigo;
			} else if(tipoId2 == "str") {
				structRetorno.codigo = "\tstd::cin >> " + verificaExistencia(id.codigo, FUN.mapAtual) + ";\n\tgetchar();\n" + geraCodigoInputString(id2) + outrosIds.codigo;
			} else {
				structRetorno.codigo = "\tstd::cin >> " +  verificaExistencia(id.codigo, FUN.mapAtual) + ";\n\tgetchar();\n\tstd::cin >> " + verificaExistencia(id2.codigo, FUN.mapAtual) + ";\n\tgetchar();\n" + outrosIds.codigo;
			}
		}

		return structRetorno;
	}


	atributos geraCodigoWhile(atributos exprecao, atributos bloco) {
		atributos structRetorno;
		
		structRetorno.tipo = "loop";

		string auxCondicao = criaVariavelTemp();
		
		structRetorno.conteudo = auxCondicao;

		FUN.mapDeclaracoes[auxCondicao] = "\tint " + auxCondicao + ";\n";

		string flagInicio = FUN.pilhaFlagsBlocos[FUN.mapAtual].flagInicio;
		string flagFim = FUN.pilhaFlagsBlocos[FUN.mapAtual].flagFim;
		
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

		FUN.mapDeclaracoes[auxCondicao] = "\tint " + auxCondicao + ";\n";

		string flagInicio = FUN.pilhaFlagsBlocos[FUN.mapAtual].flagInicio;
		string flagFim = FUN.pilhaFlagsBlocos[FUN.mapAtual].flagFim;
		string flagContadorFor = FUN.pilhaFlagsBlocos[FUN.mapAtual].flagContadorFor;

		string tipo = regraCoercao("bool",exprecaoDois.tipo,"=");

		structRetorno.codigo = exprecaoUm.codigo + "\tgoto " + flagContadorFor + ";\n" + flagInicio + ":\n" + exprecaoTres.codigo + flagContadorFor + ":\n";

		structRetorno.codigo += exprecaoDois.codigo + "\t" + auxCondicao + "=" + exprecaoDois.conteudo + ";\n\t" + auxCondicao + "=!" + auxCondicao + ";\n"; 

		structRetorno.codigo += "\tif(" + auxCondicao + ")\n\t  goto " + flagFim + ";\n" + bloco.codigo +"\tgoto " + flagInicio + ";\n" + flagFim + ":\n"; 

		return structRetorno;
	}


	atributos geraCodigoBreak(string qualLoop) {
		atributos structRetorno;

		structRetorno.tipo = "";
		structRetorno.conteudo = "";
		
		if (qualLoop != "") {
			int quantosLoops = stoi(qualLoop);	
			
			checaLoopsPossiveis(quantosLoops);
			
			structRetorno.codigo = "\tgoto " + FUN.pilhaFlagsBlocos[FUN.mapAtual - quantosLoops + 1].flagFim + ";\n";
		} else {
			checaLoopsPossiveis(1);
			structRetorno.codigo = "\tgoto " + FUN.pilhaFlagsBlocos[FUN.mapAtual].flagFim + ";\n";
		}

		return structRetorno;
	}

	atributos geraCodigoContinue(string qualLoop) {
		atributos structRetorno;

		structRetorno.tipo = "";
		structRetorno.conteudo = "";
		
		if (qualLoop != "") {
			int quantosLoops = stoi(qualLoop);	
			
			checaLoopsPossiveis(quantosLoops);
			
			structRetorno.codigo = "\tgoto " + FUN.pilhaFlagsBlocos[FUN.mapAtual - quantosLoops + 1].flagInicio + ";\n";
		} else {
			checaLoopsPossiveis(1);
			structRetorno.codigo = "\tgoto " + FUN.pilhaFlagsBlocos[FUN.mapAtual].flagInicio + ";\n";
		}

		return structRetorno;
	}

	atributos geraCodigoCase(atributos exprecao, atributos bloco) {
		atributos structRetorno;
		
		string auxCondicao = criaVariavelTemp();
		
		structRetorno.tipo = "";
		structRetorno.tamanho = "";
		structRetorno.conteudo = auxCondicao;

		string tipoTempSwitch = FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].tipo;
		string temporariaSwitch = FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].temporaria;
		string tamanhoTemporariaSwitch = FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].tamanho;

		if(tipoTempSwitch == exprecao.tipo) {
			FUN.mapDeclaracoes[auxCondicao] = "\tint " + auxCondicao + ";\n";
			if(exprecao.tipo != "string")
				structRetorno.codigo = exprecao.codigo + "\t" + auxCondicao + "=" + exprecao.conteudo + "==" + temporariaSwitch + ";\n\t" + auxCondicao + "=!" + auxCondicao + ";\n";
			else
				structRetorno.codigo = exprecao.codigo + "\t" + auxCondicao + "= strcmp(" + exprecao.conteudo + "," + temporariaSwitch + ");\n";
		} else {
			atributos elementoAuxiliar;
			elementoAuxiliar.tipo = tipoTempSwitch;
			elementoAuxiliar.conteudo = temporariaSwitch;
			elementoAuxiliar.tamanho = tamanhoTemporariaSwitch;
			elementoAuxiliar.codigo = "";

			geraCodigoCoercao(structRetorno, exprecao, elementoAuxiliar, "switch");
		}
		
		string auxFlag = criaFlag();
		structRetorno.codigo += "\tif(" + auxCondicao + ")\n\t  goto " + auxFlag + ";\n";
		
		string flagFinalSwitch = FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].flagFim;
		structRetorno.codigo += bloco.codigo + "\tgoto " + flagFinalSwitch + ";\n" + auxFlag + ":\n";

		return structRetorno;
	}

	atributos geraCodigoSwitch(atributos exprecao, atributos cases, atributos defaul) {
		atributos structRetorno;

		structRetorno.tipo = "";
		structRetorno.tamanho = "";
		structRetorno.conteudo = "";

		string temporaria = FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].temporaria;

		structRetorno.codigo = exprecao.codigo + "\t" + temporaria + "=" + exprecao.conteudo + ";\n" + cases.codigo;

		if(defaul.codigo != "") {
			structRetorno.codigo += defaul.codigo;
		}

		structRetorno.codigo += FUN.pilhaInformacoesSwitch[FUN.informacoesSwitchAtual].flagFim + ":\n";

		return structRetorno;
	}

// Geradores Funcao --------------------------------------------------------------------------
	void adicionaNoMapFuncoes(void) {
		caracteristicasFuncao auxEmpilhar;
		
		pilhaFuncao.push_back(auxEmpilhar);
		funcaoAtual++;
	}

	void retiraDoMapFuncoes(void) {
		pilhaFuncao.pop_back();
		funcaoAtual--;
	}

	atributos geraCodigoExpreDeclaraFuncao(atributos exprecao, atributos outrasExprecoes) {
		vector<identificadorFuncao> auxIdentifica = auxChamadaFuncao.back();
		int auxQualPara = auxQualParametro.back();
		bool teveMatch = false;

		int quantidadeRemovidos = 0;
		int temporariaParaFimLoop = auxIdentifica.size();
		for(int i = 0; i < temporariaParaFimLoop; i++) {
			if(auxIdentifica[i].tipoParametros[auxQualPara] == exprecao.tipo) {
				if(!teveMatch) {
					auxQualParametro.back() += 1;
					teveMatch = true;
				}
			} else {
				(auxChamadaFuncao[auxChamadaFuncao.size()-1]).erase((auxChamadaFuncao[auxChamadaFuncao.size()-1]).begin() + i - quantidadeRemovidos);
				quantidadeRemovidos++;
			}
		}

		atributos structRetorno;

		if(teveMatch) {
			if(isStructVazia(outrasExprecoes)) {
				structRetorno.codigo += exprecao.codigo;
				structRetorno.conteudo += exprecao.conteudo;
			} else {
				structRetorno.codigo += outrasExprecoes.codigo + exprecao.codigo;
				structRetorno.conteudo += outrasExprecoes.conteudo + ',' + exprecao.conteudo;
			}
		} else {
			yyerror("Não foi possivel encontrar sobrecarga para a função.");
		}

		return structRetorno;
	}

	atributos geraCodigoChamadaFuncao(atributos id, atributos parametros) {
		identificadorFuncao auxIdentifica = (auxChamadaFuncao.back())[0];
		int auxQualParame = auxQualParametro.back();

		atributos structRetorno;

		if (auxQualParame > auxIdentifica.tipoParametros.size()) {
			yyerror("Foram colocados parametros demais na chamada da função \"" + id.codigo + "\"");
		} else {
			if(auxIdentifica.posicaoInicioOpcionais == -1) {
				if(auxQualParame < auxIdentifica.tipoParametros.size()) {
					yyerror("Faltam parametros na função \"" + id.codigo + "\"");
				}
			} else if(auxQualParame < auxIdentifica.posicaoInicioOpcionais) {
				yyerror("Faltam parametros na função \"" + id.codigo + "\"");
			}
		}

		structRetorno.conteudo = parametros.conteudo;
		structRetorno.codigo += parametros.codigo;

		int auxInicioValoresNIniciados = auxQualParame - auxIdentifica.posicaoInicioOpcionais;
		int auxFimLoop = auxIdentifica.tipoParametros.size();

		atributos valorAtual;

		for(int i = auxQualParame, j = 0; i < auxFimLoop; i++, j++) {
			string temporaria = criaVariavelTemp();
			if(auxIdentifica.tipoParametros[i] == "bool") {
				FUN.mapDeclaracoes[temporaria] = "\tint " + temporaria + ";\n";
				valorAtual = auxIdentifica.valoresParaParametros[auxInicioValoresNIniciados + j];
				structRetorno.codigo += "\t" + temporaria + "=" + valorAtual.codigo + ";\n";
			}
			else if (auxIdentifica.tipoParametros[i] == "str") {
				FUN.mapDeclaracoes[temporaria] = "\tchar* " + temporaria + ";\n";
				valorAtual = auxIdentifica.valoresParaParametros[auxInicioValoresNIniciados + j];
				structRetorno.codigo += "\tstrcpy(" + temporaria + "," + valorAtual.codigo + ");\n";
			}
			else {
				FUN.mapDeclaracoes[temporaria] = "\t" + auxIdentifica.tipoParametros[i] + " " + temporaria + ";\n";
				valorAtual = auxIdentifica.valoresParaParametros[auxInicioValoresNIniciados + j];
				structRetorno.codigo += "\t" + temporaria + "=" + valorAtual.codigo + ";\n";
			}

			structRetorno.conteudo += "," + temporaria;
		}

		structRetorno.conteudo = auxIdentifica.temporaria + "(" + structRetorno.conteudo + ")";
		structRetorno.tipo = auxIdentifica.tipoRetorno;

		return structRetorno;
	}

	atributos geraCodigoChamadaFuncaoComando(atributos id, atributos parametros) {
		
		atributos structRetorno;

		structRetorno = geraCodigoChamadaFuncao(id, parametros);

		structRetorno.codigo += "\t" + structRetorno.conteudo + ";\n";

		return structRetorno;
	}

	void verificaExistenciaFuncao(string id, int funcaoBusca) {
		if(pilhaFuncao[funcaoBusca].mapFuncoes.find(id) == pilhaFuncao[funcaoBusca].mapFuncoes.end()) {
			if(funcaoBusca == 0)
				yyerror("Função \"" + id + "\" não foi declarada nesse escopo.");
			else {
				verificaExistenciaFuncao(id, funcaoBusca - 1);
			}
				
		} else {
			vector<identificadorFuncao> temporariaIdentificador = pilhaFuncao[funcaoBusca].mapFuncoes[id];
			auxChamadaFuncao.push_back(temporariaIdentificador);
			auxQualParametro.push_back(0);
		}
	}

	atributos geraCodigoReturn(atributos exprecao) {
		atributos structRetorno;
		
		atributos elementoUm;
		
		elementoUm.tipo = FUN.tipoRetorno;

		if(elementoUm.tipo == exprecao.tipo)
			structRetorno.codigo = exprecao.codigo + "\treturn " + exprecao.conteudo + ";\n";
		else {
			geraCodigoCoercao(structRetorno, elementoUm, exprecao, "return");
		}

		FUN.semRetorno = false;

		return structRetorno;
	}

	void setaCodigoParametros(string tipo, atributos id, atributos valor) {
		if(isStructVazia(valor)) {
			FUN.parametros.push_back(criaInstanciaTabelaParametro(id.codigo, tipo));
			FUN.tipoParametros.push_back(tipo);
		} else {
			if(FUN.posicaoInicioOpcionais == -1) {
				FUN.posicaoInicioOpcionais = FUN.tipoParametros.size();
			}
			FUN.parametrosOpcionais.push_back(criaInstanciaTabelaParametro(id.codigo, tipo));
			FUN.valoresParaParametros.push_back(valor);
			FUN.tipoParametros.push_back(tipo);
		}
	}

	string criaInstanciaTabelaParametro(string variavel, string tipo, string tamanho) {
		unordered_map<string, caracteristicas> auxMap = FUN.pilhaMaps.back();
		unordered_map<string, caracteristicas>::const_iterator linhaDaVariavel = auxMap.find(variavel);

		if ( linhaDaVariavel == auxMap.end() ) {
			caracteristicas novaVariavel;

			novaVariavel.temporaria = criaVariavelTemp();
			novaVariavel.tipo = tipo;


			if (tipo == "str")
			{
				string tempTamanho = criaVariavelTemp();

				FUN.mapDeclaracoes[tempTamanho] = "\tint " + tempTamanho + "=" + tamanho + ";\n";
				novaVariavel.tamanho = tempTamanho;
			}

			(FUN.pilhaMaps.back())[variavel] = novaVariavel;

			return novaVariavel.temporaria;
		}
		else {
			return (FUN.pilhaMaps.back())[variavel].temporaria;
		}
		return "";
	}

	string adicionaDeclaracoesFuncao(void) {
		string retorno;
		if(! FUN.mapDeclaracoes.empty()) {
			for(auto& declaracao: FUN.mapDeclaracoes) {
				retorno += declaracao.second;
			}
			retorno += "\n";
		}
		return retorno;
	}

	atributos geraCodigoDeclaracaoFuncao(string id, atributos comandos) {
		string temporaria;

		if(pilhaFuncao[funcaoAtual - 1].mapFuncoes.find(id) == pilhaFuncao[funcaoAtual - 1].mapFuncoes.end()) {
			vector<identificadorFuncao> vectorFistIdentificador;
			pilhaFuncao[funcaoAtual - 1].mapFuncoes[id] = vectorFistIdentificador;

			identificadorFuncao fistIdentificador;
			temporaria = criaVariavelTemp();

			fistIdentificador.temporaria = temporaria;
			fistIdentificador.tipoParametros = FUN.tipoParametros;
			fistIdentificador.valoresParaParametros = FUN.valoresParaParametros;
			fistIdentificador.posicaoInicioOpcionais = FUN.posicaoInicioOpcionais;
			if(FUN.tipoRetorno == "")
				fistIdentificador.tipoRetorno = "void";
			else
				fistIdentificador.tipoRetorno = FUN.tipoRetorno;

			pilhaFuncao[funcaoAtual - 1].mapFuncoes[id].push_back(fistIdentificador);			
		} else {
			for (auto funcao : pilhaFuncao[funcaoAtual - 1].mapFuncoes[id]) {
				if(funcao.tipoParametros == FUN.tipoParametros) {
					yyerror("Assinatura de função já existe nesse escopo.");
				}
			}

			identificadorFuncao fistIdentificador;
			temporaria = criaVariavelTemp();

			fistIdentificador.temporaria = temporaria;
			fistIdentificador.tipoParametros = FUN.tipoParametros;
			fistIdentificador.valoresParaParametros = FUN.valoresParaParametros;
			fistIdentificador.posicaoInicioOpcionais = FUN.posicaoInicioOpcionais;
			if(FUN.tipoRetorno == "")
				fistIdentificador.tipoRetorno = "void";
			else
				fistIdentificador.tipoRetorno = FUN.tipoRetorno;

			pilhaFuncao[funcaoAtual - 1].mapFuncoes[id].push_back(fistIdentificador);
		}

		string codigo;

		if (FUN.tipoRetorno == "") {
			codigo += "void " + temporaria + "(";
		} else {
			if (FUN.semRetorno) {
				yyerror("a função \"" + id + "\" deve ter retorno de acordo com sua declaração.");
			}
			if (FUN.tipoRetorno == "bool") {
				codigo += "int " + temporaria + "(";
			} else if (FUN.tipoRetorno == "str") {
				codigo += "char* " + temporaria + "(";
			} else {
				codigo += FUN.tipoRetorno + " " + temporaria + "(";
			}
		}

		int local;
		int auxTamanho = FUN.tipoParametros.size();

		for (local = 0; local < auxTamanho - 1; local++) {
			if (FUN.posicaoInicioOpcionais == -1) {
				codigo += FUN.tipoParametros[local] + " " + FUN.parametros[local] + ",";
			} else {
				if (local < FUN.posicaoInicioOpcionais)
					codigo += FUN.tipoParametros[local] + " " + FUN.parametros[local] + ",";
				else
					codigo += FUN.tipoParametros[local] + " " + FUN.parametrosOpcionais[local - FUN.posicaoInicioOpcionais] + ",";
			}
		}

		if (local < auxTamanho) {
			if (FUN.posicaoInicioOpcionais == -1)
				codigo += FUN.tipoParametros[local] + " " + FUN.parametros[local] + ") {\n";
			else
				codigo += FUN.tipoParametros[local] + " " + FUN.parametrosOpcionais[local - FUN.posicaoInicioOpcionais] + ") {\n";
		} else {
			codigo += ") {\n";
		}

		codigo += adicionaDeclaracoesFuncao() + comandos.codigo + "}\n\n";

		declaracoesString += codigo;
		return structVazia();
	}
// ------------------------------------------------------------------------------------------
