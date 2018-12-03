use strict;
#use warnings;
use Data::Dumper;
use XML::Simple;

# create object
my $xml = new XML::Simple;

my $orpha_file = 'en_product1.xml';

# read XML file
my $data = $xml->XMLin($orpha_file);

#print Dumper($data);

my %disorders1 = %{ $data->{DisorderList}->{Disorder} };
#my %orpha_num;
#my %orpha_name;
#my %mapping_code;
my %count;
my %icd10_orpha_mapping;

#print Dumper ($data->{DisorderList}->{Disorder});#->{ExternalReferenceList});
for my $key (keys %disorders1) {
  #my @orpha_codes;
  $count{$key} = $disorders1{$key}->{ExternalReferenceList}->{count};
  my $orpha_combo = $disorders1{$key}->{OrphaNumber} . " " . $disorders1{$key}->{Name}->{content};
  if ($count{$key} > 1) {
    my %xrefs = %{ $disorders1{$key}->{ExternalReferenceList}->{ExternalReference} };
    for my $xref_key (keys %xrefs) {
      if ($xrefs{$xref_key}->{Source} eq 'ICD-10') {
        my $icd_num = $xrefs{$xref_key}->{Reference};
        $icd_num =~ s/\.//g;
        #$orpha_num {$icd_num} = $disorders1{$key}->{OrphaNumber};
        #$orpha_name {$icd_num} = $disorders1{$key}->{Name}->{content};
        #$mapping_code {$icd_num} = $disorders1{$key}->{ExternalReferenceList}->{ExternalReference}->{DisorderMappingRelation}->{Name}->{content};
        #my $orpha_combo = $disorders1{$key}->{OrphaNumber} . " " . $disorders1{$key}->{Name}->{content};
        #push (@orpha_codes, $orpha_combo);
        if (exists $icd10_orpha_mapping {$icd_num}) {
          my $old_icd10_orpha = $icd10_orpha_mapping {$icd_num};
          $icd10_orpha_mapping {$icd_num} = $old_icd10_orpha . "; " . $orpha_combo;
        } else {
          $icd10_orpha_mapping {$icd_num} = $orpha_combo;
        }
      }
    }
  } elsif ($count{$key} == 1) {
    if ($disorders1{$key}->{ExternalReferenceList}->{ExternalReference}->{Source} eq 'ICD-10') {
      my $icd_num = $disorders1{$key}->{ExternalReferenceList}->{ExternalReference}->{Reference};
      $icd_num =~ s/\.//g;
      if (exists $icd10_orpha_mapping {$icd_num}) {
        my $old_icd10_orpha = $icd10_orpha_mapping {$icd_num};
        $icd10_orpha_mapping {$icd_num} = $old_icd10_orpha . "; " . $orpha_combo;
      } else {
        $icd10_orpha_mapping {$icd_num} = $orpha_combo;
      }
      #print $disorders1{$key}->{OrphaNumber}, ":", $disorders1{$key}->{ExternalReferenceList}->{ExternalReference}->{Reference}, "\n";
    }
  }
}

print Dumper (\%icd10_orpha_mapping);

#print Dumper (\%orpha_name);

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

my %icd9_icd10_mapping;
my %icd9_orpha_mapping;

while (my $line = <MAPFILE>) {
  my ($icd9, $icd10, $comb) = split (/\s+/, $line);
  # if there's an orpha mapping for the icd10 code then check if there's icd9 mapping
  if (exists $icd10_orpha_mapping {$icd10}) {
    # if there already exists an orpha code for the icd9 code append to it
    if (exists $icd9_orpha_mapping {$icd9}) {
      $icd9_orpha_mapping {$icd9} .= "; " . $icd10_orpha_mapping {$icd10};
    # otherwise if there isn't an orpha code for icd9 then create one
    } else {
      $icd9_orpha_mapping {$icd9} = $icd10_orpha_mapping {$icd10};
    }
  }
  # if there's an icd name for the icd10 code then create the number/name combo
  my $icd10_combo;
  if (exists $icd_name {$icd10}) {
    $icd10_combo = $icd10 . " " . $icd_name {$icd10};
  }
  chomp $comb;
  # if there's already an icd10 mapping for the icd9 code then append
  if (exists $icd9_icd10_mapping {$icd9}) {
    $icd9_icd10_mapping {$icd9} .= "; " . $icd10_combo;
    # if there's already an icd10 mapping for the icd9 then append for the orpha code
#    if (exists $orpha_num {$icd10}) {
#      $orpha_mapping {$icd9} .= "; " . $orpha_mapping {$icd9}
#    }  
  # if there's no icd10 mapping for the icd9 code then create the mapping
  } else {
    $icd9_icd10_mapping {$icd9} = $icd10_combo;
  }
}
close MAPFILE;

#print Dumper (\%orpha_mapping);


my $input = shift;

my $icd_output = 'icd_out_'.$input;
my $orpha_output = 'orpha_out_'.$input;

open (INPUT, $input);
open (ICDOUT, ">$icd_output");
open (ORPHAOUT, ">$orpha_output");

my $dummy=<INPUT>;   #First line is read here
print ICDOUT $dummy;
print ORPHAOUT $dummy;

while (my $line = <INPUT>) {
  chomp $line;
  my @line =  split (/\t/, $line);
#  my ($diag1, $diag2, $diag3, $diag4, $diag5, $proc1) = split (/\t/, $line);

  foreach my $element (@line) {
    if ($element =~ /\s/) {
      $element =~ s/\s.*//;
    }
    if ($icd9_icd10_mapping {$element} ) {
      print ICDOUT $icd9_icd10_mapping {$element};
      #if ($icd_name {$icd9_icd10_mapping {$element}}) {    
      #  print ICDOUT ":", $icd_name {$icd9_icd10_mapping {$element}};
      #}
    } elsif ($element eq '') {
      print ICDOUT $element;
    } else {
      print ICDOUT $element, "_x";
    }
    if ($icd9_orpha_mapping {$element} ) {
      print ORPHAOUT $icd9_orpha_mapping {$element};
      #if ($icd9_orp {$icd9_orpha_mapping {$element}}) {
      #  print ORPHAOUT ":", $orpha_name {$icd9_orpha_mapping {$element}};
      #}
    } elsif ($element eq '') {
      print ORPHAOUT $element;
    } else {
      print ORPHAOUT $element, "_x";
    }
    print ICDOUT "\t";
    print ORPHAOUT "\t";
  }
  print ICDOUT "\n";
  print ORPHAOUT "\n";
}
#print Dumper(\%mapping);

close INPUT;
close ICDOUT;
close ORPHAOUT;
exit;


