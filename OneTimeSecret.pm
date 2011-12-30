package OneTimeSecret;

our $VERSION = "0.01";

use common::sense;
use JSON;
use LWP::UserAgent;
use URI::Escape;
use Encode qw( encode_utf8 decode_utf8 );

my $_USER_AGENT  = LWP::UserAgent->new();
my $_API_VERSION = "v1";
my $_BASE_URL    = 'https://%s:%s@onetimesecret.com/api/'.$_API_VERSION;
my $_SECRET_TTL  = 3600;

sub __url_for {
    my ($self, $action, $user, $password) = @_;
    $user     ||= $self->customerId();
    $password ||= $self->apiKey();

    return sprintf(
        $_BASE_URL,
        uri_escape( $user ),
        uri_escape( $password )
    ) . $action;
}

sub new {
    my $class = shift;
    my $customerId = shift;
    my $apiKey = shift;

    my %options = ( @_ );
    my $self = bless {
        _customerId => $customerId,
        _apiKey     => $apiKey,
    }, $class;
    # process other options...
    return $self;
}

sub _post {
    my ($self, $url, $data) = @_;
    $data ||= {};
    foreach my $key (keys %$data) {
        delete $data->{$key} unless defined $data->{$key};
    }
    my $response = $_USER_AGENT->post( $url, 'Content' => $data );
    return from_json( decode_utf8( $response->decoded_content ) );
}

sub _get {
    my ($self, $url) = @_;
    my $response = $_USER_AGENT->get( $url );
    return from_json( $response->decoded_content );
}

sub status {
    my ($self) = @_;
    return $self->_get( $self->__url_for( "/status" ) );
}

sub shareSecret {
    my $self = shift;
    my $secret = shift;
    my $options = { @_ };

    return $self->_post( $self->__url_for( "/share" ), {
        secret => $secret,
        ttl    => $options->{ttl} || $_SECRET_TTL,
        recipient  => $options->{recipient} || undef,
        passphrase => $options->{passphrase} || undef,
    });
}

sub generateSecret {
    my $self = shift;
    my $options = { @_ };

    return $self->_post( $self->__url_for( "/generate" ));
}

sub retrieveSecret {
    my $self = shift;
    my $key = shift;
    my $options = { @_ };
    return $self->_post( $self->__url_for( sprintf("/secret/%s", $key) ) );
}

sub retrieveMetadata {
    my ($self, $key) = @_;
    return $self->_post( $self->__url_for( sprintf("/private/%s", $key) ) );
}

sub customerId    { return $_[0]->{_customerId}  };
sub setCustomerId { $_[0]->{_customerId} = shift };
sub apiKey    { return $_[0]->{_apiKey}  };
sub setApiKey { $_[0]->{_apiKey} = shift };

1;
__END__

=head1 NAME

OneTimeSecret - Perl interface to OneTimeSecret.com API

=head1 SYNOPSIS

 use OneTimeSecret;

 $api = OneTimeSecret->new( <your customer id>, <your API key> );

 $response = $api->shareSecret( "Attack at dawn" );
 $secretKey = $response->{secret_key};

 $retrievedMessage = $api->retrieveSecret( $secretKey );
 print $retrievedMessage->{value};
 Attack at dawn

 $retrieveAgain = $api->retrieveSecret( $secretKey );
 print $retrieveAgain->{value}; # value is empty


=head1 VERSION

    0.01


=head1 DESCRIPTION

See https://onetimesecret.com if you don't know how it works or what it's
for.

=head2 FEATURES

=over

=item * Very thin wrapper

You have full access to arguments and returned values for all the
REST API calls.

=item * Transparent

You call it with Perl data, and get back Perl data.  No messing
with encoding or decoding of JSON.

=back

=head1 TODO

=over

=item too many things to list

=back


=head1 BUGS

Please report bugs relevant to C<OneTimeSecret> to E<lt>info[at]kyledawkins.comE<gt>.


=head1 SEE ALSO

Some other stuff.

=head1 AUTHOR

Kyle Dawkins, E<lt>info[at]kyledawkins.comE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright 2011 by Kyle Dawkins

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


