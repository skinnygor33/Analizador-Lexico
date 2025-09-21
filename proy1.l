%%
/* --- CONSTRAINTS LEX/FLEX --- */

/* Delimitadores: ignorar espacios, tabuladores y saltos de línea */
[ \t\n]+        { /* No hacer nada, simplemente los consume */ }

/* =================================================================== */
/* Clase 0: Palabras Reservadas                                        */
/* IMPORTANTE: Deben ir antes de la regla de identificadores para que */
/* el analizador las reconozca específicamente.                      */
/* =================================================================== */
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

/* =================================================================== */
/* Clase 7: Operadores Relacionales                                    */
/* IMPORTANTE: Los operadores de dos caracteres (<=, ==, etc.) deben */
/* ir antes que los de un carácter (<, =) para que Flex aplique la     */
/* regla de la "coincidencia más larga".                               */
/* =================================================================== */
"<="            { imprimir_token(7, 2); }
">="            { imprimir_token(7, 3); }
"=="            { imprimir_token(7, 4); }
"!="            { imprimir_token(7, 5); }
"<"             { imprimir_token(7, 0); }
">"             { imprimir_token(7, 1); }

/* =================================================================== */
/* Clases 1 a 8: El resto de los tokens                                */
/* =================================================================== */

/* Clase 1: Identificadores */
\$[a-zA-Z]+     {
                    int pos = buscar_o_insertar_identificador(yytext);
                    imprimir_token(1, pos);
                }

/* Clase 2: Constantes Numéricas Enteras */
0|([1-9][0-9]*) {
                    int pos = buscar_o_insertar_literal_num(yytext);
                    imprimir_token(2, pos);
                }
[Oo][0-7]+      {
                    int pos = buscar_o_insertar_literal_num(yytext);
                    imprimir_token(2, pos);
                }

/* Clase 3: Constantes Numéricas Reales */
[0-9]*\.[0-9]+  {
                    int pos = buscar_o_insertar_literal_num(yytext);
                    imprimir_token(3, pos);
                }

/* Clase 4: Constantes Cadenas */
\"[^"']+\"|\'[^"']\'|\'\"\'|\"\'\" {
                    char* valor_limpio = strdup(yytext + 1);
                    valor_limpio[strlen(valor_limpio) - 1] = '\0';
                    int pos = buscar_o_insertar_literal_cad(valor_limpio);
                    imprimir_token(4, pos);
                    free(valor_limpio);
                }

/* Clase 5: Símbolos Especiales */
[\[\](){},:;]   { imprimir_token(5, yytext[0]); }

/* Clase 6: Operadores Aritméticos */
[+\*/%]         { imprimir_token(6, yytext[0]); }

/* Clase 8: Operador de Asignación */
"="             { imprimir_token(8, yytext[0]); }

/* Manejo de Errores Léxicos (cualquier otro caracter) */
.               { fprintf(stderr, "Error Léxico: Símbolo no reconocido '%s'\n", yytext); }

%%