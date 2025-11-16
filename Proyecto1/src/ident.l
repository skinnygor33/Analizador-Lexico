%{
    /*
    Integrantes:
    Martínez Araujo Jesús Alonso

    */
   #include <stdio.h>
   #include <stdlib.h>
   #include <string.h>
   #include "../inc/listaCircular.h" //para hacer uso de las funciones 
  
   ListaC * TS_inicio = NULL; //Inicio de la tabla de Símbolos
   ListaC * TLN_inicio = NULL; //Inicio de la tabla de Literales Numéricas
   ListaC * TLC_inicio = NULL; //Inicio de la tabla de Literales Cadenas
   ListaC * ListaT_inicio = NULL; //Lista para los TOKENS

   //Contadores para asignar la posición (valor del token)
   int pos_ts = 0;
   int pos_tln = 0;
   int pos_tlc = 0;
   int pos_token = 0; //contador para asignar posición del Token

   extern FILE *yyout;
   extern FILE *yyin;
   FILE *apSal;

void imprimir_token(int clase, int pos) {
        
    //insertar en la lista dinámica de Tokens
    InsertarToken(clase, pos); 
    printf("Token agregado: (%d, %d)\n", clase, pos);
    fprintf(apSal, "Token agregado: (%d, %d)\n", clase, pos);
    fflush(apSal); //se forza la escritura del búfer al archivo 
}
    //checar ya que se usa solo para la insercion de tokens
    // IMPLEMENTACIÓN DE LA FUNCIÓN DE INSERCIÓN DE TOKEN
void InsertarToken(int clase, int valor){
    ListaC *nuevo_token = CreadorDeNodos(valor, NULL, clase); 
    InsertarFinal(&ListaT_inicio, valor, NULL, clase);
}

// Función DINÁMICA para la Tabla de Símbolos
int buscar_o_insertar_identificador(char *ident){
    // 1. BUSCAR: Usar la función de búsqueda de la lista circular
    ListaC *nodo_encontrado = BuscarNodoPorDato(TS_inicio, ident);
    
    if(nodo_encontrado != NULL){
        // Encontrado: retorna su posición
        return nodo_encontrado->posicion;
    }
    
    //INSERTAR: Si no se encontró, insertar nuevo nodo
    int posicion_actual = pos_ts;
    // InsertarFinal(&inicio, pos, dato string, tipo -1)
    InsertarFinal(&TS_inicio, posicion_actual, ident, -1); 
    pos_ts++;
    
    return posicion_actual;
}

// Función DINÁMICA para Literales Numéricas
int buscar_o_insertar_literal_num(char *numero) {
    // 1. BUSCAR: El proyecto pide no insertar si ya existe (para Nums Reales)
    // Asumimos que esta regla aplica a todas las constantes numéricas.
    ListaC *nodo_encontrado = BuscarNodoPorDato(TLN_inicio, numero);
    
    if(nodo_encontrado != NULL){
        return nodo_encontrado->posicion;
    }

    //INSERTAR si no se encontro
    int posicion_actual = pos_tln;
    // InsertarFinal(&inicio, pos, dato string, tipo -1 (no se usa))
    InsertarFinal(&TLN_inicio, posicion_actual, numero, -1); 
    pos_tln++;
    
    return posicion_actual;
}

// Función DINÁMICA para Literales Cadena
int buscar_o_insertar_literal_cad(char *cadena) {
    // 1. BUSCAR: El proyecto pide no insertar si ya existe
    ListaC *nodo_encontrado = BuscarNodoPorDato(TLC_inicio, cadena);
    
    if(nodo_encontrado != NULL){
        return nodo_encontrado->posicion;
    }

    // 2. INSERTAR
    int posicion_actual = pos_tlc;
    // InsertarFinal(&inicio, pos, dato string, tipo -1 (no se usa))
    InsertarFinal(&TLC_inicio, posicion_actual, cadena, -1); 
    pos_tlc++;
    
    return posicion_actual;
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


\$[a-zA-Z_]+     {
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

[\[]    { imprimir_token(5, 0); }
[\]]     { imprimir_token(5, 1); }
[\(]     { imprimir_token(5, 2); }
[\)]     { imprimir_token(5, 3); }
[\{]     { imprimir_token(5, 4); }
[\}]     { imprimir_token(5, 5); }
[,]     { imprimir_token(5, 6); }
[:]     { imprimir_token(5, 7); }
[;]     { imprimir_token(5, 8); }

[+]     { imprimir_token(6, 0); }
[/]     { imprimir_token(6, 1); }
[*]     { imprimir_token(6, 2); }
[%]     { imprimir_token(6, 3); }
[-]     { imprimir_token(6, 4); }
[\^]     { imprimir_token(6, 5); }
[\\]     { imprimir_token(6, 6); }

"<="            { imprimir_token(7, 0); }
">="            { imprimir_token(7, 1); }
"=="            { imprimir_token(7, 2); }
"!="            { imprimir_token(7, 3); }
"<"             { imprimir_token(7, 4); }
">"             { imprimir_token(7, 5); }

"="     { imprimir_token(8, 0); }


.               { 
                    fprintf(stderr, "Error Léxico: Símbolo no reconocido '%s'\n", yytext);
                    fprintf(apSal, "Error Léxico: Símbolo no reconocido '%s'\n", yytext);
                }

%%
int yywrap() {
    return 1;
}

int main(int argc, char *argv[]){
    if (argc != 2) {
        printf("Uso: %s <archivo_entrada>\n", argv[0]);
        printf("Ejemplo: %s archivo_entrada.txt\n", argv[0]);
        return 1;
    }
    
    yyin = fopen(argv[1], "r"); //Entrada para flex para lectura
    if (yyin == NULL) {
        printf("Error: No se pudo abrir el archivo '%s'\n", argv[1]);
        return 1;
    }
    
    apSal = fopen("resultados.txt", "w"); //salida de los resultados para escritura
    if (apSal == NULL) {
        printf("Error: No se pudo crear el archivo 'resultados.txt'\n");
        fclose(yyin); //se cierra también flex
        return 1;
    }
    
    printf("Analizando el archivo: %s\n", argv[1]);
    printf("Los resultados se guardarán en: resultados.txt\n\n");
    
    fprintf(apSal, "=== RESULTADOS DEL ANALISIS LEXICO ===\n\n");
    fflush(apSal); //obliga a ponerlo en el archivo de resultados.txt
    
    yylex(); //solo una vez para evitar conflictos de sobreescritura
    
    // Imprimir tablas finales

    printf("\n--- TOKENS GENERADOS ---\n");
    fprintf(apSal, "\n--- TOKENS GENERADOS ---\n");
    imprimirTokens(ListaT_inicio, apSal);

    printf("\n--- TABLA DE SIMBOLOS ---\n");
    fprintf(apSal, "\n--- TABLA DE SIMBOLOS ---\n");
    imprimirLista(TS_inicio, apSal);
    
    printf("\n--- TABLA DE LITERALES NUMERICOS ---\n");
    fprintf(apSal, "\n--- TABLA DE LITERALES NUMERICOS ---\n");
    imprimirLista(TLN_inicio, apSal);
    
    printf("\n--- TABLA DE LITERALES CADENA ---\n");
    fprintf(apSal, "\n--- TABLA DE LITERALES CADENA ---\n");
    imprimirLista(TLC_inicio, apSal);
    
    fprintf(apSal, "\n=== FIN DEL ANALISIS ===\n");
    fflush(apSal);
    
    fclose(yyin);
    fclose(apSal);
    
    printf("Análisis completado. Revisa el archivo 'resultados.txt' para ver los resultados.\n");

    
    return 0;
}