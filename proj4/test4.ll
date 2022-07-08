; === prologue ====

@.str.0 = private unnamed_addr constant [16 x i8] c"a=%d,b=%f,c=%f\0A\00", align 1
declare dso_local i32 @scanf(i8*, ...)
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca float, align 4
%t2 = alloca float, align 4
store i32 1, i32* %t0
store float 0x4002b851e0000000, float* %t1
%t3 = load float, float* %t1
%t4 = fpext float %t3 to double
%t5 = fsub double %t4, 0x4002666660000000
%t6 = fptrunc double %t5 to float
store float %t6, float* %t2
%t7 = load i32, i32* %t0
%t8 = load float, float* %t1
%t9 = fpext float %t8 to double
%t10 = load float, float* %t2
%t11 = fpext float %t10 to double
%t12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @.str.0, i64 0, i64 0), i32 %t7, double %t9, double %t11)

; === epilogue ===
ret i32 0
}
