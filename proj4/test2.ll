; === prologue ====

@.str.0 = private unnamed_addr constant [36 x i8] c"Please enter 2 integers for a & j:\0A\00", align 1
@.str.1 = private unnamed_addr constant [6 x i8] c"%d %d\00", align 1
@.str.2 = private unnamed_addr constant [11 x i8] c"a=%d j=%d\0A\00", align 1
@.str.3 = private unnamed_addr constant [23 x i8] c"a = %d is less than 0\0A\00", align 1
@.str.4 = private unnamed_addr constant [7 x i8] c"a = 0\0A\00", align 1
@.str.5 = private unnamed_addr constant [12 x i8] c"a = %d > 0\0A\00", align 1
@.str.6 = private unnamed_addr constant [8 x i8] c"j+a=%d\0A\00", align 1
@.str.7 = private unnamed_addr constant [8 x i8] c"j-a=%d\0A\00", align 1
@.str.8 = private unnamed_addr constant [8 x i8] c"j*a=%d\0A\00", align 1
@.str.9 = private unnamed_addr constant [8 x i8] c"j/a=%d\0A\00", align 1
@.str.10 = private unnamed_addr constant [8 x i8] c"b <= a\0A\00", align 1
declare dso_local i32 @scanf(i8*, ...)
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
store i32 100, i32* %t0, align 4
%t1 = alloca i32, align 4
store i32 999, i32* %t1, align 4
%t2 = alloca i32, align 4
store i32 0, i32* %t2, align 4
%t3 = alloca i32, align 4
store i32 1, i32* %t3, align 4
%t4 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([36 x i8], [36 x i8]* @.str.0, i64 0, i64 0))
%t5 = call i32 (i8*, ...) @scanf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str.1, i64 0, i64 0), i32* %t0, i32* %t3)
%t6 = load i32, i32* %t0
%t7 = load i32, i32* %t3
%t8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), i32 %t6, i32 %t7)
%t9 = load i32, i32* %t0
%t10 = icmp slt i32 %t9, 0
br i1 %t10, label %b0, label %b1
b0:
%t11 = load i32, i32* %t0
%t12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str.3, i64 0, i64 0), i32 %t11)
br label %bl0
b1:
%t13 = load i32, i32* %t0
%t14 = icmp eq i32 %t13, 0
br i1 %t14, label %b2, label %b3
b2:
%t15 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @.str.4, i64 0, i64 0))
br label %bl0
b3:
%t16 = load i32, i32* %t0
%t17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.5, i64 0, i64 0), i32 %t16)
%t18 = load i32, i32* %t1
%t19 = load i32, i32* %t0
%t20 = icmp sgt i32 %t18, %t19
br i1 %t20, label %b4, label %b5
b4:
%t21 = load i32, i32* %t3
%t22 = load i32, i32* %t0
%t23 = add nsw i32 %t21, %t22
store i32 %t23, i32* %t2
%t24 = load i32, i32* %t2
%t25 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.6, i64 0, i64 0), i32 %t24)
%t26 = load i32, i32* %t3
%t27 = load i32, i32* %t0
%t28 = sub nsw i32 %t26, %t27
store i32 %t28, i32* %t2
%t29 = load i32, i32* %t2
%t30 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.7, i64 0, i64 0), i32 %t29)
%t31 = load i32, i32* %t3
%t32 = load i32, i32* %t0
%t33 = mul nsw i32 %t31, %t32
store i32 %t33, i32* %t2
%t34 = load i32, i32* %t2
%t35 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.8, i64 0, i64 0), i32 %t34)
%t36 = load i32, i32* %t3
%t37 = load i32, i32* %t0
%t38 = sdiv i32 %t36, %t37
store i32 %t38, i32* %t2
%t39 = load i32, i32* %t2
%t40 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.9, i64 0, i64 0), i32 %t39)
br label %bl0
b5:
%t41 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @.str.10, i64 0, i64 0))
br label %bl0
bl0:
br label %bl1
bl1:
br label %bl2
bl2:

; === epilogue ===
ret i32 0
}
