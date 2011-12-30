#!/usr/bin/env perl

use lib 'lib';

use Net::OneTimeSecret;
use utf8;

use common::sense;
use Test::More tests => 10;

my $customerId  = 'apitest-perl@onetimesecret.com';
my $testApiKey  = 'df0de769899e5464cb70754ea4494aec1b7de7fb';

my $api = Net::OneTimeSecret->new( $customerId, $testApiKey );

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


# Let's try some unicode
my $unicode = $api->shareSecret( "˙sʃǝǝ ɟo ʃʃnɟ sı ʇɟɐɹɔɹǝʌoɥ ʎW" );
ok( $unicode && $unicode->{created}, "Created shared secret from unicode.");

my $ru = $api->retrieveSecret( $unicode->{secret_key} );
ok( $ru && $ru->{value} eq "˙sʃǝǝ ɟo ʃʃnɟ sı ʇɟɐɹɔɹǝʌoɥ ʎW", "Retrieved unicode secret." );
#diag Dumper($ru);

$ru = $api->retrieveSecret( $unicode->{secret_key} );
ok( $ru && $ru->{message} eq "Unknown secret", "Couldn't retrieve secret twice." );