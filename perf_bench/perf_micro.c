#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

// 参考ASan论文性能测试：大量小内存分配/释放
#define ALLOC_COUNT 1000000
#define BLOCK_SIZE 256

int main(void) {
    void **ptrs = (void**)malloc(sizeof(void*) * ALLOC_COUNT);
    if (!ptrs) {
        fprintf(stderr,"malloc ptrs failed\n");
        return 1;
    }

    // 循环分配
    for (int i = 0; i < ALLOC_COUNT; i++) {
        ptrs[i] = malloc(BLOCK_SIZE);
        if(ptrs[i]==NULL){
            fprintf(stderr,"malloc block fail at %d\n",i);
            return 1;
        }
        // 简单写内存，防止编译器优化消除分配
        uint8_t *p = (uint8_t*)ptrs[i];
        p[0] = (uint8_t)(i & 0xff);
        p[BLOCK_SIZE-1] = (uint8_t)((i>>8)&0xff);
    }

    // 循环释放
    for (int i = 0; i < ALLOC_COUNT; i++) {
        free(ptrs[i]);
    }

    free(ptrs);
    return 0;
}
