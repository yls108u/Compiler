#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>

void my_switch(int option)
{
    option=option%10;
    switch(option){
        case 1:
            break;
        case 2:
            break;
        default:
            option = ~option;
            option = 10;
            option--;
            option = option>>2;
            option = option<<2;
            option = option/10;
    }
    return ;
}

int read_data(int *ptr, int cnt)
{
    int *qtr = ptr;
    for (int i = 0; i < cnt; i++)
    {
        scanf("%d", &*qtr);
        qtr++;
    }
    *qtr = '\0';
    return 0;
}

int main(void)
{
    //宣告
    int node_cnt;
    int root;
    int *original_parent;
    int *finial_parent;

    /*讀取資料*/
    scanf("%d", &node_cnt);
    original_parent = malloc(sizeof(int) * (node_cnt + 1));
    finial_parent = malloc(sizeof(int) * (node_cnt + 1));

    for(int i=1;i<=1000;i++){
        if(i%20==0) my_switch(i);
        else if(i%1000==0) {
            read_data(original_parent, node_cnt);
            read_data(finial_parent, node_cnt);
        }
    }

    /*
    釋放記憶體空間
    */
    free(original_parent);\
    free(finial_parent);\

    printf("ENNNNNNNNNNN\n");

    return 0;
}
