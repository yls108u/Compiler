#include <stdio.h>
#include <stdlib.h>

int main(){

    int a=0;
    int b=0;
    int c=0;
    int j=0;

    printf("enter 3 different numbers for a b c:\n");
    scanf("%d %d %d",&a,&b,&c);

    if(a>b){
        if(a>c){
            printf("a is the largest\n");
        }
        else{
            printf("c is the largest\n");
        }
    }
    else{
        if(b>c){
            printf("b is the largest\n");
        }
        else{
            printf("c is the largest\n");
        }
    }
  
    return 0;
}
