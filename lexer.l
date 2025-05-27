#include <string.h>
#include <stdio.h>

int in_tag_context = 0; 
char* token_str = NULL;

enum {
    LTSL = 258, SLGT, OPEN, CLOSE, ASSIGN,
    STRING, NAME, DATA, EOF_TOK
};

%}

%%

"</"            { in_tag_context = 1; printf("Token: LTSL\n"); return LTSL; }
"/>"            { in_tag_context = 0; printf("Token: SLGT\n"); return SLGT; }
"<"             { in_tag_context = 1; printf("Token: OPEN\n"); return OPEN; }
">"             { in_tag_context = 0; printf("Token: CLOSE\n"); return CLOSE; }
"="             { printf("Token: ASSIGN\n"); return ASSIGN; }

\"[^\"]*\"      {
                    token_str = strdup(yytext);
                    printf("Token: STRING (%s)\n", yytext);
                    return STRING;
                }

[a-zA-Z_][a-zA-Z0-9_]* {
    token_str = strdup(yytext);
    if (in_tag_context) {
        printf("Token: NAME (%s)\n", yytext);
        return NAME;
    } else {
        printf("Token: DATA (%s)\n", yytext);
        return DATA;
    }
}

[^<>\r\n\t =/"]+ {
    token_str = strdup(yytext);
    printf("Token: DATA (%s)\n", yytext);
    return DATA;
}

[ \t\r\n]+      ; // skip whitespace

<<EOF>> {
    static int done = 0;
    if (!done) {
        done = 1;
        printf("Token: EOF_TOK\n");
        return EOF_TOK;
    }
    return 0;
}

%%
