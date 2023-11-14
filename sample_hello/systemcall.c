

#include <sys/types.h>
#include <sys/stat.h>
#include <stdlib.h>
#include "mfp.h"

void serial_putc(char c){
    while( !(MFP_REG_TSR & 0x80) ) ;

    MFP_REG_UDR = c;
}

char serial_getc(void){
    char c;
    
    while( !(MFP_REG_RSR & 0x80) ) ;
    c = MFP_REG_UDR;

	return c;
}

int isUSARTDataAvailable(void){
    return (MFP_REG_RSR & 0x80);
}


/*
Part of following code is based on 
https://natsu-no-omoide.hatenablog.jp/entry/2020/07/25/150800
*/

double __trunctfdf2( long double A );
caddr_t _sbrk(int incr);
int _close(void *reent, int fd);
int _fstat(int fd, struct stat *pstat);
off_t _lseek(void *reent, int fd, off_t pos, int whence);
int _read(int file, char* ptr, int len);
int _write(int file, char* ptr, int len);
void _exit(int code);
int _getpid(void);
int _isatty(int file);
void _kill(int pid, int sig);

caddr_t sbrk(int incr) 
{
    static char sbrk_buf[10000];
    static int heap_end;
    int prev_heap_end;

    if (heap_end == 0) 
    {
        heap_end = 0;
    }

    prev_heap_end = heap_end;

    if (heap_end + incr > sizeof(sbrk_buf)) 
    {
        _write (1, "Heap and stack collision\n", 25);
        abort();
    }

    heap_end += incr;

    return (caddr_t) &sbrk_buf[prev_heap_end];
}

int close(void *reent, int fd)
{
    return ( 0 );
}

int fstat(int fd, struct stat *pstat)
{
    pstat->st_mode = S_IFCHR;
    return ( 0 );
}

off_t a;
off_t lseek(void *reent, int fd, off_t pos, int whence)
{
    return (a);
}

int read(int file, char* ptr, int len)
{
    int r;
    char c;
    for ( r =0; r < len; r++ ) 
    {
        c = serial_getc();
        if(file == 0){
            if( c == '\r' ){
                serial_putc('\r');
                serial_putc('\n');
            }else if( c == '\b' ){
                serial_putc('\b');
                serial_putc(' ');
                serial_putc('\b');
            }else{
                serial_putc(c);
            }
        }
        if(c=='\r'){
            ptr[r] = '\n';
        }else if(c=='\b'){
            r -= 1;
        }else{
            ptr[r] = c;
        }
        if( c == '\r' || c == '\n' ) return r+1;
//        printf("read '%c'\n",c);
    }
    return len ;
}

int write(int file, char* ptr, int len)
{
    int r;
    for ( r =0; r < len; r++)
    {
        if(file < 3 && ptr[r] == '\n'){
            serial_putc('\r');
        }
        serial_putc(ptr[r]);
    }
    return len ;
}


int _write(int file, char* ptr, int len)
{
    int r;
    for ( r =0; r < len; r++)
    {
        if(file < 3 && ptr[r] == '\n'){
            serial_putc('\r');
        }
        serial_putc(ptr[r]);
    }
    return len ;
}

void _exit(int code)
{
    while(1);
    return;
}

int getpid(void)
{
    return ( -1 );
} 

int isatty(int file)
{
    return ( -1 );
}

void kill(int pid, int sig)
{
    return;
}

