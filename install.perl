# installer for Exporter::VA.
# All it does is copy the file to sitelib location.

require 5.6.1;
use strict;
use warnings;
use Config;
use File::Path;  #create directory tree
use File::Spec;  #concat name parts with system-specific delimiters
use File::Copy;

# where am I copying TO?
my $sitelib= $Config{installsitelib};
my $install_location= File::Spec->catdir ($sitelib, 'Exporter');
unless (-d $install_location) {
   my $count= mkpath ($install_location);
   die "Error creating path $install_location\n"  unless $count == 1;
   }
my $dest= File::Spec->catfile ($install_location, 'VA.pm');

# where am I running FROM?
my ($volume,$directories,$file) = File::Spec->splitpath($0);
my $source= File::Spec->catpath ($volume, $directories, 'Exporter-VA.pm');

# OK, do what I came here for.
# >> could check versions here.

# move any old copy to a temp file in case I need to roll it back.
my $have_old= -e $dest;
my $tempfile = $dest . ".BACKUP";
if ($have_old) {
   move ($dest, $tempfile)  or die qq(Could not move "$dest" to "$tempfile");
   }
copy ($source, $dest)  or die qq(Could not copy "$source" to "$dest"\n);
# test, then clean up.
if (test_module()) {
   # all went well so get rid of the backup.
   print "OK.\n";
   unlink $tempfile;
   }
else {
   # problem, so roll back
   print "Module test failed! ";
   if ($have_old) {
      print "restoring old file.\n";
      move ($tempfile, $dest)  or die qq(Problem restoring old file!! Could not move "$tempfile" back to "$dest");
      }
   else {
      print "deleting installed file.\n";
      unlink $dest;
      }
   }

### end of main code.

sub test_module
 {
 my $testprog= "test1.perl";
 print "Testing the module...\n";
 my $retcode= system ($^X, $testprog, "--quiet");
 return $retcode == 0;
 }

