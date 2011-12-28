#!/usr/bin/env perl

use OneTimeSecret;

use common::sense;
use Test::More tests => 7;


my $customerId  = 'apitest-perl@onetimesecret.com';
my $testApiKey  = 'df0de769899e5464cb70754ea4494aec1b7de7fb';

my $api = OneTimeSecret->new( $customerId, $testApiKey );

my $response = $api->shareSecret("My hovercraft is full of eels.");
ok( $response && $response->{created}, "Created new secret" );

my $secretKey = $response->{secret_key};
my $metadataKey = $response->{metadata_key};
ok( $secretKey && $metadataKey, "Retrieved keys for new secret" );

# status
my $status = $api->status();
ok( $status && $status->{status} eq 'nominal', "Status OK" );

# generate
my $gen = $api->generateSecret();
ok( $gen && $gen->{value}, "Generated secret" );

my $retrieved = $api->retrieveSecret( $secretKey );
ok( $retrieved && $retrieved->{value} eq "My hovercraft is full of eels.", "Secret retrieved successfully" );

my $retrievedAgain = $api->retrieveSecret( $secretKey );
ok( !exists $retrievedAgain->{value} && $retrievedAgain->{message} eq "Unknown secret", "Unable to retrieve message twice" );

my $metadata = $api->retrieveMetadata( $metadataKey );
ok( $metadata && $metadata->{created}, "Metadata retrieved" );