/* csv-parser.h */

typedef struct line_s {
  int elems;
  char **fields;
} line;

FILE* file_handle();
line* get_line(FILE*,int*,int,int*,int,int*,int,int*,int);
unsigned short * reset();
unsigned short * parse(char*);
int detect_end_line(char*,int,int*,int);
int detect_quote(char*,int,int*,int,int*,int);

