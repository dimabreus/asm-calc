#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TOKEN_PLUS 0
#define TOKEN_MINUS 1
#define TOKEN_STAR 2
#define TOKEN_SLASH 3
#define TOKEN_LEFT_BRACKET 4
#define TOKEN_RIGHT_BRACKET 5
#define TOKEN_NUMBER 6
#define TOKEN_EOF 7

#define NODE_LITERAL 0
#define NODE_BINOP 1
#define BINOP_PLUS 0
#define BINOP_MINUS 1
#define BINOP_MULTIPLY 2
#define BINOP_DIVIDE 3

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

void vecClear(Vector *vector) {
    memset(vector->data, 0, vector->size * sizeof(*vector->data));
    vector->size = 0;
}

Vector tokens = {0};
int lexerCurrent = 0;

void lexerAddToken(int8_t type, int64_t literal) {
    int8_t *token = malloc(1 + 8);
    memset(token, 0, 1 + 8);

    token[0] = (uint8_t)type;
    memcpy(token + 1, &literal, sizeof(int64_t));

    vecAppend(&tokens, (int64_t)token);
}

void lexer(char *code) {
    while (1) {
        char c = code[lexerCurrent];

        if (c == '\0') {
            lexerAddToken(TOKEN_EOF, 0);
            break;
        }

        if (c == ' ' || c == '\n') {
            lexerCurrent++;
            continue;
        }

        if (c == '+') lexerAddToken(TOKEN_PLUS, 0);
        else if (c == '-') lexerAddToken(TOKEN_MINUS, 0);
        else if (c == '*') lexerAddToken(TOKEN_STAR, 0);
        else if (c == '/') lexerAddToken(TOKEN_SLASH, 0);
        else if (c == '(') lexerAddToken(TOKEN_LEFT_BRACKET, 0);
        else if (c == ')') lexerAddToken(TOKEN_RIGHT_BRACKET, 0);
        else if (c >= '0' && c <= '9') {
            int64_t number = 0;

            while (c >= '0' && c <= '9') {
                number *= 10;
                number += c - 48;
                c = code[++lexerCurrent];
            }

            lexerAddToken(TOKEN_NUMBER, number);
            continue;
        } else {
            printf("Unknown char: %c\n", c);
        }

        lexerCurrent++;
    }
}

int8_t *createNode() {
    int8_t *node = malloc(26);
    memset(node, 0, 26);
    return node;
}

void setNodeType(int8_t *node, int8_t type) {
    node[0] = type;
}

void setNodeBinopType(int8_t *node, int8_t binopType) {
    node[1] = binopType;
}

void setNodeLiteral(int8_t *node, int64_t literal) {
    memcpy(node + 2, &literal, 8);
}

void setNodeLeft(int8_t *node, int8_t *left) {
    intptr_t addr = (intptr_t)left;
    memcpy(node + 10, &addr, 8);
}

void setNodeRight(int8_t *node, int8_t *right) {
    intptr_t addr = (intptr_t)right;
    memcpy(node + 18, &addr, 8);
}

int64_t tokenGetLiteral(int8_t *token) {
    int64_t literal;
    memcpy(&literal, token + 1, 8);
    return literal;
}

int parserCurrent = 0;

char *formatType(int8_t type) {
    return type == TOKEN_PLUS            ? "PLUS"
           : type == TOKEN_MINUS         ? "MINUS"
           : type == TOKEN_STAR          ? "STAR"
           : type == TOKEN_SLASH         ? "SLASH"
           : type == TOKEN_LEFT_BRACKET  ? "LEFT_BRACKET"
           : type == TOKEN_RIGHT_BRACKET ? "RIGHT_BRACKET"
           : type == TOKEN_NUMBER        ? "NUMBER"
                                         : "EOF";
}

char *formatBinopType(int8_t type) {
    return type == BINOP_PLUS       ? "+"
           : type == BINOP_MINUS    ? "-"
           : type == BINOP_MULTIPLY ? "*"
                                    : "/";
}

int8_t *peek() {
    return (int8_t *)tokens.data[parserCurrent];
}

bool isAtEnd() {
    return *peek() == TOKEN_EOF;
}

int8_t *previous() {
    assert(parserCurrent > 0 && "Previous at start is bad");

    return (int8_t *)tokens.data[parserCurrent - 1];
}

bool check(int8_t type) {
    if (isAtEnd())
        return false;

    int8_t *token = peek();
    return token != 0 && *token == type;
}

int8_t *advance() {
    if (!isAtEnd())
        parserCurrent++;
    return previous();
}

int8_t *consume(int8_t type) {
    if (check(type))
        return advance();

    printf("Expected: %s, got: %s\n", formatType(type), formatType(*peek()));
    exit(1);
    return 0;
}

bool match(int8_t type) {
    if (check(type)) {
        advance();
        return true;
    }
    return false;
}

int8_t *factor();
int8_t *term();
int8_t *expression();

int8_t *factor() {
    if (match(TOKEN_LEFT_BRACKET)) {
        int8_t *expr = expression();
        consume(TOKEN_RIGHT_BRACKET);
        return expr;
    }

    int8_t *numberToken = consume(TOKEN_NUMBER);
    int64_t literal = tokenGetLiteral(numberToken);

    int8_t *node = createNode();
    setNodeType(node, NODE_LITERAL);
    setNodeLiteral(node, literal);

    return node;
}

int8_t *term() {
    int8_t *node = factor();

    while (match(TOKEN_STAR) || match(TOKEN_SLASH)) {
        int8_t operator = *previous();
        int8_t *right = factor();
        int8_t *left = node;

        node = createNode();
        setNodeType(node, NODE_BINOP);
        setNodeBinopType(node, operator == TOKEN_STAR ? BINOP_MULTIPLY : BINOP_DIVIDE);
        setNodeLeft(node, left);
        setNodeRight(node, right);
    }

    return node;
}

int8_t *expression() {
    int8_t *node = term();

    while (match(TOKEN_PLUS) || match(TOKEN_MINUS)) {
        int8_t operator = *previous();
        int8_t *right = term();
        int8_t *left = node;

        node = createNode();
        setNodeType(node, NODE_BINOP);
        setNodeBinopType(node, operator == TOKEN_PLUS ? BINOP_PLUS : BINOP_MINUS);
        setNodeLeft(node, left);
        setNodeRight(node, right);
    }

    return node;
}

int8_t *parser() {
    int8_t *expr = expression();

    if (!isAtEnd()) {
        printf("Expected: EOF, got: %s\n", formatType(*peek()));
    }

    return expr;
}

char *formatAst(int8_t *ast) {
    int8_t type = *ast;
    int8_t binopType = *(ast + 1);

    if (type == NODE_LITERAL) {
        int64_t literal = *(int64_t *)(ast + 2);
        char *buffer = malloc(256);
        sprintf(buffer, "%ld", literal);
        return buffer;
    }

    int64_t leftAddr, rightAddr;
    memcpy(&leftAddr, ast + 10, 8);
    memcpy(&rightAddr, ast + 18, 8);

    int8_t *left = (int8_t *)(intptr_t)leftAddr;
    int8_t *right = (int8_t *)(intptr_t)rightAddr;

    char *leftFormatted = formatAst(left);
    char *rightFormatted = formatAst(right);

    char *buffer = malloc(256);
    sprintf(buffer, "(%s %s %s)", leftFormatted, formatBinopType(binopType), rightFormatted);
    return buffer;
}

int64_t calc(int64_t left, int64_t right, int8_t operator) {
    if (operator == BINOP_PLUS)
        return left + right;
    if (operator == BINOP_MINUS)
        return left - right;
    if (operator == BINOP_MULTIPLY)
        return left * right;
    if (operator == BINOP_DIVIDE) {
        if (right == 0) printf("sorry bud, no dividing by 0\n");
        else return left / right;
    }

    return -1;
}

int64_t interpreter(int8_t *ast) {
    int8_t type = *ast;
    int8_t binopType = *(ast + 1);

    if (type == NODE_LITERAL) {
        int64_t literal = *(int64_t *)(ast + 2);
        return literal;
    }

    int64_t leftAddr, rightAddr;
    memcpy(&leftAddr, ast + 10, 8);
    memcpy(&rightAddr, ast + 18, 8);

    int8_t *left = (int8_t *)(intptr_t)leftAddr;
    int8_t *right = (int8_t *)(intptr_t)rightAddr;

    int64_t leftValue = interpreter(left);
    int64_t rightValue = interpreter(right);

    int64_t result = calc(leftValue, rightValue, binopType);
    return result;
}

void reset() {
    vecClear(&tokens);
    lexerCurrent = 0;
    parserCurrent = 0;
}

int main() {
    char input[256];

    while (1) {
        reset();

        printf("> ");
        fgets(input, sizeof(input), stdin);

        if (strcmp(input, "q\n") == 0) {
            break;
        }

        lexer(input);

        int8_t *ast = parser();

        printf("%ld\n", interpreter(ast));
    }
}