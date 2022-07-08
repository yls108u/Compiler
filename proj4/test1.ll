; === prologue ====

@.str.0 = private unnamed_addr constant [11 x i8] c"a=%d b=%d\0A\00", align 1
@.str.1 = private unnamed_addr constant [19 x i8] c"new a=%d new b=%d\0A\00", align 1
declare dso_local i32 @scanf(i8*, ...)
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
store i32 10, i32* %t0, align 4
%t1 = alloca i32, align 4
store i32 5, i32* %t1, align 4
%t2 = load i32, i32* %t0
%t3 = load i32, i32* %t1
%t4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.0, i64 0, i64 0), i32 %t2, i32 %t3)
%t5 = load i32, i32* %t1
%t6 = mul nsw i32 %t5, 4
store i32 %t6, i32* %t0
%t7 = load i32, i32* %t0
%t8 = load i32, i32* %t1
%t9 = sdiv i32 %t8, 5
%t10 = sub nsw i32 %t7, %t9
store i32 %t10, i32* %t1
%t11 = load i32, i32* %t0
%t12 = load i32, i32* %t1
%t13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([19 x i8], [19 x i8]* @.str.1, i64 0, i64 0), i32 %t11, i32 %t12)

; === epilogue ===
ret i32 0
}
