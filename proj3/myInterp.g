grammar myInterp;

options{
    language = Java;
    //backtrack = true;
    k=2;
}

@header {
    import java.util.HashMap;
    import java.util.Scanner;
}

@members {
    boolean TRACEON = true;
    HashMap memory = new HashMap();
    Scanner sc = new Scanner(System.in);
}

start
      : im_port program
      ;

im_port
        : inc+ def*
        ;

inc
    : INCLUDE '<' (.)* '>'
    ;

def
    : DEFINE Identifier Integer_constant 
      {
        memory.put($Identifier.text, new Integer(Integer.parseInt($Integer_constant.text)));
        //System.out.println($Identifier.text + " = " + $Integer_constant.text);
      }
    ;

program @init{int pt = 1;}
        : (VOID|INT) MAIN '(' ')' '{' declarations statements[pt] '}'
        ;

declarations
            : type Identifier '=' Integer_constant 
              {
                memory.put($Identifier.text, new Integer(Integer.parseInt($Integer_constant.text)));
                //System.out.println($Identifier.text + " = " + $Integer_constant.text);
              } 
              ';' declarations
            |
            ;

type
    :INT 
    ;

statements [int pt]
          : statement[pt] statements[pt]
          |
          ;

arith_expression returns [int value]
                  : a1 = multExpr {$value = $a1.value;}
                  ( '+' a2 = multExpr {$value = $value + $a2.value;}
				          | '-' a3 = multExpr {$value = $value - $a3.value;}
				          )*
                  ;

multExpr returns [int value]
          : (m1 = signExpr {$value = $m1.value;})
          ( ('*' m2 = signExpr {$value = $value * $m2.value;})
          | ('/' m3 = signExpr {$value = $value / $m3.value;})
          | ('%' m4 = signExpr {$value = $value \% $m4.value;})
          | ('>' m5 = signExpr {$value = ($value > $m5.value ? 1 : 0);})
          | ('<' m6 = signExpr {$value = ($value < $m6.value ? 1 : 0);})
          | ('|' m7 = signExpr {$value = $value | $m7.value;})
          | ('^' m8 = signExpr {$value = $value ^ $m8.value;})
          | ('&' m9 = signExpr {$value = $value & $m9.value;})
          | ('||' m10 = signExpr {$value = $value | $m10.value;})
          | ('&&' m11 = signExpr {$value = $value & $m11.value;})
          | ('>=' m12 = signExpr {$value = ($value >= $m12.value ? 1 : 0);})
          | ('<=' m13 = signExpr {$value = ($value <= $m13.value ? 1 : 0);})
          | ('==' m14 = signExpr {$value = ($value == $m14.value ? 1 : 0);})
          | ('!=' m15 = signExpr {$value = ($value != $m15.value ? 1 : 0);})
          | ('+=' m16 = signExpr {$value = $value + $m16.value;})
          | ('-=' m17 = signExpr {$value = $value - $m17.value;})
          | ('*=' m18 = signExpr {$value = $value * $m18.value;})
          | ('/=' m19 = signExpr {$value = $value / $m19.value;})
		      )*
		      ;

signExpr returns [int value]
        : s1 = primaryExpr {$value = $s1.value;}
        | '-' s2 = primaryExpr {$value = -1 * $s2.value;}
		    ;
		  
primaryExpr returns [int value]
           : Integer_constant {$value = Integer.parseInt($Integer_constant.text);}
           | Identifier
              {
                Integer v = (Integer)memory.get($Identifier.text);
                if(v != null) $value = v.intValue();
                else System.err.println("undefined var: "+$Identifier.text);
              }
		       | '(' arith_expression ')' {$value = $arith_expression.value;}
           ;

statement [int pt] @init{int flag = 1; String str;}
          : id1 = Identifier '=' arith_expression ';' //assignment
            {
              if(pt == 1){
                memory.put($id1.text, new Integer($arith_expression.value));
                //System.out.println($id1.text + " = " + $arith_expression.value);
              }
            }
          | IF '(' arith_expression ')'
            {
              if($arith_expression.value != 0){
                //System.out.println($arith_expression.value + " is true");
                if(pt == 0) flag = 0;
                else flag = 1;
              }
              else flag = 0;
            }
            j1 = judge_statements[flag]
            (
              options{greedy=true;}: ELSE 
              {
                //System.out.println($arith_expression.value + " is false");
                if(pt == 0) flag = 0;
                else {
                  if(flag == 1) flag = 0;
                  else flag = 1;
                }
              }
              j2 = judge_statements[flag]
            )?
         |  PF '('  st = string_expression 
            {
              str = $st.text;
              str = str.replace("\"","");
              //System.out.println(str);
            }  
            (',' ((id2 = Identifier{
                Integer v = (Integer)memory.get($id2.text);
                String dig = Integer.toString(v);
                str = str.replaceFirst("\%d", dig);
                //System.out.println(str);
            }
            ) | (id3 = Integer_constant{
                Integer v = Integer.parseInt($id3.text);
                String dig = Integer.toString(v);
                str = str.replaceFirst("\%d", dig);
                //System.out.println(str);
            }
            )) )* ')' ';'{str = str.replace("\\n",""); if(pt == 1) System.out.println(str);}
         |  SF '(' '"' (VAR)* '"' (',' '&' id3 = Identifier {memory.put($id3.text, sc.nextInt());} )* ')' ';'
         |  RETURN Integer_constant? ';' 
         ;

judge_statements [int flag] @init{int pt = flag;}
                  : statement[pt]
                  | '{' statements[pt] '}'
                  ;

string_expression
                  : '"' (.)* '"'
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

EscSeq: '\\n'; // ('n'|'f'|'b'|'r'|'t'|'\"'|'\''|'\\');

VAR: '%' ('d'|'f'|'s'|'c');

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};

COMMENT1 : '//'(.)*'\n' {$channel=HIDDEN;};
COMMENT2 : '/*' (.)* '*/' {$channel=HIDDEN;};
