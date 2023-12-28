# -*- perl -*-
use strict;
use warnings;
use Test::More tests => 40;

BEGIN { use_ok( 'DBIx::Array' ); }


local $@;
eval {require DBIx::Array::Connect};
my $error   = $@;
my $connect = $ENV{"ORACLE_NICK_NAME"};
my $skip    = $error && !$connect;

SKIP: {
  skip "DBIx::Array::Connect not installed or ORACLE_NICK_NAME not defined", 39 if $skip;

my $sdb      = DBIx::Array::Connect->new->connect($connect);
isa_ok($sdb, "DBIx::Array");
is($sdb->prepare_max_count(3), 3, 'prepare_max_count');
ok(!defined($sdb->{'_prepared'}), 'prepared cache empty');

is($sdb->sqlscalar("SELECT 1 FROM DUAL"), 1, "test 1");
is(scalar(keys %{$sdb->{'_prepared'}}), 1, 'prepared cache size');
is($sdb->sqlscalar("SELECT 1 FROM DUAL"), 1, "test 2");
is(scalar(keys %{$sdb->{'_prepared'}}), 1, 'prepared cache size');
is($sdb->sqlscalar("SELECT 1 FROM DUAL"), 1, "test 3");
is(scalar(keys %{$sdb->{'_prepared'}}), 1, 'prepared cache size');
is($sdb->sqlscalar("SELECT 2 FROM DUAL"), 2, "test 4");
is(scalar(keys %{$sdb->{'_prepared'}}), 2, 'prepared cache size');
is($sdb->sqlscalar("SELECT 2 FROM DUAL"), 2, "test 5");
is(scalar(keys %{$sdb->{'_prepared'}}), 2, 'prepared cache size');
is($sdb->sqlscalar("SELECT 3 FROM DUAL"), 3, "test 6");
is(scalar(keys %{$sdb->{'_prepared'}}), 3, 'prepared cache size');
is($sdb->sqlscalar("SELECT 3 FROM DUAL"), 3, "test 7");
is(scalar(keys %{$sdb->{'_prepared'}}), 3, 'prepared cache size');
is($sdb->sqlscalar("SELECT 3 FROM DUAL"), 3, "test 8");
is(scalar(keys %{$sdb->{'_prepared'}}), 3, 'prepared cache size');
is($sdb->sqlscalar("SELECT 4 FROM DUAL"), 4, "test 9");
is(scalar(keys %{$sdb->{'_prepared'}}), 3, 'prepared cache size');
is($sdb->sqlscalar("SELECT 4 FROM DUAL"), 4, "test 10");
is(scalar(keys %{$sdb->{'_prepared'}}), 3, 'prepared cache size');
is($sdb->sqlscalar("SELECT 5 FROM DUAL"), 5, "test 11");
is(scalar(keys %{$sdb->{'_prepared'}}), 3, 'prepared cache size');
is($sdb->sqlscalar("SELECT 6 FROM DUAL"), 6, "test 12");
is(scalar(keys %{$sdb->{'_prepared'}}), 3, 'prepared cache size');
is($sdb->sqlscalar("SELECT 7 FROM DUAL"), 7, "test 13");
is(scalar(keys %{$sdb->{'_prepared'}}), 3, 'prepared cache size');

is($sdb->prepare_max_count(1), 1, 'prepare_max_count');
ok(!defined($sdb->{'_prepared'}), 'prepared cache empty');

is($sdb->sqlscalar("SELECT 1 FROM DUAL"), 1, "test 14");
is(scalar(keys %{$sdb->{'_prepared'}}), 1, 'prepared cache size');
is($sdb->sqlscalar("SELECT 2 FROM DUAL"), 2, "test 15");
is(scalar(keys %{$sdb->{'_prepared'}}), 1, 'prepared cache size');

is($sdb->prepare_max_count(0), 0, 'prepare_max_count');
ok(!defined($sdb->{'_prepared'}), 'prepared cache empty');
is($sdb->sqlscalar("SELECT 1 FROM DUAL"), 1, "test 16");
ok(!defined($sdb->{'_prepared'}), 'prepared cache empty');
}
