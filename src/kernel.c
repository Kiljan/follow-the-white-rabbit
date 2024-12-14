#include "kernel.h"
#include <stddef.h>
#include <stdint.h>

uint16_t* video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

size_t strlen(char*);
void print(char*);
void terminal_writechar(char, char);
void terminal_putchar(int, int, char, char);
uint16_t terminal_make_char(char, char);
void terminal_initialize();


void kernel_main()
{
    terminal_initialize();
    print("Follow the white rabbit\n...");
}

void terminal_initialize()
{
  video_mem = (uint16_t*)(0xB8000);
  terminal_row = 0;
  terminal_col = 0;
  
  for (int y = 0; y < VGA_HEIGHT; y++){
    for (int x = 0; x < VGA_WIDTH; x++){
      terminal_putchar(x, y, ' ', 4);
    }
  }
}

size_t strlen(char* str)
{
   char *len = str;
   while(*len)
     len++;

   return (size_t) len;
}

void print(char* str)
{
  size_t len = strlen(str);
  for (int i = 0; i < len; ++i){
    terminal_writechar(str[i], 4);
  }
}

void terminal_writechar(char c, char colour)
{
  if (c == '\n' || terminal_col >= VGA_WIDTH){
    terminal_row += 1;
    terminal_col = 0;
    return;
  }

  terminal_putchar(terminal_col, terminal_row, c, colour);
  terminal_col += 1;
}

void terminal_putchar(int x, int y, char c, char colour)
{
    video_mem[(y * VGA_WIDTH) + x] = terminal_make_char(c, colour);
}

uint16_t terminal_make_char(char c, char colour)
{
  return (colour << 8) | c;
}


