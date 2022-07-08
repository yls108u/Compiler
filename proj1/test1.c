#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>

typedef struct test{
    int a_int;
    float a_float;
    double a_double;
    char a_char;
    long int a_longint;
    long long int a_longlongint;
}Test;

void mytest(int j)
{
    j++;
    j--;
    j=j*1;
    j=j/1;
    j<<2;
    j>>2;

    int i=0;
    int k=0;
    k=i&i;
    k=i|i;
    k=i^i;
    k=!i;
    k=~i;
}

int main(void)
{
    for(int i=0;i<100;i++){
        if(i%20==0) printf("for test %d\n", i);
        else continue;
    }
    
    int j=0;
    while(j<100){
        if(j%50==0) printf("for test2 %d\n", j);
        else if(j%100==0) break;
        j++;
    }

    //mytest(j);

    return 0;
}
