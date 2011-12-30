use inc::Module::Install;

name           'OneTimeSecret';
all_from       'OneTimeSecret.pm';

# Specific dependencies
requires       'LWP::UserAgent';
requires       'LWP::Protocol::https';
requires       'JSON';
requires       'Try::Tiny';
requires       'common::sense';
requires       'URI::Escape';
requires       'Encode';
test_requires  'Test::More'  => '0.42';

WriteAll;