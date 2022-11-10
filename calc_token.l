/* Libro pagina 13*/
%{
#include "calc_token.tab.h"

// extern int yylval;
// [{}(),=] { return *yytext; }


%}

%option noinput nounput

%% 

ESTADOS { return NOMBRE; }
ALFABETO { return NOMBRE; }
ESTADOS_FINALES { return NOMBRE; }
ESTADO_INICIAL { return INICIAL; }
& { return TRANSICION; }
[{}(),=] { return *yytext; }
q[0-9]+ { return ESTADO; }
\n { }
[ \t] { }
. { }

%%