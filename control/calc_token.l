%{
#include "calc_token.tab.h"
%}


%option noinput nounput

%% 

E { yylval.str = yytext; return ESTADOS; }
A { yylval.str = yytext; return ALFABETO; }
EF { yylval.str = yytext; return FINAL; }
EI { yylval.str = yytext; return INICIAL; }
T { yylval.str = yytext; return TRANSICION; }
START { return EVALUAR; }
DESC { return DESC; }
q[0-9]+ { yylval.str = yytext; return ESTADO; }
[a-z] { yylval.str = yytext; return VALUE; }
[{}(),="] { return *yytext; }
\n { return ENDLINE; }
[ \t] { }
. { }

%%