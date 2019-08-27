%{
  #include <stdio.h>
  #include <stdlib.h>

  #define ESPACE 10
  #define BRAC 11
  #define TABULA 12
  #define F 100
  #define X 101
  #define B 102
  #define I 103
  #define E 104
  #define O 105
  #define H 106
  #define BOL 107
  #define ESTRUC 1000
  #define IDD 1001
  #define OPE 1002
  #define ATRI 1003
  #define TIPO 1004
  #define P 1005
  #define DIVI 1006
  #define STR 1007
%}


ALPHANUM [0-1a-zA-Z]
ID _?{ALPHANUM}+
DIG [0-9]
INT (\-)?[1-9]{DIG}*|0
OCTAL 0[0-7]+
HEX 0x[0-9A-Fa-f]+
FLOAT (\-)?({DIG}\.{DIG}+|{INT}\.{DIG}+)
EXP {FLOAT}E{INT}|{INT}E{INT}
BOOL True|False
OP "+"|"-"|"*"|"/"|"**"|"<="|">="|"=="|"<"|">"
ATR "+="|"-="|"*="|"/="|"="|"**="
PARA "("|")"|"{"|"}"
DI ,|;

%%
{BOOL}          { return BOL; }
{OCTAL}         { return O; }
{HEX}           { return H; }
{INT}           { return I; }
{FLOAT}         { return F; }
{EXP}           { return E; }
"while"|"for"|"if"|"else"|"elif"                { return ESTRUC; }
"fun"|"block"|"bar"|"in"|"print"                { return ESTRUC; }
"str"|"int"|"float"|"double"|"unint"|"bool"     { return TIPO; }
"and"|"or"|"not"                                { return OPE; }
{ATR}                                           { return ATRI; }
{OP}                                            { return OPE; }
{PARA}                                          { return P; }
{ID}            { return IDD; }
{DI}            { return DIVI; }
[ ]+            { return ESPACE; }
[\t]+           { return TABULA; }
[\n]            { return BRAC; }
.               { return B; }
<<EOF>>         { return X; }
%%
int main(int argc, char *argv[])
{
    FILE *f_in;
	int tipoToken;
    /*
    int totalDec = 0,
        totalOct = 0,
        totalHex = 0,
        totalFlt = 0,
        totalBool = 0,
        totalExp = 0;
    */
	if(argc == 2)
	{
		if(f_in == fopen(argv[1], "r"))
		{
			yyin = f_in;
		}
		else
		{
			perror(argv[0]);
		}
	}
	else
	{
		yyin = stdin;
	}

	while((tipoToken = yylex()) != X)
	{
		switch(tipoToken)
		{
			case F:
				printf(" float ");
				break;
            case I:
				printf(" decimal ");
				break;
            case E:
                printf(" expoente ");
                break;
            case BOL:
				printf(" bool ");
				break;
            case O:
				printf(" octadecimal ");
				break;
            case H:
                printf(" hexadecimal ");
                break;
            case ESTRUC:
                printf(" estrutura ");
                break;
            case ESPACE:
                printf(" espaço ");
                break;
            case BRAC:
                printf(" quebra_de_linha\n");
                break;
            case TIPO:
                printf(" TIPO ");
                break;
            case IDD:
                printf(" variavel ");
                break;
            case OPE:
                printf(" Operação ");
                break;
            case ATRI:
                printf(" Atribuição ");
                break;
            case P:
                printf(" parentese/chaves ");
                break;
            case DIVI:
                printf(" virgula/pont.Virgula ");
                break;
            case STR:
                printf(" uma string ");
                break;
            case TABULA:
                printf(" tabulação ");
                break;
        }
	}
    /*
	printf("Arquivo tem:\n");
    printf("\t %d valores exponenciais\n", totalExp);
    printf("\t %d valores boleanos\n", totalBool);
	printf("\t %d valores decimais\n", totalDec);
	printf("\t %d valores octais\n", totalOct);
	printf("\t %d valores hexadecimais\n", totalHex);
	printf("\t %d valores floats\n", totalFlt);
    */
}
