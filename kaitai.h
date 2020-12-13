#ifndef __KAITAI_H
#define __KAITAI_H

#ifndef WIN32
typedef char CHAR;
typedef CHAR *PCHAR;
typedef const PCHAR LPCSTR;
typedef unsigned long ULONG;
typedef void VOID;
typedef VOID *PVOID;
typedef int BOOL;
#define CALLBACK
#endif

enum {
    KAITAI_FLAG_DEFAULT,
    KAITAI_FLAG_EXPANDARRAYS = 1 << 0,
    KAITAI_FLAG_PROCESSZLIB = 1 << 1,
};

// Convenience macro to load a binary into duktape.
#define DUK_LOAD_BINOBJ(ctx, name) do {                                 \
    extern unsigned char name ## _js[];                              \
    extern unsigned int  name ## _js_len;                             \
    duk_peval_lstring_noresult(ctx,                                     \
                               name ## _js,                          \
                               (ULONG) name ## _js_len);             \
    } while (false)

typedef struct _KAITAI_PARSER {
     LPCSTR Name;
     PCHAR Start;
     unsigned int *Size;
} KAITAI_PARSER, *PKAITAI_PARSER;

typedef VOID (CALLBACK *PFIELD_CALLBACK)(PVOID UserPtr, LPCSTR Name, ULONG Start, ULONG End);
typedef VOID (CALLBACK *PERROR_CALLBACK)(PVOID UserPtr, LPCSTR ErrorString);

BOOL KaitaiQueryFormat(PKAITAI_PARSER Format,
                       ULONG Flags,
                       PVOID Buffer,
                       ULONG BufSize,
                       PFIELD_CALLBACK FieldCallback,
                       PERROR_CALLBACK ErrorCallback,
                       PVOID UserPtr);

#endif
