#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<ctype.h>

//very very simple BST
/*just for TTTTTTTTest*/

struct BST
{
    char dataword[128];
    int wordcnt;
    struct BST *l_child;
    struct BST *r_child;
};

struct BST *BST_array[1024];
int leafcnt=0;

struct BST *BST_insert(struct BST *T,char *word)
{
    if(T==NULL)
    {
        struct BST *p=malloc(sizeof(struct BST));
        strcpy(p->dataword,word);
        p->wordcnt=1;
        p->l_child=NULL;
        p->r_child=NULL;
        return p;
    }
    if(strcmp(T->dataword,word)>0)
    {
        T->l_child = BST_insert(T->l_child,word);
    }
    else if(strcmp(T->dataword,word)<0)
    {
        T->r_child = BST_insert(T->r_child,word);
    }
    return T;
}

struct BST *find(struct BST *T,char *word,int plus,int minus)
{
    if(T==NULL)
    {
        return NULL;
    }
    if(strcmp(T->dataword,word)>0)
    {
        return find(T->l_child,word,plus,minus);
    }
    else if(strcmp(T->dataword,word)<0)
    {
        return find(T->r_child,word,plus,minus);
    }
    else
    {
        if(plus==1)
        {
            T->wordcnt=T->wordcnt+1;
        }
        if(minus==1)
        {
            T->wordcnt=T->wordcnt-1;
        }
        return T;
    }
}

void inorder_traversal(struct BST *T)
{
    if(T==NULL)
    {
        return ;
    }
    inorder_traversal(T->l_child);
    printf("%d %s\n",T->wordcnt,T->dataword);
    BST_array[leafcnt]=T;
    leafcnt++;
    inorder_traversal(T->r_child);
    return ;
}

int cmp(const void *a,const void *b)
{
    struct BST **x = (struct BST **)a;
    struct BST **y = (struct BST **)b;
    return (*y)->wordcnt-(*x)->wordcnt;
}

void freemytree(struct BST *T)
{
    if(T==NULL)
    {
        return ;
    }
    freemytree(T->l_child);
    freemytree(T->r_child);
    free(T);
    return ;
}

int main()
{
    int i=0;
    int plus=0,minus=0;
    char line[128];
    char word[128];
    char ch='\n';
    char *ptr;
    struct BST *T=NULL;

    plus=0;
    minus=0;
    leafcnt=0;

    while(fgets(line,128,stdin)!=NULL) //要在終端機執行請輸入字串後按ctrl+d
    {
        if(line[0]=='-')
        {
            ptr=line+1;
            strcpy(word,ptr);
            if((ptr=strchr(word,ch))!=NULL)
            {
                *ptr='\0';
            }
            minus=1;
            find(T,word,plus,minus);
            minus=0;
        }
        else
        {
            ptr=line;
            i=0;
            strcpy(word,line);
            if((ptr=strchr(word,ch))!=NULL)
            {
                *ptr='\0';
            }
            if(find(T,word,plus,minus)==NULL)
            {
                T=BST_insert(T,word);
            }
            else
            {
                plus=1;
                find(T,word,plus,minus);
                plus=0;
            }
        }
    }

    printf("Inorder traversal:\n");
    inorder_traversal(T);

    printf("\n");

    printf("Count sorting:\n");
    qsort(BST_array,leafcnt,sizeof(struct BST*),cmp);
    for(i=0;i<leafcnt;i++)
    {
        printf("%d %s\n",(*BST_array[i]).wordcnt,(*BST_array[i]).dataword);
    }

    freemytree(T);

    return 0;
}