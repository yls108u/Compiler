#include<stdio.h>
#define pi 3.14

void main()
{
    char *ptr=NULL;
    ptr=malloc(1024);
    for(int i=0;i<100;i++)
        printf("for test %d\n", i);
}