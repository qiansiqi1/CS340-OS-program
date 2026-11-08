/* Intentional heap boundary accesses for the ASan redzone experiment. */
#include <errno.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s SIZE left|right|underflow|overflow\n", argv[0]);
        return 2;
    }

    char *end = NULL;
    errno = 0;
    unsigned long parsed = strtoul(argv[1], &end, 10);
    if (errno != 0 || *argv[1] == '\0' || *end != '\0' || parsed < 1 || parsed > 64) {
        fputs("SIZE must be an integer from 1 to 64\n", stderr);
        return 2;
    }

    const size_t size = (size_t)parsed;
    const char *mode = argv[2];
    if (strcmp(mode, "left") != 0 && strcmp(mode, "right") != 0 &&
        strcmp(mode, "underflow") != 0 && strcmp(mode, "overflow") != 0) {
        fputs("Invalid mode\n", stderr);
        return 2;
    }

    volatile unsigned char *buffer = malloc(size);
    if (buffer == NULL) {
        fputs("Allocation failed\n", stderr);
        return 2;
    }

    const ptrdiff_t index = strcmp(mode, "left") == 0 ? 0 :
                            strcmp(mode, "right") == 0 ? (ptrdiff_t)size - 1 :
                            strcmp(mode, "overflow") == 0 ? (ptrdiff_t)size : -1;
    buffer[index] = 42;
    printf("Completed %s write (allocation: %zu bytes)\n", mode, size);
    free((void *)buffer);
    return 0;
}
