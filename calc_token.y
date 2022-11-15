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
        struct Node *zeroInput  = NULL;
        struct Node *oneInput = NULL;
} State;

typedef struct DFA{
  std::vector <State> estados;
  std::vector <string> alfabeto;
  State estado_inicial;
  std::vector <State> estados_finales;
} Dfa;

int yylex();

void yyerror(const char *s){
  fprintf(stderr, "%s\n", s);
}

Dfa dfa;

bool isValidNode(char nombreEstado[MAX_ESTADOS]){

  string s(nombreEstado);

  for(int i = 0; i<dfa.estados.size(); i++){
    if(dfa.estados[i].name.compare(s) == 0){
      return true;
    }
  }
  return false;
}

bool evaluarCadena(char cadena){
  printf("Se encuentra");
  printf("No se encuentra");
  return true;
}

void dfaResume(){
  printf("\nEstados:");
  for(int i = 0; i<dfa.estados.size(); i++){
    printf(" %s", dfa.estados[i].name.c_str());
  }
  cout << "Estado inicial: "<< dfa.estado_inicial.name.c_str() << "\n";
  printf("Estados finales: ");
  for(int i = 0; i<dfa.estados_finales.size(); i++){
    printf(" %s", dfa.estados_finales[i].name.c_str());
  }

  printf("Alfabeto: ");
  for(int i = 0; i<dfa.alfabeto.size(); i++){
    printf(" %s", dfa.alfabeto[i].c_str());
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
      if(isValidNode($3) == false){
        printf("Error al agregar el estado final: no se encuentra dentro de los estados definidos.");
        exit(1);
      }
      
      State node;
      node.name = $3;

      dfa.estado_inicial = node; 
    }
  | FINAL '=' estados {
      char *token = strtok($3, ",");
      while( token != NULL ) {

        if(isValidNode(token) == false){
          printf("Error al agregar el estado final: no se encuentra dentro de los estados definidos.");
          exit(1);
        }

        State node;
        node.name = token;
        dfa.estados_finales.push_back(node);
        token = strtok(NULL, ",");
      }

    }
  | TRANSICION '=' estados '=' VALUE {

      printf("%s %s", $3, $5);

      // string s($3);
      // s.replace(5, 2, "");
      // string s2($5);
      // printf("%s %s", s.c_str(), s2.c_str());

      // char *token = strtok(str, ",");
      // while( token != NULL ) {
      //   printf("%s", token);
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
