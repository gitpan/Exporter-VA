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
copy ($source, $dest)  or die qq(Could not copy "$source" to "$dest"\n);

print "OK.\n";

