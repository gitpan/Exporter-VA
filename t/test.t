use strict;
use warnings;
use Getopt::Long;
use File::Spec;

use constant TEST_COUNT => 28;  # number printed in expect line of test harness output.
our ($quiet, $verbose);
my $failcount;


BEGIN {
   chdir 't' if -d 't';
   GetOptions ('quiet' => \$quiet, 'verbose' => \$verbose) or die "bad options\n";
   unless ($verbose) {
      # silence the --verbose and --dump stuff
      open (my $f, '>', File::Spec->devnull());
      require Exporter::VA;
      *Exporter::VA::VERBOSE= $f;
      }
   print "1..", TEST_COUNT, "\n" unless ($quiet);  # format used by Test::Harness.
   }

sub verify
 {
 my ($code, $answer)= @_;
 my $result= eval ($code);
 if ($@) {
    print "Error calling { $code }, produces $@";
    }
 else {
    if ($result eq $answer) {
       print "ok # calling { $code } => $result\n"  unless $quiet;
       }
    else {
       print "not ok # calling { $code }, returns \"$result\",  expected \"$answer\"\n";
       ++$failcount;
       }
    }
 }


## Test basic export features.
package C1;
use M1 v1.0 qw/--verbose_import &foo bar baz quux bazola $ztesch --dump/;
sub verify;
*verify= \&main::verify;
verify "C1::foo (5)", "Called M1::foo (5).";
verify "C1::bar (6)", "Called M1::internal_bar (6).";
verify "C1::baz (7)", "Called M1::baz (7).";
verify "C1::quux (8)", "Called M1::quux (8).";
verify "C1::bazola (9)", "Called dynamically-generated M1::&bazola asked for by C1, with parameters (9).";
verify '$C1::ztesch=10; ++$M1::ztesch; $C1::ztesch == 11', "1";


## Test .plain and tags
package C2;
use M2 v1.0 qw/ foo baz $ztesch :tag1/;
sub verify;
*verify= \&main::verify;
verify "C2::foo (12)", "Called M2::foo (12).";
verify "C2::baz (13)", "Called M2::baz (13).";
verify '$C2::ztesch=14; ++$M2::ztesch; $C2::ztesch == 15', "1";
verify "C2::quux (16)", "Called M2::quux (16).";
verify "C2::bazola (17)", "Called M2::baz (17).";
verify "C2::thud (18)", "Called M2::baz (18).";
verify "C2::grunt (19)", "Called M2::baz (19).";


## Test version-list exports
package C3;
use M3 qw/--verbose_import foo :blarg/;
sub verify;
*verify= \&main::verify;
verify "C3::foo (20)", "Called M3::old_foo (20).";
verify "C3::bar (22)", "Called M3::bar (22).";


## Make sure different clients can use different versions
package C4;
use M3 v2.1 qw/:tag/;  # more levels of indirection
sub verify;
*verify= \&main::verify;
verify "C4::foo (21)", "Called M3::new_foo (21).";
package C5;
use M3 v1.5.1 qw/foo/;
sub verify;
*verify= \&main::verify;
verify "C5::foo (23)", "Called M3::middle_foo (23).";


## Make sure we use a :DEFAULT.
package C6;
use M2;
sub verify;
*verify= \&main::verify;
verify "C6::foo (24)", "Called M2::foo (24).";
verify "C6::thud (25)", "Called M2::baz (25).";


## Pragma names may be non-identifiers
# (also tests pragma extracting arguments)
# (also tests that return value from callback is ignored if symbol begins with dash)
package C7;
our $output;
use M2 'foo', '-pra#ma!', \$output, 'baz';
sub verify;
*verify= \&main::verify;
verify "C7::foo (26)", "Called M2::foo (26).";
verify "C7::baz (27)", "Called M2::baz (27).";
verify "\$C7::output",  "-pra#ma!";

# check the behavior of normalize_vstring
use Exporter::VA 'normalize_vstring';
sub vv
 {
 my ($x, $answer)= @_;
 my $result= normalize_vstring ($x);
 if ($result eq $answer) {
    printf "ok # normalizing %vd => %vd\n", $x, $result  unless $quiet;
    }
 else {
    printf "not ok # normalizing %vd, returns \"%vd\",  expected \"%vd\"\n", $x, $result, $answer;
    ++$failcount;
    }
 }
 
vv (v1.2.3, v1.2.3);
vv ('', v0);
vv (v3.2.1.0, v3.2.1);
vv (v1.0.0.0, v1.0);
vv (2.3, v2.3);
vv ('2.3.4', v2.3.4);

# check floating-point version specifier on use line
package C8;
use M3 2.4;
# >> if it worked, it took 2.4 as v2.4, not v50.46.52 or v2.400.
# >> later, check my client desired version.  How can I do that from "outside"?
# >> well, have M3 export a function that I can use to ask from the "inside".

####### summary report ######
print '-'x40, "\n"  unless $quiet;
if ($failcount) {
   print "* FAILED $failcount tests!!\n";
   exit 5;
   }
else {
   print "PASSED all tests.\n";
   exit 0;
   }

