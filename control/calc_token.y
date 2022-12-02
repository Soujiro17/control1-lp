%{
// #include <stdio.h>
// #include <string.h>
// #include <stdbool.h>
// #include <stdlib.h>

#include <iostream>
#include <vector>
#include <cstring>
#include <algorithm>

using namespace std;

#define MAX_ESTADOS 10

typedef struct Transition{
  struct Node *nodoInicio = NULL;
  struct Node *nodoFinal = NULL;
  string symbol;
} Transicion;

typedef struct Node{
        string name;
        bool isFinal = 0;
} State;

typedef struct DFA{
  vector <State> estados;
  vector <string> alfabeto;
  State *estado_inicial;
  vector <State> estados_finales;
  vector <Transicion> transiciones;
} Dfa;

int yylex();

void yyerror(const char *s){
  fprintf(stderr, "%s\n", s);
}

Dfa dfa;

bool evaluarCadena(char *cadena){

  int size = strlen(cadena);

  if (cadena[size - 1] == ')'){
    cadena[size - 1] = '\0';
  }

  string stringCadena(cadena);

  Transicion transicionActual;
  State *estadoInicial = dfa.estado_inicial;

  bool error = true;
  int count = 0;

  int largoCadena = stringCadena.length();

  printf("Estado inicial: %s\n", estadoInicial->name.c_str());

  char *token = strtok(cadena, ",");

  while( token != NULL ) {
    error = true;

    int size = strlen(token);

    if (token[size - 1] == '\n'){
      token[size - 1] = '\0';
    }

    string symbol(token);

    for(int i = 0; i<dfa.transiciones.size(); i++){

      if(count == 0){
        if(dfa.transiciones[i].symbol.compare(symbol) == 0 && dfa.transiciones[i].nodoInicio->name.compare(estadoInicial->name) == 0){
          transicionActual = dfa.transiciones[i];
          error = false;
          break;
        }
      }else{
        if(dfa.transiciones[i].symbol.compare(symbol) == 0){
          transicionActual = dfa.transiciones[i];
          error = false;
        }
      }
    }


    if(error == true){
      printf("\nCadena no en nodo final. Error");
      exit(0);
    }

    printf("Nodo de inicio: %s - Nodo destino: %s - Símbolo: %s\n",((transicionActual).nodoInicio)->name.c_str(), ((transicionActual).nodoFinal)->name.c_str(), (transicionActual).symbol.c_str());

    count++;

    if((largoCadena - ((largoCadena/2))) == count){
      if(((transicionActual).nodoFinal)->isFinal == 1){
        printf("Cadena reconocida!\n");
      }else{
        printf("\nCadena no reconocida. Error\n");
      }
    }

    token = strtok(NULL, ",");
  }

  return true;
}

void dfaResume(char *symbol){

  char sim = symbol[0];

  printf("symbol: %s", symbol);

  if(strcmp(symbol, "EF)") == 0){
    for(int i = 0; i<dfa.estados_finales.size(); i++){
      printf("Estado final: %s", dfa.estados_finales[i].name.c_str());
    }
  }else if(sim == 'E'){
    for(int i = 0; i<dfa.estados.size(); i++){
      printf("Estado: %s\n", dfa.estados[i].name.c_str());
    }
  }else if(sim == 'A'){
    for(int i = 0; i<dfa.alfabeto.size(); i++){
      printf("Letra alfabeto: %s\n", dfa.alfabeto[i].c_str());
    }
  }
}

%}

%union{
  int num;
  char * str;
}

%type<str> statement estados valores evaluar desc descV

%token<str> ESTADOS INICIAL FINAL ALFABETO DESC DESCV
%token<str> ESTADO VALUE EVALUAR
%token<str> TRANSICION
%token ENDLINE

%%

input: 
  | input linea
  ;

linea: ENDLINE 
  | statement ENDLINE
  | evaluar ENDLINE
  | desc ENDLINE
  ; 

statement: ESTADOS '=' estados {

      char *token = strtok($3, ",");

      dfa.estados.clear();

      while( token != NULL ) {

        int size = strlen(token);

        if (token[size - 1] == '\n'){
          token[size - 1] = '\0';
        }

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

        int size = strlen(token);

        if (token[size - 1] == '\n'){
          token[size - 1] = '\0';
        }

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

      State *nodoEncontrado1 = NULL;
      State *nodoEncontrado2 = NULL;

      for(int i = 0; i<dfa.estados.size(); i++){
        if(dfa.estados[i].name.compare(nodo1) == 0){
          nodoEncontrado1 = &dfa.estados[i];
        }else if (dfa.estados[i].name.compare(nodo2) == 0){
          nodoEncontrado2 = &dfa.estados[i];
        }
      }

      if(nodoEncontrado1 == NULL){
        printf("Nodo1 no encontrado: error.");
        exit(0);
      }

      if(nodoEncontrado2 == NULL){
        printf("Nodo2 no encontrado: error.");
        exit(0);
      }

      if(!count(dfa.alfabeto.begin(), dfa.alfabeto.end(), transicion)){
        printf("Letra no encontrada en alfabeto.");
        exit(0);
      }

      Transicion nuevaTransicion = {
        .nodoInicio = nodoEncontrado1,
        .nodoFinal = nodoEncontrado2,
        .symbol = transicion
      };

      dfa.transiciones.push_back(nuevaTransicion);

      nodoEncontrado1 = NULL;
      nodoEncontrado2 = NULL;
      nodos = "";
      transicion = "";
      nodo1 = "";
      nodo2 = "";

    }
  | ALFABETO '=' valores {
      char *token = strtok($3, ",");
      while( token != NULL ) {

        int size = strlen(token);

        if (token[size - 1] == '\n'){
          token[size - 1] = '\0';
        }

        string s(token);
        dfa.alfabeto.push_back(s);
        token = strtok(NULL, ",");
      }

      // dfaResume();
    }
  ;

estados: ESTADO | estados ',' estados;

valores: VALUE | valores ',' VALUE;

evaluar: EVALUAR '(' valores ')' { evaluarCadena($3); };

descV: ESTADOS
  | ALFABETO
  | FINAL
  | INICIAL
  | TRANSICION
  ;

desc: DESC '(' descV ')' { dfaResume($3); }

%%

int main(int argc, char **argv){

  // int tok;
  yyparse();

  // while(tok = yylex()){
  //   printf("%d\n", tok);
  // }
  return 0;
}
