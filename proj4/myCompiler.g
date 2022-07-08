grammar myCompiler;

options{
    language = Java;
}

@header {
    import java.util.HashMap;
    import java.util.Scanner;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;
    HashMap memory = new HashMap();
    Scanner sc = new Scanner(System.in);

    public enum Type{
      ERR, BOOL, INT, FLOAT, CHAR, CONST_INT, CONST_FLOAT;
    }

    class tVar {
      int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
      int   iValue;   // value of constant integer. Ex: 123.
      float fValue;   // value of constant floating point. Ex: 2.314.
	  };

    class Info {
      Type theType;  // type information.
      tVar theVar;
      Info() {
        theType = Type.ERR;
        theVar = new tVar();
      }
    };

    HashMap<String, Info> symtab = new HashMap<String, Info>();
    int labelCount = 0;
    int varCount = 0;
    int branch_cnt = 0;
    int branch_end = 0;
    int print_cnt = 0;
    List<String> TextCode = new ArrayList<String>();

    void prologue(){
      TextCode.add("; === prologue ====\n");
      TextCode.add("declare dso_local i32 @scanf(i8*, ...)");
      TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
	    TextCode.add("define dso_local i32 @main()");
	    TextCode.add("{");
    }

    void epilogue(){
      TextCode.add("\n; === epilogue ===");
	    TextCode.add("ret i32 0");
      TextCode.add("}");
    }

    String newLabel(){
      labelCount++;
      return (new String("L")) + Integer.toString(labelCount);
    }

    public List<String> getTextCode(){
      return TextCode;
    }
}

program
        : VOID MAIN '(' ')' 
        {
          prologue();
        }

        '{' declarations statements '}'
        {
          epilogue();
        }
        ;

declarations
            : type Identifier 
            {
              /* Add ID and its info into the symbol table. */
	            Info the_entry = new Info();
		          the_entry.theType = $type.attr_type;
		          the_entry.theVar.varIndex = varCount;
		          varCount++;
		          symtab.put($Identifier.text, the_entry);

              // issue the instruction.
		          // Ex: \%a = alloca i32, align 4
              if ($type.attr_type == Type.INT) { 
                TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
              }
              else if ($type.attr_type == Type.FLOAT) { 
                TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca float, align 4");
              }
            }

            ('=' ( Integer_constant
            {
		          // store i32 [num], i32* \%a, align 4
              Info theLHS = symtab.get($Identifier.text);
              if ($type.attr_type == Type.INT) { 
                TextCode.add("store i32 " + $Integer_constant.text + ", i32* \%t" + theLHS.theVar.varIndex + ", align 4");
              }
            }
            | Floating_point_constant
            {
              Info theLHS = symtab.get($Identifier.text);
              Float f = Float.parseFloat($Floating_point_constant.text);
              long ftrans = Double.doubleToLongBits(f.floatValue());
              if ($type.attr_type == Type.FLOAT) { 
                TextCode.add("store float 0x" + Long.toHexString(ftrans) + ", float* \%t" + theLHS.theVar.varIndex + ", align 4");
              }
            }
            ) )? 

            ';' declarations
            |
            ;

type
    returns [Type attr_type]

    :INT 
    {
      $attr_type = Type.INT;
    }
    | FLOAT
    {
      $attr_type = Type.FLOAT;
    }
    ;

statements
          : statement statements
          |
          ;

arith_expression 
                  returns [Info theInfo]
                  @init {theInfo = new Info();}

                  : a1 = multExpr 
                  {
                    $theInfo = $a1.theInfo;
                  }

                  ( '+' a2 = multExpr 
                  {
                    if(($a1.theInfo.theType == Type.INT) && ($a2.theInfo.theType == Type.INT)) {
                      TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $a2.theInfo.theVar.varIndex);
					            $theInfo.theType = Type.INT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount++;
                    } 
                    else if(($a1.theInfo.theType == Type.INT) && ($a2.theInfo.theType == Type.CONST_INT)) {
                      TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $a2.theInfo.theVar.iValue);
					            $theInfo.theType = Type.INT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount++;
                    }
                    else if(($a1.theInfo.theType == Type.CONST_INT) && ($a2.theInfo.theType == Type.INT)) {
                      TextCode.add("\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $a2.theInfo.theVar.varIndex);
					            $theInfo.theType = Type.INT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount++;
                    }
                    else if(($a1.theInfo.theType == Type.FLOAT) && ($a2.theInfo.theType == Type.CONST_FLOAT)) {
                      TextCode.add("\%t" + varCount + " = fpext float \%t" + (varCount-1) + " to double");
                      Float f = $a2.theInfo.theVar.fValue;
                      long ftrans = Double.doubleToLongBits(f.floatValue());
                      TextCode.add("\%t" + (varCount+1) + " = fadd double \%t" + varCount + ", 0x" + Long.toHexString(ftrans));
                      TextCode.add("\%t" + (varCount+2) + " = fptrunc double \%t" + (varCount+1) + " to float");
					            $theInfo.theType = Type.FLOAT;
					            $theInfo.theVar.varIndex = varCount + 2;
					            varCount = varCount + 3;
                    }
                    else if(($a1.theInfo.theType == Type.CONST_FLOAT) && ($a2.theInfo.theType == Type.FLOAT)) {
                      TextCode.add("\%t" + varCount + " = fpext float \%t" + (varCount-1) + " to double");
                      Float f = $a2.theInfo.theVar.fValue;
                      long ftrans = Double.doubleToLongBits(f.floatValue());
                      TextCode.add("\%t" + (varCount+1) + " = fadd double 0x" + Long.toHexString(ftrans) + ", \%t" + varCount);
                      TextCode.add("\%t" + (varCount+2) + " = fptrunc double \%t" + (varCount+1) + " to float");
					            $theInfo.theType = Type.FLOAT;
					            $theInfo.theVar.varIndex = varCount + 2;
					            varCount = varCount + 3;
                    }
                  }

				          | '-' a3 = multExpr 
                  {
                    if(($a1.theInfo.theType == Type.INT) && ($a3.theInfo.theType == Type.INT)) {
                      TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $a3.theInfo.theVar.varIndex);
					            $theInfo.theType = Type.INT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount++;
                    } 
                    else if(($a1.theInfo.theType == Type.INT) && ($a3.theInfo.theType == Type.CONST_INT)) {
                      TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $a3.theInfo.theVar.iValue);
					            $theInfo.theType = Type.INT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount++;
                    }
                    else if(($a1.theInfo.theType == Type.CONST_INT) && ($a3.theInfo.theType == Type.INT)) {
                      TextCode.add("\%t" + varCount + " = sub nsw i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $a3.theInfo.theVar.varIndex);
					            $theInfo.theType = Type.INT;
					            $theInfo.theVar.varIndex = varCount;
					            varCount++;
                    }
                    else if(($a1.theInfo.theType == Type.FLOAT) && ($a3.theInfo.theType == Type.CONST_FLOAT)) {
                      TextCode.add("\%t" + varCount + " = fpext float \%t" + (varCount-1) + " to double");
                      Float f = $a3.theInfo.theVar.fValue;
                      long ftrans = Double.doubleToLongBits(f.floatValue());
                      TextCode.add("\%t" + (varCount+1) + " = fsub double \%t" + varCount + ", 0x" + Long.toHexString(ftrans));
                      TextCode.add("\%t" + (varCount+2) + " = fptrunc double \%t" + (varCount+1) + " to float");
					            $theInfo.theType = Type.FLOAT;
					            $theInfo.theVar.varIndex = varCount + 2;
					            varCount = varCount + 3;
                    }
                    else if(($a1.theInfo.theType == Type.CONST_FLOAT) && ($a3.theInfo.theType == Type.FLOAT)) {
                      TextCode.add("\%t" + varCount + " = fpext float \%t" + (varCount-1) + " to double");
                      Float f = $a1.theInfo.theVar.fValue;
                      long ftrans = Double.doubleToLongBits(f.floatValue());
                      TextCode.add("\%t" + (varCount+1) + " = fsub double 0x" + Long.toHexString(ftrans) + ", \%t" + varCount);
                      TextCode.add("\%t" + (varCount+2) + " = fptrunc double \%t" + (varCount+1) + " to float");
					            $theInfo.theType = Type.FLOAT;
					            $theInfo.theVar.varIndex = varCount + 2;
					            varCount = varCount + 3;
                    }
                  }
				          )*
                  ;

multExpr
          returns [Info theInfo]
          @init {theInfo = new Info();}

          : (m1 = signExpr 
          {
            $theInfo = $m1.theInfo;
          }
          )

          ( ('*' m2 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m2.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m2.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m2.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $m2.theInfo.theVar.iValue);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m2.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m2.theInfo.theVar.varIndex);
				      $theInfo.theType = Type.INT;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('/' m3 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m3.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m3.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m3.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", " + $m3.theInfo.theVar.iValue);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m3.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m3.theInfo.theVar.varIndex);
				      $theInfo.theType = Type.INT;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('%' m4 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m4.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m4.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m4.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", " + $m4.theInfo.theVar.iValue);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m4.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = srem i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m4.theInfo.theVar.varIndex);
				      $theInfo.theType = Type.INT;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('>' m5 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m5.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m5.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m5.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = icmp sgt i32 \%t" + $theInfo.theVar.varIndex + ", " + $m5.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m5.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp sgt i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m5.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('<' m6 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m6.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m6.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m6.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = icmp slt i32 \%t" + $theInfo.theVar.varIndex + ", " + $m6.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m6.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp slt i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m6.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('|' m7 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m7.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = or i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m7.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m7.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = or i32 \%t" + $theInfo.theVar.varIndex + ", " + $m7.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m7.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = or i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m7.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('^' m8 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m8.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = xor i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m8.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m8.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = xor i32 \%t" + $theInfo.theVar.varIndex + ", " + $m8.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m8.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = xor i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m8.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('&' m9 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m9.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = and i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m9.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m9.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = and i32 \%t" + $theInfo.theVar.varIndex + ", " + $m9.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m9.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = and i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m9.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('||' m10 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m10.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = or i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m10.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m10.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = or i32 \%t" + $theInfo.theVar.varIndex + ", " + $m10.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m10.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = or i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m10.theInfo.theVar.varIndex);
				      $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('&&' m11 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m11.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = and i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m11.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m11.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = and i32 \%t" + $theInfo.theVar.varIndex + ", " + $m11.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m11.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = and i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m11.theInfo.theVar.varIndex);
				      $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('>=' m12 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m12.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m12.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m12.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = icmp sge i32 \%t" + $theInfo.theVar.varIndex + ", " + $m12.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m12.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp sge i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m12.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('<=' m13 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m13.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m13.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m13.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = icmp sle i32 \%t" + $theInfo.theVar.varIndex + ", " + $m13.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m13.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp sle i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m13.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('==' m14 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m14.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m14.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m14.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = icmp eq i32 \%t" + $theInfo.theVar.varIndex + ", " + $m14.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m14.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp eq i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m14.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('!=' m15 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m15.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m15.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m15.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = icmp ne i32 \%t" + $theInfo.theVar.varIndex + ", " + $m15.theInfo.theVar.iValue);
					    $theInfo.theType = Type.BOOL;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m15.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = icmp ne i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m15.theInfo.theVar.varIndex);
              $theInfo.theType = Type.BOOL;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('+=' m16 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m16.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m16.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m16.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $m16.theInfo.theVar.iValue);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m16.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = add nsw i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m16.theInfo.theVar.varIndex);
				      $theInfo.theType = Type.INT;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('-=' m17 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m17.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m17.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m17.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = sub nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $m17.theInfo.theVar.iValue);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m17.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = sub nsw i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m17.theInfo.theVar.varIndex);
				      $theInfo.theType = Type.INT;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('*=' m18 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m18.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m18.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m18.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $m18.theInfo.theVar.iValue);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m18.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m18.theInfo.theVar.varIndex);
				      $theInfo.theType = Type.INT;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )

          | ('/=' m19 = signExpr 
          {
            if(($m1.theInfo.theType == Type.INT) && ($m19.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $m19.theInfo.theVar.varIndex);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            } 
            else if(($m1.theInfo.theType == Type.INT) && ($m19.theInfo.theType == Type.CONST_INT)) {
              TextCode.add("\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", " + $m19.theInfo.theVar.iValue);
					    $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
            }
            else if(($m1.theInfo.theType == Type.CONST_INT) && ($m19.theInfo.theType == Type.INT)) {
              TextCode.add("\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", " + "\%t" + $m19.theInfo.theVar.varIndex);
				      $theInfo.theType = Type.INT;
				      $theInfo.theVar.varIndex = varCount;
				      varCount++;
            }
          }
          )
		      )*
		      ;

signExpr
        returns [Info theInfo]
        @init {theInfo = new Info();}

        : s1 = primaryExpr 
        {
          $theInfo = $s1.theInfo;
        }

        | ('-' s2 = primaryExpr)
        {
          if($s2.theInfo.theType == Type.INT){
            TextCode.add("\%t" + varCount + " = sub nsw i32 0, \%t" + $s2.theInfo.theVar.varIndex);
					  $theInfo.theType = Type.INT;
					  $theInfo.theVar.varIndex = varCount;
					  varCount++;
          }
        }
		    ;
		  
primaryExpr
            returns [Info theInfo]
            @init {theInfo = new Info();}

            : Integer_constant 
            {
              $theInfo.theType = Type.CONST_INT;
			        $theInfo.theVar.iValue = Integer.parseInt($Integer_constant.text);
            }

            | Floating_point_constant
            {
              $theInfo.theType = Type.CONST_FLOAT;
			        $theInfo.theVar.fValue = Float.parseFloat($Floating_point_constant.text);
            }

            | Identifier
            {
              // get type information from symtab.
              Type the_type = symtab.get($Identifier.text).theType;
				      $theInfo.theType = the_type;

              // get variable index from symtab.
              int vIndex = symtab.get($Identifier.text).theVar.varIndex;
				      switch (the_type) {
                case INT: 
                  // get a new temporary variable and load the variable into the temporary variable.
                  // Ex: \%tx = load i32, i32* \%ty.
						      TextCode.add("\%t" + varCount + " = load i32, i32* \%t" + vIndex);
						      // Now, Identifier's value is at the temporary variable \%t[varCount]. Therefore, update it.
						      $theInfo.theVar.varIndex = varCount;
						      varCount++;
                  break;

                case FLOAT:
                  TextCode.add("\%t" + varCount + " = load float, float* \%t" + vIndex);
						      $theInfo.theVar.varIndex = varCount;
						      varCount++;
                  break;

                case CHAR:
                  break;
              }
            }
		        
            | '(' arith_expression ')'
           ;

statement
          returns [Info theInfo]
          @init 
          {
            theInfo = new Info(); 
            String str; 
            String ptr;
            String tpr;
            Integer strlen = 0; 
            Integer id_cnt = 0; 
            Integer in_cnt = 0; 
            Integer sf_cnt = 0;
            List VarList = new ArrayList(); 
            List TypeList = new ArrayList();
            List IndexList = new ArrayList();
          } 

          : id1 = Identifier '=' a1 = arith_expression ';'
            {
              Info theRHS = $a1.theInfo;
				      Info theLHS = symtab.get($id1.text);
		   
              if((theLHS.theType == Type.INT) && (theRHS.theType == Type.INT)){
                TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex);
				      } 
              else if((theLHS.theType == Type.INT) && (theRHS.theType == Type.CONST_INT)){
                TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex);
              }
              else if((theLHS.theType == Type.FLOAT) && (theRHS.theType == Type.FLOAT)){
                TextCode.add("store float \%t" + theRHS.theVar.varIndex + ", float* \%t" + theLHS.theVar.varIndex);
				      } 
              else if((theLHS.theType == Type.FLOAT) && (theRHS.theType == Type.CONST_FLOAT)){
                Float f = theRHS.theVar.fValue;
                long ftrans = Double.doubleToLongBits(f.floatValue());
                TextCode.add("store float 0x" + Long.toHexString(ftrans) + ", float* \%t" + theLHS.theVar.varIndex);
              }
            }

          | IF '(' a2 = arith_expression ')'
            {
              //br i1 ...
              Info pre = $a2.theInfo;
              TextCode.add("br i1 \%t" + pre.theVar.varIndex + ", label \%b" + branch_cnt + ", label \%b" + (branch_cnt+1));
              //t?:
              TextCode.add("b" + branch_cnt + ":");
              branch_cnt++;
            }
            j1 = judge_statements
            {
              //record the last br num of the if else stat
              //br label ...
              TextCode.add("br label \%bl" + branch_end);
            }
            (options{greedy=true;}: ELSE 
            {
              //t?:
              TextCode.add("b" + branch_cnt + ":");
              branch_cnt++;
            }
            j2 = judge_statements
            {
              //br label ...
              TextCode.add("br label \%bl" + branch_end);
            }
            )?
            {
              TextCode.add("bl" + branch_end + ":");
              branch_end++;
            }

          | PF '(' st = string_expression (',' ((id2 = Identifier
            {
              Type the_type = symtab.get($id2.text).theType;
				      $theInfo.theType = the_type;
              int vIndex = symtab.get($id2.text).theVar.varIndex;
				      switch (the_type) {
                case INT:
                  VarList.add(varCount);
                  TypeList.add("ID");
                  id_cnt++;
						      TextCode.add("\%t" + varCount + " = load i32, i32* \%t" + vIndex);
                  $theInfo.theVar.varIndex = varCount;
						      varCount++;
                  break;
                case FLOAT:
                  VarList.add(varCount+1);
                  TypeList.add("IDF");
                  id_cnt++;
						      TextCode.add("\%t" + varCount + " = load float, float* \%t" + vIndex);
                  TextCode.add("\%t" + (varCount+1) + " = fpext float \%t" + (varCount) + " to double");
                  $theInfo.theVar.varIndex = varCount + 1;
						      varCount = varCount + 2;
                  break;
                case CHAR:
                  break;
              }
            }
            ) | (id3 = Integer_constant
            {
              VarList.add($id3.text);
              TypeList.add("INTC");
              in_cnt++;
            }
            )) )* ')' ';'
            {
              str = $st.text;
              str = str.replace("\"","");
              strlen = str.length();
              TextCode.add(print_cnt+1, "@.str." + print_cnt + " = private unnamed_addr constant [" + strlen + " x i8] c\"" + str.replace("\\n","") + "\\0A\\00\", align 1");
              if((id_cnt == 0) && (in_cnt == 0)){
                TextCode.add("\%t" + varCount + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + strlen + " x i8], [" + strlen + " x i8]* @.str." + print_cnt + ", i64 0, i64 0))");
              }
              else{
                String tmp = "\%t" + Integer.toString(varCount) + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([" + Integer.toString(strlen) + " x i8], [" + Integer.toString(strlen) + " x i8]* @.str." + print_cnt + ", i64 0, i64 0)";
                
                for(int i = 0, j = 0, k = 0; k < id_cnt + in_cnt; k++){
                  if(TypeList.get(k) == "ID"){
                    tmp = tmp + ", i32 \%t" + VarList.get(k);
                    i++;
                  }
                  else if(TypeList.get(k) == "IDF"){
                    tmp = tmp + ", double \%t" + VarList.get(k);
                    i++;
                  }
                  else{
                    tmp = tmp + ", i32 " + VarList.get(k);
                    j++;
                  }
                }
                tmp = tmp + ")";
                TextCode.add(tmp);
              }
              $theInfo.theType = Type.INT;
					    $theInfo.theVar.varIndex = varCount;
					    varCount++;
              print_cnt++;
            }

          |  SF '(' '"' (VAR {sf_cnt++;} )* '"' 
          {
            ptr = "";
            for(int i = 0; i < sf_cnt; i++){
              ptr = ptr + "\%d";
              if(i + 1 != sf_cnt){
                ptr = ptr + " ";
              }
            }
            //ptr = "\%d \%d";
            strlen = ptr.length() + 1;
            TextCode.add(print_cnt+1, "@.str." + print_cnt + " = private unnamed_addr constant [" + strlen + " x i8] c\"" + ptr + "\\00\", align 1");
            tpr = "\%t" + Integer.toString(varCount) + " = call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([" + Integer.toString(strlen) + " x i8], [" + Integer.toString(strlen) + " x i8]* @.str." + print_cnt + ", i64 0, i64 0)";
          }
          (',' '&' id3 = Identifier 
          {
            Type the_type = symtab.get($id3.text).theType;
				    $theInfo.theType = the_type;
            int vIndex = symtab.get($id3.text).theVar.varIndex;
            IndexList.add(vIndex);
          } 
          )* ')' ';'
          {
            for(int i = 0; i < sf_cnt; i++){
              tpr = tpr + ", i32* \%t" + IndexList.get(i);
            }
            tpr = tpr + ")";
            TextCode.add(tpr);
            $theInfo.theType = Type.INT;
					  $theInfo.theVar.varIndex = varCount;
            print_cnt++;
            varCount++;
          }
          ;

judge_statements
                  : statement
                  | '{' statements '}'
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
Integer_constant:('-')? '0'..'9'+;
Floating_point_constant:('-')? '0'..'9'+ '.' '0'..'9'+;

EscSeq: '\\n'; // ('n'|'f'|'b'|'r'|'t'|'\"'|'\''|'\\');

VAR: '%' ('d'|'f'|'s'|'c');

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};

COMMENT1 : '//'(.)*'\n' {$channel=HIDDEN;};
COMMENT2 : '/*' (.)* '*/' {$channel=HIDDEN;};
