/*----------------------------------------------------------------------*/
/* Foolproof FatFs sample project for AVR              (C)ChaN, 2013    */
/*----------------------------------------------------------------------*/

typedef unsigned int  uint32_t;  
typedef signed   int   int32_t; 
typedef unsigned short  uint16_t;  
typedef signed   short   int16_t; 
typedef unsigned char  uint8_t;
typedef signed char   int8_t; 
typedef unsigned char byte;


typedef struct uart{
unsigned int dr;
unsigned int sr;
unsigned int ack;
} UART;


UART* uart1 = (UART*)(0x20000000);

void putcmon(unsigned char c)
{
    uart1->dr = c;
}


int main (void)
{
	putcmon('A');
}


