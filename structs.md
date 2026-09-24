```c
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
```

```c
struct Token { // 9 bytes
    int8_t  type    = 'TOKEN_PLUS' | ... | 'TOKEN_EOF'; // 0
    int64_t literal = 'NUMBER';                       // 1
}
```


```c
struct Node { // 26 bytes
    int8_t type      = 'NODE_LITERAL' | 'NODE_BINOP';                                    // 0
    int8_t binopType = 'BINOP_PLUS' | 'BINOP_MINUS' | 'BINOP_MULTIPLY' | 'BINOP_DIVIDE'; // 1
    int64_t literal  = 'NUMBER';                                                         // 2
    int64_t left     = "pointer to Node";                                                // 10
    int64_t right    = "pointer to Node";                                                // 18
}
```