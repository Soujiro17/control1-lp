%{
#include "calc_token.tab.h"
%}


%option noinput nounput

%% 

E { return ESTADOS; }
A { return ALFABETO; }
EF { return FINAL; }
EI { return INICIAL; }
T { return TRANSICION; }
START { return EVALUAR; }
q[0-9]+ { yylval.str = yytext; return ESTADO; }
[a-z] { yylval.str = yytext; return VALUE; }
[{}(),="] { return *yytext; }
\n { return ENDLINE; }
[ \t] { }
. { }

%%