#!/usr/bin/perl
use strict;
# use module
use XML::Simple;
use Data::Dumper;

# create object
my $xml = new XML::Simple;

my $file = 'en_product1.xml';

# read XML file
my $data = $xml->XMLin($file);

# print output
#print Dumper($data);
my %count;
my %disorders1 = %{ $data->{DisorderList}->{Disorder} };
my %xreferences;

print Dumper ($data->{DisorderList}->{Disorder}->{ExternalReferenceList});

for my $key (keys %disorders1) {
  my @xrefs;
  $count{$key} = $disorders1{$key}->{ExternalReferenceList}->{count};
  if ($disorders1{$key}->{ExternalReferenceList}->{ExternalReference}->{Source} eq 'ICD-10') {
    print $disorders1{$key}->{OrphaNumber}, ":",  $disorders1{$key}->{Name}->{content}, ":";
    print $disorders1{$key}->{ExternalReferenceList}->{ExternalReference}->{Source}, ":";
    print $disorders1{$key}->{ExternalReferenceList}->{ExternalReference}->{Reference}, ":";
    print $disorders1{$key}->{ExternalReferenceList}->{ExternalReference}->{DisorderMappingRelation}->{Name}->{content}, "\n";
  }
#  print $count{$key}, "\n";
  # if the count is more than 1 create a hash
  if ($count{$key} > 1) {
    my %xref = %{ $disorders1{$key}->{ExternalReferenceList}->{ExternalReference} };
    for my $xref_key (keys %xref) {
      push (@xrefs, ($xref{$xref_key}->{Reference}));
    }
    $xreferences{$disorders1{$key}->{Name}->{content}} = [@xrefs];
  } #else {
    #$hpo_terms{$disorders1{$key}->{Name}->{content}} = $disorders1{$key}->{HPODisorderAssociationList}->{HPODisorderAssociation}->{HPO}->{HPOTerm};
    #$hpo_freqs{$disorders1{$key}->{Name}->{content}}{$disorders1{$key}->{HPODisorderAssociationList}->{HPODisorderAssociation}->{HPO}->{HPOTerm}} = $disorders1{$key}->{HPODisorderAssociationList}->{HPODisorderAssociation}->{HPOFrequency}->{Name}->{content};
    #push (@all_hpo_terms, ($disorders1{$key}->{HPODisorderAssociationList}->{HPODisorderAssociation}->{HPO}->{HPOTerm}));
  #}
}
#print $data->{DisorderList}->{Disorder}->{OrphaNumber}, "\t", 
#      $data->{DisorderList}->{Disorder}->{Name}->{content}, "\t",
#      $data->{DisorderList}->{Disorder}->{ClassificationNodeList}->{ClassificationNode}->{ClassificationNodeChildList}->{ClassificationNode}->{Disorder}->{OrphaNumber}, "\n";

#print Dumper($data->{DisorderList}->{Disorder}->{ClassificationNodeList}->{ClassificationNode}->{ClassificationNodeChildList}->{ClassificationNode})
#print Dumper ($data->{DisorderList}->{Disorder}->{Name});
#print Dumper ($data->{DisorderList}->{Disorder}->{ClassificationNodeList});
