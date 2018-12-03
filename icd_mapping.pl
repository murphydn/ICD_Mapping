use strict;
use warnings;
use Data::Dumper;

# ICD names file
my $icd_names_file = 'icd10cm_codes_2019.txt';

my %icd_name;
open (ICDFILE, $icd_names_file);

while (my $line = <ICDFILE>) {
  chomp $line;
  # remove hidden carriage returns
  $line =~s/\r//g;
  my ($icd_code, $name) = split (/\s+/, $line, 2);
  $icd_name {$icd_code} = $name;
}
close ICDFILE;


my $map_file = '2018_I9gem.txt';

open (MAPFILE, $map_file);

my %mapping;

while (my $line = <MAPFILE>) {
  my ($icd9, $icd10, $comb) = split (/\s+/, $line);
  if (exists $icd_name {$icd10}) {
    $icd10 = $icd10 . " " .  $icd_name {$icd10};
  }
  chomp $comb;
  if (exists $mapping {$icd9}) {
    $mapping {$icd9} .= "; " . $icd10;
  } else {
    $mapping {$icd9} = $icd10;
  }
}
close MAPFILE;

my $input = shift;

open (INPUT, $input);
my $dummy=<INPUT>;   #First line is read here
print $dummy;
while (my $line = <INPUT>) {
  chomp $line;
  my @line =  split (/\t/, $line);
#  my ($diag1, $diag2, $diag3, $diag4, $diag5, $proc1) = split (/\t/, $line);

  foreach my $element (@line) {
    if ($element =~ /\s/) {
      $element =~ s/\s.*//;
    }
    if ($mapping {$element} ) {
      print $mapping {$element};
      if ($icd_name {$mapping {$element}}) {    
        print ":", $icd_name {$mapping {$element}};
      }
    } elsif ($element eq '') {
      print $element;
    } else {
      print $element, "_x";
    }
    print "\t";
  }
  print "\n";
}
#print Dumper(\%mapping);

close INPUT;
exit;


