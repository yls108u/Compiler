void main()
{
    int a=100;
    int b=999;
    int i=0;
    int j=1;

    printf("Please enter 2 integers for a & j:\n");
    scanf("%d %d", &a, &j);

    printf("a=%d j=%d\n",a,j);

    if(a < 0) {
        printf("a = %d is less than 0\n",a);
    }
    else if(a == 0){
        printf("a = 0\n");
    }
    else {
        printf("a = %d > 0\n",a);

        if(b > a){
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
            printf("b <= a\n");
        }
    }
}
