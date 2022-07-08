#include <stdio.h>
#include <stdlib.h>

int main(){

    int a=10;
    int j=1;

    if(a==10){
        a=a+1;
    }

    if(a==10){
        printf("false\n");
    }
    else if(a==11){
        if(j!=0) printf("OK\n");
        printf("test%dand%d\n",1,2);
    }
    else{
        printf("tired\n");
    }
  
    return 0;
}
