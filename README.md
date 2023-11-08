# geck (WIP)
minimal 16-bit x86 assembler  
  
### HOW MINIMAL?
the only external functions required to link the code are functions to input and output a single byte (getchar and putchar)  
[src/stdio.asm](https://github.com/barborik/geck/src/stdio.asm) defines _getchar and _putchar, which are just wrappers for the standard C getchar and putchar functions  
this can be rewritten when porting to obscure places, like x86 real mode, to read directly from memory or something  
  
### INTERNAL CALLING CONVENTION
return value - ax  
call arguments - stack, every argument is 2 bytes in size  
  
- caller pushes to the stack  
- callee is responsible for popping it  
- arguments get pushed from last to first  
  
### SYNTAX
hybrid Intel and AT&T syntax
you scream at the assembler, so the source is strictly in ALL CAPS!!!    
```
MOV (%BX), $2  
```
