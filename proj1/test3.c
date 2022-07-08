#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(){

    int num[3]={0};
    int f;

    while(scanf("%d %d %d",&num[0],&num[1],&num[2])!=EOF){
        f=0;
        if(num[0]==num[1]&&num[1]==num[2]){
            printf("%d %d %d a equilateral triangle\n",num[0],num[1],num[2]);
        }
        else{
            for(int i=0;i<3;i++){
                if(i==0){
                    if(num[1]+num[2]<=num[i]||abs(num[1]-num[2])>=num[i]){
                        printf("%d %d %dnot tri\n",num[0],num[1],num[2]);
                        f=1;
                        break;
                    }
                }
                if(i==1){
                    if(num[0]+num[2]<=num[i]||abs(num[0]-num[2])>=num[i]){
                        printf("%d %d %dnot tri\n",num[0],num[1],num[2]);
                        f=1;
                        break;
                    }
                }
                if(i==2){
                    if(num[1]+num[0]<=num[i]||abs(num[1]-num[0])>=num[i]){
                        printf("%d %d %dnot tri\n",num[0],num[1],num[2]);
                        f=1;
                        break;
                    }
                }
            }
            if(f==0){
                printf("%d %d %dnot equilateral triangle\n",num[0],num[1],num[2]);
            }
        }
    }
  
    return 0;
}
