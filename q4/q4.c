#include<stdio.h>
#include<stdlib.h>
#include<dlfcn.h>

int main(){
    char op[6];
    int a,b;
    char lib_path[32];

    while(1){
        int check=scanf("%5s %d %d",op,&a,&b);
        if(check!=3){
            break;
        }

        snprintf(lib_path,sizeof(lib_path),"./lib%s.so",op);

        void *handle=dlopen(lib_path,RTLD_LAZY);
        if(handle==NULL){
            printf("Error\n");
            continue;
        }

        int (*func)(int,int)=dlsym(handle,op);
        if(func==NULL){
            printf("Error\n");
            dlclose(handle);
            continue;
        }
        int res=func(a,b);
        printf("%d\n",res);
        dlclose(handle);
    }

    return 0;
}