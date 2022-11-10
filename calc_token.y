%{
#include <stdio.h>

int yylex();

void yyerror(const char *s){
  fprintf(stderr, "%s\n", s);
}
%}

%union{
  int num;
  char * str;
}

%type<str> statement estados

%token<str> NOMBRE INICIAL
%token<str> ESTADO
%token<str> TRANSICION

%%

statement: NOMBRE '=' estados
        | INICIAL '=' ESTADO { printf("STRING: %s\n", $3); }
        ;

estados: '{' ESTADO '}'
        | '{' ESTADO ',' estados '}' { }
        ;

%%

int main(int argc, char **argv){
  yyparse();
  return 0;
}
