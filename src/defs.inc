%ifndef DEFS_INC
%define DEFS_INC

TOKEN_PLUS          equ 0
TOKEN_MINUS         equ 1
TOKEN_STAR          equ 2
TOKEN_SLASH         equ 3
TOKEN_LEFT_BRACKET  equ 4
TOKEN_RIGHT_BRACKET equ 5
TOKEN_NUMBER        equ 6
TOKEN_EOF           equ 7

NODE_LITERAL        equ 0
NODE_BINOP          equ 1

BINOP_PLUS          equ 0
BINOP_MINUS         equ 1
BINOP_MULTIPLY      equ 2
BINOP_DIVIDE        equ 3

%endif