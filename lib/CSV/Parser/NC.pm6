
use NativeCall;


class line is repr('CStruct') {
  has int8 $.elems;
  has CArray[Str] $.array;
};

sub file_handle(Str $path) returns OpaquePointer is native('csv-parser.so') { * }
sub get_line(OpaquePointer $fh, CArray[int16], int16, CArray[int16], int16, CArray[int16], int16, CArray[int16], int16) returns line is native('csv-parser.so') { * }

class CSV::Parser::NC {
  has OpaquePointer $!fh;
  has Str $.line_separator  = "\n";
  has Str $.escape_operator = '\\';
  has Str $.field_operator  = '"';
  has Str $.field_separator = ',';
  has Bool $.contains_header_row = False;
  has Str %.headers;

  has $.ls is rw;
  has $.eo is rw;
  has $.fo is rw;
  has $.fs is rw;
  has $.ll is rw;
  has $.el is rw;
  has $.fl is rw;
  has $.sl is rw;

  method !builds {
    return if defined $.ls;
    my @s;
    $.ls = CArray[int16].new;
    $.eo = CArray[int16].new;
    $.fo = CArray[int16].new;
    $.fs = CArray[int16].new;
    @s  = $.line_separator.split('');
    $.ll = @s.elems;
    $.ls[$_] = @s[$_].ord for ^$.ll-1;
    @s = $.escape_operator.split('');
    $.el = @s.elems;
    $.eo[$_] = @s[$_].ord for ^$.el-1; 
    @s = $.field_operator.split('');
    $.fl = @s.elems;
    $.fo[$_] = @s[$_].ord for ^$.fl-1; 
    @s = $.field_separator.split('');
    $.sl = @s.elems;
    $.fs[$_] = @s[$_].ord for ^$.sl-1;
  }

  method open-file(Str $path) {
    die 'File doesnt exist' if $path.IO !~~ :f; 
    $self::fh = file_handle($path);
  }

  method get_line {
    self!builds;
    if $.contains_header_row {
      $.contains_header_row = False;
      my line $h = get_line($self::fh, $.ls, $.ll, $.eo, $.el, $.fo, $.fl, $.fs, $.sl);
      for 0 .. $h.elems-1 {
        %!headers{$_} = $h.fields[$_];
      }
    }
    return get_line($self::fh, $.ls, $.ll, $.eo, $.el, $.fo, $.fl, $.fs, $.sl);
  }
}
