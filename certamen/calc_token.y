%{

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <cstdlib>
#include <ctime>
using namespace std;

// variables globales

// tasa de transmisiÃ³n
float B;
// tasa de reclutamiento
float A;
// tasa de morbilidad
float a1;
// tasa de recuperacion
float a2;
// tasa de perdida de inmunidad
float p;
// tasa de mortalidad por razones distintas a la enfermedad
float u;
// tasa de mortalidad inducida por la enfermedad
float g;

float r;
float e;
float y;



class ciudad
{
public:
    vector<int> foto;
    vector<vector<int>> calendario;

    long ciclo;
    long infectados;
    long suceptibles;
    long expuestos;
    long recuperados;
    long total_poblacion;
    long total_poblacion_anterior; 
    long total_muertos;

    ciudad(int inf, int suc, int exps, int recup)
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

    void set_total_poblacion_anterior(){
        total_poblacion_anterior = total_poblacion; 
    }

    // tasa de cambio de los suceptibles
    float tasa_cambio_suceptibles(float recuperados_aux,float suceptibles_aux)
    {
         //float tasa_cambio_S = (A*total_poblacion) - ((r * B*suceptibles*infectados)/total_poblacion) - (u*suceptibles);
        float tasa_cambio_S = A + (p * recuperados_aux) - (B * suceptibles_aux) - (u * suceptibles_aux);
        //cout << suceptibles_aux * u  <<endl;//+ (p * recuperados) - (B * suceptibles) - (u * suceptibles);
        return tasa_cambio_S;
    }

    float tasa_cambio_expuesto(float suceptibles_aux , float expuestos_aux)
    {
        
        //float tasa_cambio_E = ((r * B * suceptibles * infectados)/total_poblacion) - (e*expuestos);
        //cout << tasa_cambio_E <<endl;
        float tasa_cambio_E = (B * suceptibles_aux) - (a1 * expuestos_aux) - (u * expuestos_aux);
        
        return tasa_cambio_E;
    }

    float tasa_cambio_infectado(float expuestos_aux,float infectados_aux)
    {
        //float tasa_cambio_I = (e*expuestos) - (y*infectados) - (u *infectados);
        float tasa_cambio_I = (a1 * expuestos_aux) - (a2 * infectados_aux) - (u * infectados_aux) - (g * infectados_aux);
        return tasa_cambio_I;
    }

    float tasa_cambio_recuperados(float infectados_aux,float recuperados_aux)
    {
        //float tasa_cambio_R = (y*infectados) - (u * recuperados);
        float tasa_cambio_R = (a2 * infectados_aux) - (p * recuperados_aux) - (u * recuperados_aux);
        return tasa_cambio_R;
    }

    // calcular total poblacion

    // variacion datos
    void avance_enfermedad()
    {
        /*
        int expuestos_nuevos = suceptibles * B;
        int infectados_nuevos = expuestos * a1;
        int recuperados_nuevos = infectados * a2;
        int suceptibles_nuevos = (recuperados * p) + (A * total_poblacion);

        int expuestos_muertos = expuestos * u;
        int infectados_muertos = (infectados * u) + (infectados * g);
        int recuperados_muertos = recuperados * u;
        int suceptibles_muertos = suceptibles * u;

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
       
        set_total_poblacion_anterior();
    }
};


//determinar cantidad de gente que se va de la celula
// determinar que tipo de gente se va a mover
// deteminar que cantidad de cada tipo se movera a cada celula


// int main(int argc, char const *argv[])
// {
    
//     B = 0.2; // tasa de infeccion
//     A = 2000; //tasa de reclutamiento
//     a1 = 2; // tasa de morbilidad
//     a2 = 0.8; // tasa de recuperacion
//     p = 0.8; // tasa de perdidad de inmunidad
//     u = 0.00; // tasa de mortalidad por causas distintas
//     g = 0.03; // tasa de mortalidad por la enfermedad

//     /*
//     r = 100; // numero de contactos por unidad de tiempo
//     y = 0.9; // el ratio de recuperacion de la gente, va entre 0 y 1
//     e = 0.7; // el ratio de progresion al estado infeccioso per capita
//     */



//     ciudad manhattan(10000, 1000000, 0, 0); // infectados , suceptibles, expuestos, recuperados
//     for (int i = 0; i < 10; i++)
//     {
//         manhattan.avance_enfermedad();
         
//         manhattan.set_total_poblacion();
//     }

//     return 0;
// }

void start(int infectados, int suceptibles, int expuestos, int recuperados){
  ciudad manhattan(infectados, suceptibles, expuestos, recuperados);
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
