#!/usr/bin/perl

use strict;

#print "\n";
#print ";-------------------------------------------------------------------\n";
#print "; Sites blocked due to choosen usage policy\n";
#print ";-------------------------------------------------------------------\n";
#print "\n";

while (<>) {
   if (/^(.*)$/) {
      print "$1\tCNAME *.wall.lan.\n";
      print "*.$1\tCNAME *.wall.lan.\n";
   }
}

