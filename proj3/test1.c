#include<stdio.h>
#define Three 3

void main()
{
    int a=10;
    int c=0;
    printf("a=%d c=%d define Three=%d\n",a,c,Three);
    a=10+11;
    printf("enter a number:\n");
    scanf("%d",&c);
    c=c+1;
    printf("The new number is %d after plus 1~\n",c);
}