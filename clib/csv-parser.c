#include <stdlib.h>
#include <stdio.h>
#include "csv-parser.h"

FILE* file_handle(char* path) {
  printf("Opening %s\n", path);
  return fopen(path, "rb");
}

line* get_line(FILE* fh, int* end, int end_l, int* esc, int esc_l, int* quo, int quo_l) {
  line *s = malloc(sizeof(line));
  s->elems = 1;
  s->fields = malloc(s->elems * (sizeof(char*)));
  char* toparse = malloc(128*sizeof(char)), *tmp = NULL;
  char buf;
  size_t line_len = 128, index = 0;
  int keepgoing = 1, inquote = 0;
  while (!feof(fh) && keepgoing) {
    line_len++;
    buf = fgetc(fh);
    if(line_len < index){
      line_len += 128;
      tmp = realloc(toparse, line_len);
      toparse = tmp;
    }
    toparse[index] = buf;
    if(detect_quote(toparse, index, esc, esc_l, quo, quo_l)){
      if(inquote){
        inquote = 0;
      }else{
        inquote = 1;
      }
    }
    if(!inquote && detect_end_line(toparse, index, end, end_l)){ 
      keepgoing = 0; 
    }
    index++;
  }

  s->fields[0] = toparse; 
  return s;
}

int detect_quote(char* buffer, int buffer_i, int* esc, int esc_l, int* quo, int quo_l){
  return 0;
}

int detect_end_line(char* buffer, int buffer_i, int* end, int end_l){
  int i, i2, m;
  if(buffer_i < end_l){
    return 0;
  }
  i = 0; //index in buffer
  m = 1; //is a match
  for(i = buffer_i; i > 0 && m == 1 && end_l - 1 - (buffer_i - i) >= 0; i--){
    if(buffer[i] != end[end_l - (buffer_i - i) - 1]){
      return 0;
    }
  }
  return m;
}
