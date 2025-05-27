#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// External lexer functions
extern int yylex(void);
extern char* yytext;
extern char* token_str;

// Token types (must match lexer)
enum {
    LTSL = 258, SLGT, OPEN, CLOSE, ASSIGN,
    STRING, NAME, DATA, EOF_TOK
};

int lookahead;

void advance() {
    lookahead = yylex();
}

void match(int token) {
    if (lookahead == token) {
        advance();
    } else {
        fprintf(stderr, "Syntax error: expected token %d, got token %d\n", token, lookahead);
        exit(1);
    }
}

// Grammar rules
void document();
void element();
void elementPrefix();
void attribute();
void elementSuffix();
void elementOrData();
void endTag();

void document() {
    element();
    if (lookahead != EOF_TOK) {
        fprintf(stderr, "Syntax error: expected EOF\n");
        exit(1);
    }
    printf("Valid XML Document\n");
}

void element() {
    match(OPEN);
    elementPrefix();
}

void elementPrefix() {
    if (lookahead == NAME) {
        match(NAME);
        attribute();
        elementSuffix();
    } else {
        fprintf(stderr, "Syntax error in elementPrefix\n");
        exit(1);
    }
}

void attribute() {
    if (lookahead == NAME) {
        match(NAME);
        match(ASSIGN);
        match(STRING);
        attribute(); // recurse
    }
    // else: ε (do nothing)
}

void elementSuffix() {
    if (lookahead == CLOSE) {
        match(CLOSE);
        elementOrData();
        endTag();
    } else if (lookahead == SLGT) {
        match(SLGT);
    } else {
        fprintf(stderr, "Syntax error in elementSuffix\n");
        exit(1);
    }
}

void elementOrData() {
    if (lookahead == OPEN) {
        element();
        elementOrData();
    } else if (lookahead == DATA) {
        match(DATA);
        elementOrData();
    }
    // else: ε
}

void endTag() {
    match(LTSL);
    match(NAME);
    match(CLOSE);
}

int main() {
    advance(); // initialize lookahead
    document();
    return 0;
}
