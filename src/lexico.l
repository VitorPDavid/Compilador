%{
  #include <string>
  #include <iostream>
  char* bufferStr = (char*)malloc(sizeof(char)*50);
  int tamBuffer = 50;
  int auxEscala = 4;
  int tamAtual = 0;
%}

ALPHANUM [0-1a-zA-Z]
ID [a-zA-Z_][0-1a-zA-Z_]*
DIG [0-9]
INT [1-9]{DIG}*|0
OCTAL 0[0-7]+
HEX 0x[0-9A-Fa-f]+
FLOAT {DIG}\.{DIG}+|{INT}\.{DIG}+
EXP {FLOAT}E{INT}|{INT}E{INT}
BOOL "true"|"false"
LOGI "or"|"and"
OP_MA_P '*'|'/'|'%'
OP_M_P '+'|'-'
ATR "+="|"-="|"*="|"/="|"%="
REL ">"|"<"|"=="|"!="|"<="|">="
PARA "("|")"|"{"|"}"
DI ,|;
STRAS \"([^\\\"]|\\.)*\"
STRAP '([^\\']|\\.)*'
%%

"\n"             { numeroLinhas++; }
[ ]+             {}
[\t]+            {}

{STRAS}          { yylval.codigo = yytext; yylval.tipo = "str"; yylval.tamanho = to_string(yyleng - 2);return TK_STR;}

"int"            { yylval.codigo = yytext; yylval.tipo = "t_int"; return TK_TIPO_INT; }
"float"          { yylval.codigo = yytext; yylval.tipo = "t_float"; return TK_TIPO_FLOAT; }
"double"         { yylval.codigo = yytext; yylval.tipo = "t_double"; return TK_TIPO_DOUBLE; }
"bool"           { yylval.codigo = "int"; yylval.tipo = "t_bool"; return TK_TIPO_BOOL; }
"str"            { yylval.codigo = "char*"; yylval.tipo = "t_str"; return TK_TIPO_STR; }
".len"           { yylval.codigo = "len"; yylval.tipo = "ope_len"; return TK_OP_LEN; }

"input"          { return TK_INPUT; }
"output"         { return TK_OUTPUT; }

"switch"         { return TK_SWITCH; }
"case"           { return TK_CASE; }
"default"        { return TK_DEFAULT; }
"while"          { return TK_WHILE; }
"for"            { return TK_FOR; }
"continue"       { return TK_CONTINUE; }
"break"          { return TK_BREAK; }

"if"             { return TK_IF; }
"else"           { return TK_ELSE; }

{LOGI}           { yylval.codigo = yytext; yylval.tipo = "logico"; return TK_LOGI; }
"not"            { yylval.codigo = yytext; yylval.tipo = "logico"; return TK_NOT; }

[+\-*/=]         { return *yytext; }
{REL}            { yylval.codigo = yytext; yylval.tipo = "rel"; return TK_REL; }

{ATR}            { yylval.codigo = yytext; yylval.tipo = "atri"; return TK_ATR; }

{INT}            { yylval.codigo = yytext; yylval.tipo = "int"; return TK_INT; }
{FLOAT}          { yylval.codigo = yytext; yylval.tipo = "float"; return TK_FLOAT; }
{BOOL}           { yylval.codigo = yytext; yylval.tipo = "bool"; return TK_BOOL; }
{ID}             { yylval.conteudo = ""; yylval.codigo = yytext; yylval.tipo = "id"; return TK_ID; }

[(){}[\];,]	     { return *yytext; }


.                { *yytext; }

%%
