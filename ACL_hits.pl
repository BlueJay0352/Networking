#!/usr/bin/perl -w
#
 
#  On the ASA:
#  pager 0
#  sh access-list
#  Dump text to hitcnts.txt file.
 
use strict;
 
# Load ACL hit counts.
open FP, "hitcnts.txt";
        my @hitcnts = <FP>;
close FP;
chomp @hitcnts;
 
# Iterate through each line in the file.
for my $i (0 .. $#hitcnts) {
        if ($hitcnts[$i] =~ m/^access-list [A-Za-z0-9-_]+ line /) {
                # This is an ACL.
 
                if (my ($hits) = $hitcnts[$i] =~ m/hitcnt=(\d+)/) {
                        # ACL only has one ACE - get the hit count.
 
                        if ($hits == 0) {
                                # Zero hits for this ACL.
                                print "Remove ACL ($hits hits): " . $hitcnts[$i] . "\n";
                        } elsif ($hits <= 100) {
                                # Hits <= 100 so should be reviewed.
                                print "Review ACL ($hits total hits): " . $hitcnts[$i] . "\n";
                        }
 
                        # Move on to the next line.
                        next;
                }
 
                # ACL probably has more than one ACE so move to the next line, which should be the
                # first ACE of the ACL.
                $i++;
 
                if ($hitcnts[$i] =~ m/^  access-list /) {
                        # This is an ACE for the ACL.
 
                        my $total_hits = 0;
                        # Iterate through ACEs for the ACL.
                        for my $x ($i .. $#hitcnts) {
                                if ($hitcnts[$x] =~ m/^access-list /) {
                                        # Hit another ACL so all ACEs have been processed.
 
                                        last;
                                }
 
                                # Get hit count for ACE.
                                my ($hits) = $hitcnts[$x] =~ m/hitcnt=(\d+)/;
                                # Total number of hits for the entire ACL.
                                $total_hits += $hits;
                        }
 
                        if ($total_hits == 0) {
                                # No ACE hits so suggestion is that the ACL can be removed.
                                print "Remove ACL ($total_hits hits): " . $hitcnts[$i-1] . "\n";
                        } elsif ($total_hits <= 100) {
                                # Total ACE hits <= 100 so should be reviewed.
                                print "Review ACEs for ACL ($total_hits total hits): " . $hitcnts[$i-1] . "\n";
                        }
                } else {
                        # Rewind.
 
                        $i--;
                }
        }
}
