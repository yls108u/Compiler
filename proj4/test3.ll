; === prologue ====

@.str.0 = private unnamed_addr constant [26 x i8] c"Please enter 3 integers:\0A\00", align 1
@.str.1 = private unnamed_addr constant [9 x i8] c"%d %d %d\00", align 1
@.str.2 = private unnamed_addr constant [25 x i8] c"a=%d b=%d c=%d a*b*c=%d\0A\00", align 1
declare dso_local i32 @scanf(i8*, ...)
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
%t2 = alloca i32, align 4
%t3 = alloca i32, align 4
%t4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.0, i64 0, i64 0))
%t5 = call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([9 x i8], [9 x i8]* @.str.1, i64 0, i64 0), i32* %t0, i32* %t1, i32* %t2)
%t6 = load i32, i32* %t0
%t7 = load i32, i32* %t1
%t8 = mul nsw i32 %t6, %t7
%t9 = load i32, i32* %t2
%t10 = mul nsw i32 %t8, %t9
store i32 %t10, i32* %t3
%t11 = load i32, i32* %t0
%t12 = load i32, i32* %t1
%t13 = load i32, i32* %t2
%t14 = load i32, i32* %t3
%t15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @.str.2, i64 0, i64 0), i32 %t11, i32 %t12, i32 %t13, i32 %t14)

; === epilogue ===
ret i32 0
}
