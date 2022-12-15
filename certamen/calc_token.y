%{

#include <ctime>
#include <vector>
#include <string>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <algorithm>
// #include <windows.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <time.h>


using namespace std;

char *colores[] = {
  "#fea0b7",
  "#fe00b7",
  "#78866B",
  "#592720",
  "#C41E3A",
  "#960018",
  "#ED9121",
  "#ACE1AF",
  "#DE3163",
  "#007BA7",
  "#F7E7CE",
  "#464646",
  "#7FFF00",
  "#FFB7C5",
  "#CD5C5C",
  "#7B3F00",
  "#E34234",
  "#D2691E",
  "#0047AB",
  "#B87333",
  "#FF7F50",
  "#FBEC5D",
  "#6495ED",
  "#FFFDD0",
  "#DC143C",
  "#00FFFF"
};

float t_mortalidad = 0.03;
float t_morbilidad = 2;
float t_transmision = 0.2;
float t_recuperacion = 0.8;
float t_reclutamiento = 0.3;
float t_perdida_inmunidad = 0.8;
float t_mortalidad_enfermedades = 0.03;

float r = 100;
float e = 0.7;
float y = 0.9;

int filas = 3;
int columnas = 3;
int ciclo = 5;

long int randNum(int lower, int upper){
    return (rand() % (upper - lower + 1)) + lower;
}

class area
{
public:
    long expuestos;
    long infectados;
    long recuperados;
    long suceptibles;
    vector<int> foto;
    long total_muertos;
    long total_poblacion;
    long total_poblacion_anterior;

    vector<vector<int>> calendario;

    area(int inf, int suc, int exps, int recup)
    {
        infectados = inf;
        suceptibles = suc;
        expuestos = exps;
        recuperados = recup;
        total_poblacion = infectados + suceptibles + expuestos + recuperados;
        total_poblacion_anterior = total_poblacion; 
        total_muertos = 0;
    }

    area(){
        infectados = 10000;
        suceptibles = 1000;
        expuestos = 0;
        recuperados = 0;
        total_poblacion = infectados + suceptibles + expuestos + recuperados;
        total_poblacion_anterior = total_poblacion; 
        total_muertos = 0;
    }

    // Setter
    void set_total_poblacion()
    {
      total_poblacion = infectados + suceptibles + expuestos + recuperados;
    }

    void set_infectados(int infectadosNuevo){
      infectados = infectadosNuevo;
    }

    void set_suceptibles(int suceptiblesNuevo){
      suceptibles = suceptiblesNuevo;
    }

    void set_expuestos(int expuestosNuevo){
      expuestos = expuestosNuevo;
    }

    void set_recuperados(int recuperadosNuevo){
      recuperados = recuperadosNuevo;
    }
    
    void set_total_poblacion_prev(){
      total_poblacion_anterior = total_poblacion; 
    }

    // tasa de cambio de los suceptibles
    float tasa_cambio_suceptibles(float recuperados_aux,float suceptibles_aux)
    {
      float tasa_cambio_S = t_reclutamiento + (t_perdida_inmunidad * recuperados_aux) - (t_transmision * suceptibles_aux) - (t_mortalidad * suceptibles_aux);
      return tasa_cambio_S;
    }

    float tasa_cambio_expuesto(float suceptibles_aux , float expuestos_aux)
    {
      float tasa_cambio_E = ((t_transmision * suceptibles_aux) - (t_morbilidad * expuestos_aux) - (t_mortalidad * expuestos_aux));        
      return tasa_cambio_E;
    }

    float tasa_cambio_infectado(float expuestos_aux,float infectados_aux)
    {
      float tasa_cambio_I = (t_morbilidad * expuestos_aux) - (t_recuperacion * infectados_aux) - (t_mortalidad * infectados_aux) - (t_mortalidad_enfermedades * infectados_aux);
      return tasa_cambio_I;
    }

    float tasa_cambio_recuperados(float infectados_aux,float recuperados_aux)
    {
      float tasa_cambio_R = (t_recuperacion * infectados_aux) - (t_perdida_inmunidad * recuperados_aux) - (t_mortalidad * recuperados_aux);
      return tasa_cambio_R;
    }

    int avance_enfermedad()
    {
      long expuestos_aux = expuestos;
      long infectados_aux = infectados;
      long recuperados_aux = recuperados;
      long suceptibles_aux = suceptibles;

      // printf("E:%li,I:%li,S:%li,R:%li,TM:%li,PT:%li\n", expuestos, infectados, suceptibles, recuperados, total_muertos, total_poblacion);

      expuestos = expuestos_aux + tasa_cambio_expuesto(suceptibles_aux,expuestos_aux);
      infectados = infectados_aux + tasa_cambio_infectado(expuestos_aux,infectados_aux);
      recuperados = recuperados_aux + tasa_cambio_recuperados(infectados_aux,recuperados_aux);
      suceptibles = suceptibles_aux + tasa_cambio_suceptibles(recuperados_aux,suceptibles_aux);

      set_total_poblacion();
      
      total_muertos = total_poblacion_anterior - total_poblacion;
      
      set_total_poblacion_prev();

      return infectados;
    }
};

void start(int infectados, int suceptibles, int expuestos, int recuperados){

  area areas[20][20];
  long int randomInf, randomSuc, randomExp, randomRec;
  FILE *data = NULL;
  int count = 0;
  // FILE *gnupipe = NULL;
  // char rects[150];
  // char plot[100];
  // int countVecindad = 1;
  // area *izquierda, *derecha, *arriba, *abajo;

  // sprintf(plot, "plot [0:%i] [0:%i] 'data.txt' using 1:2 with lines lw 8\n", filas, columnas);

  data = fopen("./graph/src/data.json", "w");
  // gnupipe = popen("gnuplot -persistent", "w");


  for(int i = 0; i<filas; i++){
    for(int j = 0; j<columnas; j++){
      randomInf = randNum(0, infectados);
      randomSuc = randNum(0, suceptibles);
      randomExp = randNum(0, expuestos);
      randomRec = randNum(0, recuperados);

      area nuevaArea(randomInf, randomSuc, randomExp, randomRec);

      areas[i][j] = nuevaArea;
    }
  }

  int segundos = 20;

  fprintf(data, "%s\n", "{");
  fprintf(data, "\"filas\": %i,\n\"columnas\": %i,\n\"segundos\": %i,\n", filas, columnas, segundos);
  fprintf(data, "%s\n", "\"data\": [");


  for(int s = 0; s<segundos; s++){
    fprintf(data, "%s\n", "[");
    count = 0;
    for(int i = 0; i<filas; i++){
      for(int j = 0; j<columnas; j++){
        areas[i][j].avance_enfermedad();
        if(j+1 == columnas && i+1 == filas){
          fprintf(data, "{ \"id\": %i, \"segundos\": %i, \"expuestos\": %li, \"infectados\": %li, \"suceptibles\": %li, \"recuperados\": %li, \"total_muertos\": %li, \"total_poblacion\": %li }\n", count, s, areas[i][j].expuestos < 0? 0 : areas[i][j].expuestos, areas[i][j].infectados < 0? 0 : areas[i][j].infectados, areas[i][j].suceptibles, areas[i][j].recuperados, areas[i][j].total_muertos, areas[i][j].total_poblacion);
        }else{
          fprintf(data, "{ \"id\": %i, \"segundos\": %i, \"expuestos\": %li, \"infectados\": %li, \"suceptibles\": %li, \"recuperados\": %li, \"total_muertos\": %li, \"total_poblacion\": %li },\n", count, s, areas[i][j].expuestos < 0? 0 : areas[i][j].expuestos, areas[i][j].infectados < 0? 0 : areas[i][j].infectados, areas[i][j].suceptibles, areas[i][j].recuperados, areas[i][j].total_muertos, areas[i][j].total_poblacion);
        }
        count++;
        areas[i][j].set_total_poblacion();
      }
    }

    if(s + 1 == segundos){
      fprintf(data, "%s\n", "]");
    }else{
      fprintf(data, "%s\n", "], ");
    }

    sleep(1);
    printf("Segundo %i\n", s);
  }
  printf("Fin ejecución\n");

  fprintf(data, "%s\n", "]");

  fprintf(data, "%s\n", "}");
  fclose(data);
  // for(int k = 0; k <  50; k += 1){

    // countVecindad = 0;
    // fprintf(data_TXT, "%i %i\n", k, k);
    // fflush(data_TXT);

    // for(int i = filas - 1; i>=0; i--){
    //   for(int j = 0; j<columnas; j++){
        
    //     infectadosObtenidos = areas[i][j].avance_enfermedad();

    //     // if(i+1 >= filas || j+1 >= columnas) continue;
    //     sprintf(rects, "set object %i rect from %i.00000, %i.00000 to %i.00000, %i.00000", countVecindad + 1, i, j, i+1, j+1);
    //     fprintf(gnupipe, "%s\n", rects);

    //     if(j != 0){
    //       if(areas[0][j+1].infectados < infectadosObtenidos){ // Derecha
    //         printf("Infectados obtenidos: %li - Infectados casilla arriba: %li\n", infectadosObtenidos, areas[i][j+1].infectados);
    //         sprintf(rects, "set object %i front clip lw 1.0  dashtype solid fc  rgb \"%s\"  fillstyle   solid 1.00 border lt -1", countVecindad+1, "#f00");
    //         fprintf(gnupipe, "%s\n", rects);
    //       }
    //     }


    //     areas[i][j].set_total_poblacion();

    //     countVecindad++;
    //   }
    //   countVecindad++;
    // }

    // fprintf(gnupipe, "%s\n", plot);
    // fflush(gnupipe);

    // sleep(1);
    // printf("Segundo %i\n", k);
    // fprintf(gnupipe, "%s\n", GnuCommands[i]);

  // fclose(data_TXT);

}

int yylex();

void yyerror(const char *s){
  fprintf(stderr, "%s\n", s);
}

%}

%union{
  int num;
  char * str;
  double dec;
}

%type<str> statement

%token<str> TI TR TB TREC TPI TMCD TME START DIAS GRILLA VALUE
%token<num> NUM 
%token<dec> DECIMAL
%token ENDLINE

%%

input: 
  | input linea
  ;

linea: ENDLINE 
  | statement ENDLINE
  | start ENDLINE
  ; 

statement: TI '=' DECIMAL { 
    if($3 < 0.0 || $3 > 1.0){
      printf("\nEl número debe estar entre 0 y 1\n");
      return 1;
    }
    t_transmision = $3;
    printf("Tasa de transmisión: %f\n", t_transmision); 
  }
  | TR '=' NUM {
    t_reclutamiento = $3;
    printf("Tasa de reclutamiento: %f\n", t_reclutamiento); 
  }
  | TB '=' NUM {
    t_morbilidad = $3;
    printf("Tasa de morbilidad: %f\n", t_morbilidad); 
  }
  | TREC '=' DECIMAL { 
    if($3 < 0.0 || $3 > 1.0){
      printf("\nEl número debe estar entre 0 y 1\n");
      return 1;
    }
    t_recuperacion = $3;
    printf("Tasa de recuperación: %f\n", t_recuperacion); 
  }
  | TPI '=' DECIMAL {
    if($3 < 0.0 || $3 > 1.0){
      printf("\nEl número debe estar entre 0 y 1\n");
      return 1;
    }
    t_perdida_inmunidad = $3;
    printf("Tasa de pérdida de inmunidad: %f\n", t_perdida_inmunidad); 
  }
  | TMCD '=' DECIMAL {
    if($3 < 0.0 || $3 > 1.0){
      printf("\nEl número debe estar entre 0 y 1\n");
      return 1;
    }
    t_mortalidad_enfermedades = $3;
    printf("Tasa de mortalidad por enfermedades: %f\n", t_mortalidad_enfermedades); 
  }
  | TME '=' DECIMAL {
    if($3 < 0.0 || $3 > 1.0){
      printf("\nEl número debe estar entre 0 y 1\n");
      return 1;
    }
    t_mortalidad = $3;
    printf("Tasa de mortalidad: %f\n", t_mortalidad); 
  }
  | DIAS '=' NUM {
    ciclo = $3;
    printf("Cantidad de ciclos: %i", $3);
  }
  | GRILLA '=' VALUE {
    filas = (int)$3[0] - 48;
    columnas = (int)$3[2] - 48;
  }
  ;

start: START '(' NUM ',' NUM ',' NUM ',' NUM ')' { start($3, $5, $7, $9); };

%%

int main(int argc, char **argv){
  srand(time(0));
  yyparse();
  return 0;
}