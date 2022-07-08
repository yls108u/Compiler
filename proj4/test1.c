void main()
{
    int a=10;
    int b=5;

    printf("a=%d b=%d\n",a,b);
    
    a = b * 4;
    b = a - b / 5;

    printf("new a=%d new b=%d\n",a,b);
}