%{

#include <ctime>
#include <vector>
#include <string>
#include <cstdlib>
#include <iostream>
#include <algorithm>

using namespace std;

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

long filas = 3;
int columnas = 3;
int ciclo = 5;

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

    area()
    {
        infectados = 10000;
        suceptibles = 100000;
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

    void avance_enfermedad()
    {
        long expuestos_aux = expuestos ;
        long infectados_aux = infectados ;
        long recuperados_aux = recuperados ;
        long suceptibles_aux = suceptibles ;

        printf("E:%li,I:%li,S:%li,R:%li,TM:%li,PT:%li", expuestos, infectados, suceptibles, recuperados, total_muertos, total_poblacion);

        expuestos = expuestos_aux + tasa_cambio_expuesto(suceptibles_aux,expuestos_aux);
        infectados = infectados_aux + tasa_cambio_infectado(expuestos_aux,infectados_aux);
        recuperados = recuperados_aux + tasa_cambio_recuperados(infectados_aux,recuperados_aux);
        suceptibles = suceptibles_aux + tasa_cambio_suceptibles(recuperados_aux,suceptibles_aux);

        set_total_poblacion();
        
        total_muertos = total_poblacion_anterior - total_poblacion;
       
        set_total_poblacion_prev();
    }
};

void start(int infectados, int suceptibles, int expuestos, int recuperados){

  area *areas[20][20];

  for(int i = 0; i<filas; i++){
    for(int j = 0; j<columnas; j++){
      area nuevaArea(infectados, suceptibles,expuestos,recuperados);
      areas[i][j] = &nuevaArea;
    }
  }


  for(int cic = 0; cic<ciclo; cic++){
    printf("\n\nCiclo %i\n", cic);
    for(int i = 0; i<filas; i++){
      for(int j = 0; j<columnas; j++){
        (*areas[i][j]).avance_enfermedad();
        printf("    ||    ");
        (*areas[i][j]).set_total_poblacion();
      }
      printf("\n");
    }
  }

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
  yyparse();
  return 0;
}