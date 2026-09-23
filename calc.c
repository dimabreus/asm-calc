#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LEXEME_PLUS 0
#define LEXEME_MINUS 1
#define LEXEME_STAR 2
#define LEXEME_SLASH 3
#define LEXEME_LEFT_BRACKET 4
#define LEXEME_RIGHT_BRACKET 5
#define LEXEME_NUMBER 6

typedef struct {
    int64_t *data;
    size_t size;
    size_t capacity;
} Vector;

void vecAppend(Vector *vector, int64_t value) {
    if (vector->size >= vector->capacity) {
        if (vector->capacity == 0) vector->capacity = 2;
        else vector->capacity *= 2;
        vector->data = realloc(vector->data, vector->capacity * sizeof(*vector->data));
    }
    vector->data[vector->size++] = value;
}

void vecPop(Vector *vector) {
    assert(vector->size > 0 && "Can't pop an empty vector");

    vector->data[--vector->size] = 0;
}

void printVector(Vector *vector) {
    printf("So this is my vector, size: %zu, cap: %zu\n", vector->size, vector->capacity);
    for (int i = 0; i < vector->size; i++) {
        printf("%d. %zu\n", i, vector->data[i]);
    }
}

Vector lexemes = {0};
int lexerCurrent = 0;

void lexerAddLexeme(int8_t type, int64_t literal) {
    int8_t *lexeme = malloc(1 + 8);

    lexeme[0] = (uint8_t)type;
    memcpy(lexeme + 1, &literal, sizeof(int64_t));

    vecAppend(&lexemes, (int64_t)lexeme);
}

void lexer(char *code) {
    while (1) {
        char c = code[lexerCurrent];

        if (c == '\0') {
            break;
        }

        if (c == ' ' || c == '\n') {
            lexerCurrent++;
            continue;
        }

        if (c == '+') lexerAddLexeme(LEXEME_PLUS, 0);
        else if (c == '-') lexerAddLexeme(LEXEME_MINUS, 0);
        else if (c == '*') lexerAddLexeme(LEXEME_STAR, 0);
        else if (c == '/') lexerAddLexeme(LEXEME_SLASH, 0);
        else if (c == '(') lexerAddLexeme(LEXEME_LEFT_BRACKET, 0);
        else if (c == ')') lexerAddLexeme(LEXEME_RIGHT_BRACKET, 0);
        else if (c >= '0' && c <= '9') {
            int64_t number = 0;

            while (c >= '0' && c <= '9') {
                number *= 10;
                number += c - 48;
                c = code[++lexerCurrent];
            }

            lexerAddLexeme(LEXEME_NUMBER, number);
            continue;
        } else {
            printf("Unknown char: %c\n", c);
        }

        lexerCurrent++;
    }
}

int main() {
    // char code[256];

    // printf("> ");
    // fgets(code, sizeof(code), stdin);

    char code[256] = "(24+3)*6-7";

    lexer(code);

    for (int i = 0; i < lexemes.size; i++) {
        int8_t *lexeme = (int8_t *)lexemes.data[i];
        int8_t type = *lexeme;
        int64_t literal;
        memcpy(&literal, lexeme + 1, sizeof(int64_t));

        printf(
            "type: %s, literal: %ld\n",
            type == LEXEME_PLUS            ? "PLUS         "
            : type == LEXEME_MINUS         ? "MINUS        "
            : type == LEXEME_STAR          ? "STAR         "
            : type == LEXEME_SLASH         ? "SLASH        "
            : type == LEXEME_LEFT_BRACKET  ? "LEFT_BRACKET "
            : type == LEXEME_RIGHT_BRACKET ? "RIGHT_BRACKET"
                                           : "NUMBER       ",
            literal);
    }
}