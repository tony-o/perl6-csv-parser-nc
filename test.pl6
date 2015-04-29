#!/usr/bin/env perl6

use lib 'lib';
use CSV::Parser::NC;

my CSV::Parser::NC $nc .= new;

$nc.open-file('t/data/escaped.csv');
$nc.get_line.say;
