
use NativeCall;


class line is repr('CStruct') {
  has int8 $.elems;
  has CArray[Str] $.array;
};

sub file_handle(Str $path) returns OpaquePointer is native('csv-parser.so') { * }
sub get_line(OpaquePointer $fh, CArray[uint8], int16, CArray[int16], int16) returns line is native('csv-parser.so') { * }

class CSV::Parser::NC {
  has OpaquePointer $!fh;
  has Str $.line_separator  = "\n";
  has Str $.escape_operator = '\\';

  method open-file(Str $path) {
    die 'File doesnt exist' if $path.IO !~~ :f; 
    $self::fh = file_handle($path);
  }

  method get_line {
    my $ls = CArray[int16].new;
    my $eo = CArray[int16].new;
    my @s  = $.line_separator.split('');
    my $ll = @s.elems;
    $ls[$_] = @s[$_].ord for ^$ll-1;
    @s = $.escape_operator.split('');
    my $el = @s.elems;
    $eo[$_] = @s[$_].ord for ^$el-1; 
    my line $a := get_line($self::fh, $ls, $ll, $eo, $el);
    $a.elems.say;
    for 0 .. $a.elems-1 {
      print "$_: ";
      $a.array[$_].say;
    }
  }
}
