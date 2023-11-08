/*

simple tool for generating instruction and
identifier hashes for internal use in geck

algorithm by Dan Bernstein (djb)

USAGE:
$ echo "IDENT" | ./hash

*/

#include <stdio.h>
#include <stdint.h>

int main(void)
{
    int c;
    uint16_t hash = 5381;

    while ((c = getchar()) != '\n')
    {
        hash += hash << 5;
        hash ^= c;
    }

    printf("0x%X\n", hash);

    return 0;
}
