use strict;
use warnings;

sub verify
 {
 my ($code, $answer)= @_;
 my $result= eval ($code);
 if ($@) {
    print "Error calling { $code }, produces $@";
    }
 else {
    if ($result eq $answer) {
       print "OK calling { $code } => $result\n";
       }
    else {
       print "WRONG calling { $code }, returns \"$result\",  expected \"$answer\"\n";
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
## >>
