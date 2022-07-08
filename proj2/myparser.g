grammar myparser;

options{
    language = Java;
    //backtrack = true;
    k=2;
}

@header {
    //import packages here.
}

@members {
    boolean TRACEON = true;
}

program:(INCLUDE '<' (.)* '>')+ (DEFINE Identifier (Integer_constant | Floating_point_constant))* (VOID|INT) MAIN '(' ')' '{' declarations statements '}' 
        {if (TRACEON) System.out.println("(INCLUDE < (.)* >)+ (DEFINE Identifier (Integer_constant | Floating_point_constant))* (VOID|INT) MAIN () {declarations statements}");};

declarations:type '*'? Identifier ('[' Integer_constant ']')? ('=' (Integer_constant | Floating_point_constant | NULL))? ';' declarations
             { if (TRACEON) System.out.println("declarations: type *? Identifier ([ Integer_constant ])? (= (Integer_constant | Floating_point_constant | NULL))? ; declarations"); }
           | { if (TRACEON) System.out.println("declarations: ");} ;

loop_declarations:type Identifier '=' (Integer_constant | Floating_point_constant)
                  { if (TRACEON) System.out.println("type Identifier = (Integer_constant | Floating_point_constant)");};

type:INT { if (TRACEON) System.out.println("type: INT"); }
   | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); }
   | DOUBLE {if (TRACEON) System.out.println("type: DOUBLE"); }
   | CHAR {if (TRACEON) System.out.println("type: CHAR"); }
   | VOID {if (TRACEON) System.out.println("type: VOID"); };

statements:statement statements
        |;

arith_expression: multExpr
                  ( '+' multExpr
				          | '-' multExpr
				          )*
                  ;

multExpr: (signExpr|'++'|'--')
          ( ('*' signExpr)
          | ('/' signExpr)
          | ('%' signExpr)
          | ('>' signExpr)
          | ('<' signExpr)
          | ('|' signExpr)
          | ('^' signExpr)
          | ('&' signExpr)
          | ('||' signExpr)
          | ('&&' signExpr)
          | ('>=' signExpr)
          | ('<=' signExpr)
          | ('==' signExpr)
          | ('!=' signExpr)
          | ('+=' signExpr)
          | ('-=' signExpr)
          | ('*=' signExpr)
          | ('/=' signExpr)
          | ('>>' signExpr)
          | ('<<' signExpr)
          | ('++')|('--')
		      )*
		      ;

signExpr: primaryExpr
        | '-' primaryExpr
		    ;
		  
primaryExpr: Integer_constant
           | Floating_point_constant
           | Identifier
           | NULL
		       | '(' arith_expression ')'
           ;

statement: Identifier '=' expression ';' 
           {if (TRACEON) System.out.println("statement: Identifier = expression ;"); }
         | Identifier arith_expression ';' 
           {if (TRACEON) System.out.println("statement: Identifier arith_expression ;"); }
         | IF '(' arith_expression ')' judge_statements (options{greedy=true;}:ELSE judge_statements)? 
           {if (TRACEON) System.out.println("statement: IF ( arith_expression ) judge_statements"); }
         | FOR '(' ( statement | loop_declarations) ';' arith_expression ';' arith_expression ')' judge_statements 
           {if (TRACEON) System.out.println("statement: FOR ( ( statement | loop_declarations) ; arith_expression ; arith_expression ) judge_statements"); }
         | WH '(' arith_expression ')' judge_statements 
           {if (TRACEON) System.out.println("statement: WH ( arith_expression ) judge_statements"); }
         | PF '(' '"' (string_expression)* '"' (',' (Identifier | Integer_constant | Floating_point_constant))* ')' ';' 
           {if (TRACEON) System.out.println("statement: PF ( \" string_expression \" (, (Identifier | Integer_constant | Floating_point_constant))* ) ;"); }
         | SF '(' '"' VAR* '"' (',' '&' Identifier)* ')' ';' 
           {if (TRACEON) System.out.println("statement: SF ( \" VAR* \" (, & Identifier)* ) ;"); }
         | BREAK ';' 
           {if (TRACEON) System.out.println("statement: BREAK ;"); }
         | CONTINUE ';' 
           {if (TRACEON) System.out.println("statement: CONTINUE ;"); }
         | RETURN Integer_constant? ';' 
           {if (TRACEON) System.out.println("statement: RETURN Integer_constant? ;"); }
         ;

judge_statements: statement {if (TRACEON) System.out.println("judge_statements: statement"); }
                  | '{' statements '}' {if (TRACEON) System.out.println("judge_statements: { statements }"); };

string_expression: EscSeq | (~('\\'|'"'));

mac_expression: MAC '(' ((SOF '(' type ')' '*' '(' arith_expression ')') | Integer_constant ) ')';

expression:	arith_expression {if (TRACEON) System.out.println("expression: arith_expression"); }
	| mac_expression {if (TRACEON) System.out.println("expression: mac_expression"); }
	;



/* description of the tokens */
/*Data type*/
INT   : 'int';
FLOAT : 'float';
DOUBLE : 'double';
CHAR   : 'char';
VOID  : 'void';
INCLUDE : '#include';
DEFINE : '#define';
BREAK: 'break';
CONTINUE: 'continue';
FOR   : 'for';
WH     : 'while';
IF    : 'if';
ELSE    : 'else';
RETURN : 'return';
NULL   : 'NULL';
MAIN   : 'main';
PF    : 'printf';
SF    : 'scanf';
MAC   : 'malloc';
FGETS  : 'fgets';
SOF  : 'sizeof';
FREE : 'free';

/*Punctuation Marks*/
LPAREM: '(';
RPAREM: ')';
SEMICO: ';';
LBRACKET: '[';
RBRACKET : ']';
LBRACE   : '{';
RBRACE   : '}';
COMMA    : ',';
COLON    : ':';
DQUOTE   : '"';
SDQUOTE   : '\'';

/*Compound Operators*/
PLU  : '+';
MIN  : '-';
MUL : '*';
DIV  : '/';
ASS  : '=';
LE  : '<';
GE  : '>';
AMP : '&';
BOR: '|';
XOR  : '^';
NOT  : '!';
UNA : '~';
EQ: '==';
LEQ : '<=';
GEQ  : '>=';
NE  : '!=';
AND  : '&&';
LOR  : '||';
PP  : '++';
MM : '--'; 
RSH : '<<';
LSH : '>>';
PER : '%';
BLAC : '\\';
HASH: '#';

/*struct opreator*/
DOT : '.';
PTER : '->';

/*num and id*/
Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;

EscSeq: '\\' ('n'|'f'|'b'|'r'|'t'|'\"'|'\''|'\\');

VAR: '%' ('d'|'f'|'s'|'c');

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};

COMMENT1 : '//'(.)*'\n' {$channel=HIDDEN;};
COMMENT2 : '/*' (.)* '*/' {$channel=HIDDEN;};