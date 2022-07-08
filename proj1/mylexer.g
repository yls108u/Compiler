lexer grammar mylexer;

options{
    language = Java;
}


/*----------------------*/
/*   Reserved Keywords  */
/*----------------------*/
/*Data type*/
INT_TYPE    : 'int';
FLOAT_TYPE  : 'float';
DOUBLE_TYPE : 'double';
CHAR_TYPE   : 'char';
VOID_TYPE   : 'void';
STRUCT_TYPE : 'struct';
LONG_TYPE   : (LONG)(LONG)*('int');

/*Punctuation Marks*/
LPAREM_TYPE   : '(';
RPAREM_TYPE   : ')';
SEMICO_TYPE   : ';';
LBRACKET_TYPE : '[';
RBRACKET_TYPE : ']';
LBRACE_TYPE   : '{';
RBRACE_TYPE   : '}';
COMMA_TYPE    : ',';
COLON_TYPE    : ':';
DQUOTE_TYPE   : '"';
SDQUOTE_TYPE   : '\'';

/*other*/
INC_TYPE    : '#include';
FOR_TYPE    : 'for';
WH_TYPE     : 'while';
IF_TYPE     : 'if';
EL_TYPE     : 'else';
CON_TYPE    : 'continue';
BREAK_TYPE  : 'break';
SW_TYPE     : 'switch';
CASE_TYPE   : 'case';
DEF_TYPE    : 'default';
RETURN_TYPE : 'return';
NULL_TYPE   : 'NULL';
EOF_TYPE    : 'EOF';
MAIN_TYPE   : 'main';
PF_TYPE     : 'printf';
SF_TYPE     : 'scanf';
MAC_TYPE    : 'malloc';
FGETS_TYPE  : 'fgets';
SOF_TYPE    : 'sizeof';
FREE_TYPE   : 'free';
TDEF_TYPE   : 'typedef';


/*----------------------*/
/*  Compound Operators  */
/*----------------------*/
PLU_OP  : '+';
MIN_OP  : '-';
MUL_OP  : '*';
DIV_OP  : '/';
ASS_OP  : '=';
LE_OP   : '<';
GE_OP   : '>';
AMP_OP  : '&';
BOR_OP  : '|';
XOR_OP  : '^';
NOT_OP  : '!';
UNA_OP  : '~';
EQ_OP   : '==';
LEQ_OP  : '<=';
GEQ_OP  : '>=';
NE_OP   : '!=';
AND_OP  : '&&';
LOR_OP  : '||';
PP_OP   : '++';
MM_OP   : '--'; 
RSH_OP  : '<<';
LSH_OP  : '>>';
PER_OP  : '%';
BLAC_OP : '\\';

/*struct opreator*/
DOT_OP  : '.';
PTER_OP : '->';

/*num and id*/
DEC_NUM : ('0' | ('1'..'9')(DIGIT)*);
ID : (LETTER)(LETTER | DIGIT)*;
FLOAT_NUM: FLOAT_NUM1 | FLOAT_NUM2 | FLOAT_NUM3;

fragment FLOAT_NUM1: (DIGIT)+'.'(DIGIT)*;
fragment FLOAT_NUM2: '.'(DIGIT)+;
fragment FLOAT_NUM3: (DIGIT)+;

/* Comments */
COMMENT1 : '//'(.)*'\n';
COMMENT2 : '/*' (options{greedy=false;}: .)* '*/';
COMMENT3 : '"' (options{greedy=false;}: .)* '"';

fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';
fragment DIGIT : '0'..'9';
fragment LONG : 'long ';

WS  : (' '|'\r'|'\t'|'\n')+
    ;
