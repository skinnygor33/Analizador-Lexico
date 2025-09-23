%{
    /**
    Alonso
    */
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>
   #define TAMANIO_TABLA 100
   extern FILE *yyout;
   extern FILE *yyin;
   FILE *apSal;

    // CORRECCIÓN 1: Definir structs ANTES de declararlas
    struct TablaSimbolos{
        int posicion;
        char *nombre_identificador;
        int tipo;
    };

    struct TablaLiterales {
        int posicion;
        char *dato;
    };

    // CORRECCIÓN 2: Declarar las tablas DESPUÉS de definir los structs
    struct TablaSimbolos tabla_simbolos[TAMANIO_TABLA];
    struct TablaLiterales tabla_literales_numericas[TAMANIO_TABLA];
    struct TablaLiterales tabla_literales_cadena[TAMANIO_TABLA];

    // Variables contadoras para cada tabla
    int pos_tabla_simbolos = 0;
    int pos_tabla_literales_numericas = 0;
    int pos_tabla_literales_cadenas = 0;

   int funcion_hash(char *clave, int tamanio_tabla){
        int valor_hash = 0;
        while(*clave != '\0'){
            valor_hash += *clave;
            clave++;
        }
        return valor_hash % tamanio_tabla; // CORRECCIÓN 3: era * en lugar de %
   }
   
   int buscar_o_insertar_identificador(char *ident){
        // CORRECCIÓN 4: Buscar primero, insertar después
        for(int i = 0; i < pos_tabla_simbolos; i++){
            if(strcmp(ident, tabla_simbolos[i].nombre_identificador) == 0){
                return tabla_simbolos[i].posicion;
            }
        }
        
        // Si no se encontró, insertar nuevo
        int posicion_actual = pos_tabla_simbolos;
        tabla_simbolos[posicion_actual].posicion = posicion_actual;
        tabla_simbolos[posicion_actual].nombre_identificador = strdup(ident);
        tabla_simbolos[posicion_actual].tipo = -1;
        pos_tabla_simbolos++;
        return posicion_actual;
   }
   
    int buscar_o_insertar_literal_num(char *numero) {
        for (int i = 0; i < pos_tabla_literales_numericas; i++) {
            if (strcmp(numero, tabla_literales_numericas[i].dato) == 0) {
                return tabla_literales_numericas[i].posicion;
            }
        }
        
        int posicion_actual = pos_tabla_literales_numericas;
        tabla_literales_numericas[posicion_actual].posicion = posicion_actual;
        tabla_literales_numericas[posicion_actual].dato = strdup(numero);
        pos_tabla_literales_numericas++;
        return posicion_actual;
    }
    
    // CORRECCIÓN 5: Cambiar nombre de función para que coincida
    int buscar_o_insertar_literal_cad(char *cadena) {
        for (int i = 0; i < pos_tabla_literales_cadenas; i++) {
            if (strcmp(cadena, tabla_literales_cadena[i].dato) == 0) {
                return tabla_literales_cadena[i].posicion;
            }
        }
        
        int posicion_actual = pos_tabla_literales_cadenas;
        tabla_literales_cadena[posicion_actual].posicion = posicion_actual;
        tabla_literales_cadena[posicion_actual].dato = strdup(cadena);
        pos_tabla_literales_cadenas++;
        return posicion_actual;
    }
    
    void imprimir_token(int clase, int pos) {
        printf("Token agregado: (%d, %d)\n", clase, pos);
        fprintf(apSal, "Token agregado: (%d, %d)\n", clase, pos);
        fflush(apSal);
    }

%}

%%

[ \t\n]+        { /* No hacer nada, simplemente los consume */ }


"alternative"   { imprimir_token(0, 0); }
"big"           { imprimir_token(0, 1); }
"evaluate"      { imprimir_token(0, 2); }
"instead"       { imprimir_token(0, 3); }
"large"         { imprimir_token(0, 4); }
"loop"          { imprimir_token(0, 5); }
"make"          { imprimir_token(0, 6); }
"number"        { imprimir_token(0, 7); }
"other"         { imprimir_token(0, 8); }
"real"          { imprimir_token(0, 9); }
"repeat"        { imprimir_token(0, 10); }
"select"        { imprimir_token(0, 11); }
"small"         { imprimir_token(0, 12); }
"step"          { imprimir_token(0, 13); }
"stop"          { imprimir_token(0, 14); }
"symbol"        { imprimir_token(0, 15); }
"throw"         { imprimir_token(0, 16); }


"<="            { imprimir_token(7, 2); }
">="            { imprimir_token(7, 3); }
"=="            { imprimir_token(7, 4); }
"!="            { imprimir_token(7, 5); }
"<"             { imprimir_token(7, 0); }
">"             { imprimir_token(7, 1); }


\$[a-zA-Z]+     {
                    int pos = buscar_o_insertar_identificador(yytext);
                    imprimir_token(1, pos);
                }


0|([1-9][0-9]*) {
                    int pos = buscar_o_insertar_literal_num(yytext);
                    imprimir_token(2, pos);
                }
[Oo][0-7]+      {
                    int pos = buscar_o_insertar_literal_num(yytext);
                    imprimir_token(2, pos);
                }

[0-9]*\.[0-9]+  {
                    int pos = buscar_o_insertar_literal_num(yytext);
                    imprimir_token(3, pos);
                }


\"[^"']+\"|\'[^"']\'|\'\"\'|\"\'\" {
                    char* valor_limpio = strdup(yytext + 1);
                    valor_limpio[strlen(valor_limpio) - 1] = '\0';
                    int pos = buscar_o_insertar_literal_cad(valor_limpio);
                    imprimir_token(4, pos);
                    free(valor_limpio);
                }


[\[\](){},:;]   { imprimir_token(5, yytext[0]); }


[+\*/%\-\^\\]   { imprimir_token(6, yytext[0]); }


"="             { imprimir_token(8, yytext[0]); }


.               { 
                    fprintf(stderr, "Error Léxico: Símbolo no reconocido '%s'\n", yytext);
                    fprintf(apSal, "Error Léxico: Símbolo no reconocido '%s'\n", yytext);
                }

%%
int yywrap(){
    return 1;
}

int main(int argc, char *argv[]){
    // CORRECCIÓN 6: Verificar argumentos PRIMERO
    if (argc != 2) {
        printf("Uso: %s <archivo_entrada>\n", argv[0]);
        printf("Ejemplo: %s archivo_entrada.txt\n", argv[0]);
        return 1;
    }
    
    // CORRECCIÓN 7: Abrir archivos ANTES de inicializar tablas
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'\n", argv[1]);
        return 1;
    }
    
    apSal = fopen("resultados.txt", "w");
    if (apSal == NULL) {
        printf("Error: No se pudo crear el archivo 'resultados.txt'\n");
        fclose(yyin);
        return 1;
    }
    
    printf("Analizando el archivo: %s\n", argv[1]);
    printf("Los resultados se guardarán en: resultados.txt\n\n");
    
    // CORRECCIÓN 8: Inicializar las tablas correctamente
    for (int i = 0; i < TAMANIO_TABLA; i++) {
        tabla_simbolos[i].nombre_identificador = NULL;
        tabla_literales_numericas[i].dato = NULL;
        tabla_literales_cadena[i].dato = NULL;
    }
    
    fprintf(apSal, "=== RESULTADOS DEL ANALISIS LEXICO ===\n\n");
    fflush(apSal);
    
    yyout = apSal;
    
    // CORRECCIÓN 9: Llamar yylex() UNA SOLA VEZ
    yylex();
    
    // Imprimir tablas finales
    printf("\n--- TABLA DE SIMBOLOS ---\n");
    fprintf(apSal, "\n--- TABLA DE SIMBOLOS ---\n");
    for (int i = 0; i < pos_tabla_simbolos; i++) {
        printf("Posicion: %d, Nombre: %s, Tipo: %d\n", 
               tabla_simbolos[i].posicion, 
               tabla_simbolos[i].nombre_identificador, 
               tabla_simbolos[i].tipo);
        fprintf(apSal, "Posicion: %d, Nombre: %s, Tipo: %d\n", 
               tabla_simbolos[i].posicion, 
               tabla_simbolos[i].nombre_identificador, 
               tabla_simbolos[i].tipo);
    }
    
    printf("\n--- TABLA DE LITERALES NUMERICOS ---\n");
    fprintf(apSal, "\n--- TABLA DE LITERALES NUMERICOS ---\n");
    for (int i = 0; i < pos_tabla_literales_numericas; i++) {
        printf("Posicion: %d, Dato: %s\n", 
               tabla_literales_numericas[i].posicion, 
               tabla_literales_numericas[i].dato);
        fprintf(apSal, "Posicion: %d, Dato: %s\n", 
               tabla_literales_numericas[i].posicion, 
               tabla_literales_numericas[i].dato);
    }
    
    printf("\n--- TABLA DE LITERALES CADENA ---\n");
    fprintf(apSal, "\n--- TABLA DE LITERALES CADENA ---\n");
    for (int i = 0; i < pos_tabla_literales_cadenas; i++) {
        printf("Posicion: %d, Dato: %s\n", 
               tabla_literales_cadena[i].posicion, 
               tabla_literales_cadena[i].dato);
        fprintf(apSal, "Posicion: %d, Dato: %s\n", 
               tabla_literales_cadena[i].posicion, 
               tabla_literales_cadena[i].dato);
    }
    
    fprintf(apSal, "\n=== FIN DEL ANALISIS ===\n");
    fflush(apSal);
    
    fclose(yyin);
    fclose(apSal);
    
    printf("Análisis completado. Revisa el archivo 'resultados.txt' para ver los resultados.\n");
    
    return 0;
}