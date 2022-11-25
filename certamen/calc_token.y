%{

#include <ctime>
#include <vector>
#include <string>
#include <cstdlib>
#include <iostream>
#include <algorithm>

using namespace std;

float t_mortalidad;
float t_morbilidad;
float t_transmision;
float t_recuperacion;
float t_reclutamiento;
float t_perdida_inmunidad;
float t_mortalidad_enfermedades;

float r;
float e;
float y;

class area
{
public:
    long ciclo;
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

    // Setter
    void set_total_poblacion()
    {
      total_poblacion = infectados + suceptibles + expuestos + recuperados;
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

    // calcular total poblacion
    // variacion datos
    void avance_enfermedad()
    {
        /*
        int expuestos_nuevos = suceptibles * t_transmision;
        int infectados_nuevos = expuestos * t_morbilidad;
        int recuperados_nuevos = infectados * t_recuperacion;
        int suceptibles_nuevos = (recuperados * t_perdida_inmunidad) + (t_reclutamiento * total_poblacion);

        int expuestos_muertos = expuestos * t_mortalidad;
        int infectados_muertos = (infectados * t_mortalidad) + (infectados * t_mortalidad_enfermedades);
        int recuperados_muertos = recuperados * t_mortalidad;
        int suceptibles_muertos = suceptibles * t_mortalidad;

        total_muertos = expuestos_muertos + infectados_muertos + recuperados_muertos + suceptibles_muertos + total_muertos;
        */
     
        long expuestos_aux = expuestos ;
        long infectados_aux = infectados ;
        long recuperados_aux = recuperados ;
        long suceptibles_aux = suceptibles ;
         cout << "Ciclo numero: " << ciclo << endl;
        cout << "expuestos: " << expuestos << endl;
        cout << "infectados: " << infectados << endl;
        cout << "suceptibles: " << suceptibles << endl;
        cout << "recuperados: " << recuperados << endl;
        cout << "total de muertos: " << total_muertos << endl;
        cout << "poblacion total: " << total_poblacion<<endl;
        cout << ":::::::::::::::::::::::::::::" << endl;
        expuestos = expuestos_aux + tasa_cambio_expuesto(suceptibles_aux,expuestos_aux);
        infectados = infectados_aux + tasa_cambio_infectado(expuestos_aux,infectados_aux);
        recuperados = recuperados_aux + tasa_cambio_recuperados(infectados_aux,recuperados_aux);
        suceptibles = suceptibles_aux + tasa_cambio_suceptibles(recuperados_aux,suceptibles_aux);
        cout << "tasa de suceptibles: " << tasa_cambio_suceptibles(recuperados,suceptibles_aux) << endl;
        cout << "tasa de expuestos: " << tasa_cambio_expuesto(suceptibles,expuestos_aux) << endl;
        cout << "tasa de infectados: " << tasa_cambio_infectado(expuestos,infectados_aux) << endl;
        cout << "tasa de recuperados: " << tasa_cambio_recuperados(infectados,recuperados_aux) << endl;
        cout << endl;
        set_total_poblacion();
        
        total_muertos = total_poblacion_anterior - total_poblacion;
       
        set_total_poblacion_prev();
    }
};


//determinar cantidad de gente que se va de la celula
// determinar que tipo de gente se va t_reclutamiento mover
// deteminar que cantidad de cada tipo se movera t_reclutamiento cada celula
void start(int infectados, int suceptibles, int expuestos, int recuperados){
  area manhattan(infectados, suceptibles, expuestos, recuperados);
  for (int i = 0; i < 10; i++)
  {
    manhattan.avance_enfermedad();
    manhattan.set_total_poblacion();
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

%token<str> TI TR TB TREC TPI TMCD TME START
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
    printf("DECIMAL: %f\n", $3); 
  }
  | TR '=' NUM { 
    printf("NUM: %i\n", $3); 
  }
  | TB '=' NUM { 
    printf("NUM: %i\n", $3); 
  }
  | TREC '=' DECIMAL { 
    if($3 < 0.0 || $3 > 1.0){
      printf("\nEl número debe estar entre 0 y 1\n");
      return 1;
    }
    printf("DECIMAL: %f\n", $3); 
  }
  | TPI '=' DECIMAL {
    if($3 < 0.0 || $3 > 1.0){
      printf("\nEl número debe estar entre 0 y 1\n");
      return 1;
    }
    printf("DECIMAL: %f\n", $3); 
  }
  | TMCD '=' DECIMAL {
    if($3 < 0.0 || $3 > 1.0){
      printf("\nEl número debe estar entre 0 y 1\n");
      return 1;
    }
    printf("DECIMAL: %f\n", $3); 
  }
  | TME '=' DECIMAL {
    if($3 < 0.0 || $3 > 1.0){
      printf("\nEl número debe estar entre 0 y 1\n");
      return 1;
    }
    printf("DECIMAL: %f\n", $3); 
  }
  ;

start: START '(' NUM ',' NUM ',' NUM ',' NUM ')' { start($3, $5, $7, $9); };

%%

int main(int argc, char **argv){
  yyparse();
  return 0;
}