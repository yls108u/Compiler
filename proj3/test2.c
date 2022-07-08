#include<stdio.h>

int main()
{
    int a=0;
    int j=0;
    int i=0;

    printf("enter a number:\n");
    scanf("%d",&a);

    if(a < 0) {
        printf("a = %d is less than 0\n",a);
    }
    else if(a > 0) {
        printf("a = %d > 0\n",a);
        printf("enter another number:\n");
        scanf("%d",&j);

        if(j>a){
            i=j+a;
            printf("j+a=%d\n",i);
            i=j-a;
            printf("j-a=%d\n",i);
            i=j*a;
            printf("j*a=%d\n",i);
            i=j/a;
            printf("j/a=%d\n",i);
        }
        else{
            printf("j<a\n");
        }
    }

    return 0;
}
