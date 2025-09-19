%{
    /**
    Alonso
    */
   #include <stdio.h>
   extern FILE *yyout;
   FILE *apSal;
   Struct TablaCE[100]; //Estática o dinamica
   int i=0, llave;
   //Métodos de búsqueda
   int buscar(int nd, int llave){
        int k, res=1;
        for (k=0; k<=nd; k++){
            if(llave == Tabla CE [k])
            return 0; //de que si lo encontró
        }
        return 1; //no lo encontro
   }

%}
/*
Macarena 
*/
espacio [ ]
dig [0-9]
let [a-zA-Z_]
ident {let}({dig}|{let})*
%%
{ident}     {fprintf(apSal, "%s es un identificador\n", yytext);}
{espacio} {;}
.   {fprintf(apSal, "%s error no es un identificador\n");}

{cteEntDec}  {printf("Cte entera decimal %s\n", yytext);}
    llave = ato; (yytext);
    if(buscar(i,llave)){
        TablaCE[i]=llave;
        i++
    }
    }
{ident} {}
%%
int yywrap(){
    return 1;
}
int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    apSal = fopen("resultados.txt","w");
    yyout = apSal; //se redirige ña salida de flex al archivo
    yylex();
    fclose(apSal);
    return (0);
}
