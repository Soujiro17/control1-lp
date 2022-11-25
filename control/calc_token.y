%{
// #include <stdio.h>
// #include <string.h>
// #include <stdbool.h>
// #include <stdlib.h>

#include <iostream>
#include <vector>
#include <cstring>
using namespace std;

#define MAX_ESTADOS 10

typedef struct Node{
        string name;
        bool isFinal = 0;
        struct Node *nextNode = NULL;
        string symbol;
} State;

typedef struct DFA{
  vector <State> estados;
  vector <string> alfabeto;
  State *estado_inicial;
  vector <State> estados_finales;
} Dfa;

int yylex();

void yyerror(const char *s){
  fprintf(stderr, "%s\n", s);
}

Dfa dfa;

State getState(string stateName){
  State *nodoEncontrado;

  for(int i = 0; i<dfa.estados.size(); i++){
    if(dfa.estados[i].name.compare(stateName) == 0){
      nodoEncontrado = &dfa.estados[i];
    }
  }

  return &nodoEncontrado;
}

bool evaluarCadena(char cadena){
  printf("Se encuentra");
  printf("No se encuentra");
  return true;
}

void dfaResume(){
  printf("\nEstados:\n");
  for(int i = 0; i<dfa.estados.size(); i++){
    if(dfa.estados[i].isFinal == 1){
      printf("  - %s (final)\n", dfa.estados[i].name.c_str());
    }else{
      printf("  - %s\n", dfa.estados[i].name.c_str());
    }
  }
  printf("Estado inicial: %s", (*dfa.estado_inicial).name.c_str());

  printf("\nAlfabeto: ");
  for(int i = 0; i<dfa.alfabeto.size(); i++){
    printf("%s ", dfa.alfabeto[i].c_str());
  }
}

%}

%union{
  int num;
  char * str;
}

%type<str> statement estados valores cadena

%token<str> ESTADOS INICIAL FINAL ALFABETO
%token<str> ESTADO VALUE EVALUAR CADENA
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

      while( token != NULL ) {
        State nodo;
        nodo.name = token;
        dfa.estados.push_back(nodo);
        token = strtok(NULL, ",");
      }

    }
  | INICIAL '=' ESTADO {

      for(int i = 0; i<dfa.estados.size(); i++){
        if(strcmp(dfa.estados[i].name.c_str(), $3) == 0){
          dfa.estado_inicial = &dfa.estados[i];
          break;
        }
      }

    }
  | FINAL '=' estados {
      char *token = strtok($3, ",");
      while( token != NULL ) {

        for(int i=0; i<dfa.estados.size(); i++){
          if(strcmp(dfa.estados[i].name.c_str(), token) == 0){
            dfa.estados[i].isFinal = 1;
          }
        }

        token = strtok(NULL, ",");
      }

    }
  | TRANSICION '=' estados '=' VALUE {

      string nodos($3);
      string transicion($5);
      string nodo1 = nodos.substr(0, 2);
      string nodo2 = nodos.substr(3, 2);

      State nodoEncontrado = getState(nodo1);
      
      printf("%s - %s - %s", nodo1.c_str(), nodo2.c_str(), transicion.c_str());

      for(int i = 0; i<dfa.estados.size(); i++){
        if(dfa.estados[i].name.compare())
      }
      // char *token = strtok(nodos, ",");
      // while( token != NULL ) {
      //   // State nodo;
      //   // nodo.name = token;
      //   // dfa.estados.push_back(nodo);
      //   printf("%s", token);
      //   token = strtok(NULL, ",");
      // }
    }
  | ALFABETO '=' valores {
      char *token = strtok($3, ",");
      while( token != NULL ) {
        string s(token);
        dfa.alfabeto.push_back(s);
        token = strtok(NULL, ",");
      }

      dfaResume();
    }
  ;

estados: ESTADO
  | estados ',' estados
  ;

valores: VALUE | valores ',' valores;

cadena: valores | valores cadena

evaluar: EVALUAR '(' cadena ')' { evaluarCadena($3); };

%%

int main(int argc, char **argv){
  yyparse();
  return 0;
}
