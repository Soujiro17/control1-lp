%{
#include "calc_token.tab.h"
%}


%option noinput nounput

%% 

E { return ESTADOS; }
A { return ALFABETO; }
EF { return FINAL; }
EI { return INICIAL; }
& { return TRANSICION; }
[{}(),=] { return *yytext; }
q[0-9]+ { yylval.str = yytext; return ESTADO; }
\n { return ENDLINE; }
[ \t] { }
. { }

%%