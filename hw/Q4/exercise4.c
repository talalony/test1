#include <stdio.h>
#include <stdlib.h>

int main() {
    printf("\nGreetings, Dorothy!\n");
    printf("The great Wizard has left you a message in a magical text file.\n");
    printf("Gaze upon its contents to uncover its secrets!\n\n");

    printf("\n---------------------------------------\n\n\n");
    
    system("/bin/more magic_file.txt");
    
    return 0;
}
