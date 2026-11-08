/* Original course-project smoke test; not code from the ASan paper. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
    if (argc != 2 ||
        (strcmp(argv[1], "safe") != 0 && strcmp(argv[1], "overflow") != 0)) {
        fprintf(stderr, "Usage: %s safe|overflow\n", argv[0]);
        return 2;
    }

    const size_t size = 8;
    const size_t index = strcmp(argv[1], "safe") == 0 ? size - 1 : size;
    /* volatile keeps the intentional write observable under optimization. */
    volatile unsigned char *buffer = malloc(size);
    if (buffer == NULL) {
        fputs("Allocation failed\n", stderr);
        return 2;
    }

    buffer[index] = 42;
    printf("Completed write at index %zu (allocation: %zu bytes)\n", index, size);
    free((void *)buffer);
    return 0;
}
