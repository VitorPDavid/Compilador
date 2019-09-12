%{
  #include <string>

%}

ALPHANUM [0-1a-zA-Z]
ID [a-zA-Z_][0-1a-zA-Z_]*
DIG [0-9]
INT [1-9]{DIG}*|0
OCTAL 0[0-7]+
HEX 0x[0-9A-Fa-f]+
FLOAT (\-)?({DIG}\.{DIG}+|{INT}\.{DIG}+)
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

"int"            {return TK_TIPO_INT;}

[+\-*/=]         { return *yytext; }

{INT}            { yylval.codigo = yytext; return TK_INT; }
{ID}             { yylval.codigo = yytext; return TK_ID; }

[(){}[\];,]	     { return *yytext; }


.                { *yytext; }

%%
