%{
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>

#define MAX_ESTADOS 10

int yylex();

void yyerror(const char *s){
  fprintf(stderr, "%s\n", s);
}

int contador_transiciones = 0;

struct DFA{
  char alfabeto[MAX_ESTADOS][MAX_ESTADOS];
  char estados[MAX_ESTADOS][MAX_ESTADOS];
  char estado_inicial[10];
  char estados_finales[MAX_ESTADOS][MAX_ESTADOS];
  char transiciones[MAX_ESTADOS][MAX_ESTADOS];
};

struct DFA dfa;

bool isOnArray(char value[MAX_ESTADOS], char array[MAX_ESTADOS][MAX_ESTADOS]){
  int i;
  for(i = 0; i<MAX_ESTADOS; i++){
    if(strcmp(array[i], value) == 0){
      return true;
    }
  }
  return false;
}

%}

%union{
  int num;
  char * str;
}

%type<str> statement estados valores

%token<str> ESTADOS INICIAL FINAL ALFABETO
%token<str> ESTADO VALUE
%token<str> TRANSICION
%token ENDLINE

%%

input: 
  | input linea
  ;

linea: ENDLINE 
  | statement ENDLINE
  ; 

statement: ESTADOS '=' estados {
      char *token = strtok($3, ",");
      int count = 0;
      while( token != NULL ) {
        strcpy(dfa.estados[count], token);
        count++;
        token = strtok(NULL, ",");
      }
    }
  | INICIAL '=' ESTADO {
      if(isOnArray($3, dfa.estados) == false){
        printf("Error al agregar el estado final: no se encuentra dentro de los estados definidos.");
        exit(1);
      }
      strcpy(dfa.estado_inicial, $3); 
    }
  | FINAL '=' estados {
      char *token = strtok($3, ",");
      int count = 0;
      while( token != NULL ) {

        if(isOnArray(token, dfa.estados) == false){
          printf("Error al agregar el estado final: no se encuentra dentro de los estados definidos.");
          exit(1);
        }

        strcpy(dfa.estados_finales[count], token);
        count++;
        token = strtok(NULL, ",");
      }
    }
  | TRANSICION '=' estados '=' VALUE { 
      strcpy(dfa.transiciones[contador_transiciones], $3);
    }
  | ALFABETO '=' valores { 
      char *token = strtok($3, ",");
      int count = 0;
      while( token != NULL ) {
        strcpy(dfa.alfabeto[count], token);
        count++;
        token = strtok(NULL, ",");
      }
    }
  ;

estados: ESTADO
  | estados ',' estados
  ;

valores: VALUE | valores ',' valores;

%%

int main(int argc, char **argv){
  yyparse();
  return 0;
}
