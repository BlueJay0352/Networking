#!/usr/bin/perl -w
#
 
use warnings;
use strict;
use autodie;

my @files = glob "Configs/*";


foreach my $file (@files) {

	# Read config from .txt files in Dir.
	open my $fh, $file or die "Can't open '$file': $!";
	my @config = <$fh>;
	close $fh;
	chomp @config;
	
	my $configref = \@config;
	 
	# Open file and retain config name.
	open (my $fp, '>', "$file.UNUSED");
 
		# Extract names from config.
		my @names = map { /^name \d+\.\d+\.\d+\.\d+ ([A-Za-z0-9-_]+)$/ ? $1 : () } @{ $configref };
		# Remove names from config.
		@config = grep { $_ !~ /^name / } @config;
		# Find unused name references.
		foreach my $name (@names) {
		        if (!grep { $_ =~ /$name/ } @config) 
				{
					print $fp "no name $name \n"; 
				}			
		}	
 
		# Extract objects from config.
		my @objects = map { /^(object|object-group) (network|service) ([A-Za-z0-9-_]+)$/ ? $3 : () } @{ $configref };
		# Remove objects from config.
		@config = grep { $_ !~ /^(object|object-group) / } @config;
		# Find unused object references.
		foreach my $object (@objects) { 
		        if (!grep { $_ =~ /$object/ } @config) {
					
				if ($object =~ /PPS/)  {
						print $fp "no object-group service $object \n"; 
				}	
				
				else {
						print $fp "no object-group network $object \n"; 
				     }	 
				}
				
		}			
}



