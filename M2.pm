use strict;
use warnings;

package M2;
our $VERSION= "1.2";  # set in text format, not v-string.
use vars qw/ $ztesch /;
use Exporter::VA ':normal',
 {
 '.plain' => [ qw/ foo &baz $ztesch :tag1/],
 ':tag1' => [ qw/ quux bazola thud &grunt/],
 '&bazola' => \\&baz,
 'thud' => \\&baz,
 'grunt' => \\&baz,
 '.&begin' => sub { print "called .&begin\n"; },
 '.&end' => sub { print "called .&end\n"; },
 } ;

sub foo
 {
 return "Called " . __PACKAGE__ . "::foo (@_).";
 }

sub internal_bar
 {
 return "Called " .  __PACKAGE__ . "::internal_bar (@_).";
 }

sub baz
 {
 return "Called " .  __PACKAGE__ . "::baz (@_)."; 
 }

sub quux
 {
 return "Called " .  __PACKAGE__ . "::quux (@_)."; 
 }

print "module M2 loaded\n";
1;

