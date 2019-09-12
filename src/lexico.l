%{
  #include <string>

%}

ALPHANUM [0-1a-zA-Z]
ID [a-zA-Z_][0-1a-zA-Z_]*
DIG [0-9]
INT [1-9]{DIG}*|0
OCTAL 0[0-7]+
HEX 0x[0-9A-Fa-f]+
FLOAT {DIG}\.{DIG}+|{INT}\.{DIG}+
EXP {FLOAT}E{INT}|{INT}E{INT}
BOOL True|False
OP '+'|'-'|'*'|'/'
ATR "+="|"-="|"*="|"/="|"="|"**="
PARA "("|")"|"{"|"}"
DI ,|;

%%
"\n"             {}

[ ]+             {}
[\t]+            {}

"main"           {return TK_MAIN;}

"int"            { yylval.codigo = yytext; return TK_TIPO_INT;}
"float"          { yylval.codigo = yytext; return TK_TIPO_FLOAT;}
"double"         { yylval.codigo = yytext; return TK_TIPO_DOUBLE;}
"bool"           { yylval.codigo = yytext; return TK_TIPO_BOOL;}

[+\-*/=]         { return *yytext; }

{INT}            { yylval.codigo = yytext; return TK_INT; }
{FLOAT}          { yylval.codigo = yytext; return TK_FLOAT; }
{ID}             { yylval.codigo = yytext; return TK_ID; }

[(){}[\];,]	     { return *yytext; }


.                { *yytext; }

%%
