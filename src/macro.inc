%macro _param 2
    mov     %1, [rbp + 16 + 2 * %2]
%endmacro

%macro _enter64 0
    push    rbp
    mov     rbp, rsp
%endmacro

%macro _leave64 1
    mov     rsp, rbp
    pop     rbp
    ret     2 * %1
%endmacro

%macro _enter 0
    _enter64
%endmacro

%macro _leave 1
    _leave64 %1
%endmacro
