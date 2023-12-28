# -*- perl -*-
use strict;
use warnings;
use Test::More tests => 23;

BEGIN { use_ok( 'DBIx::Array' ); }

local $@;
eval {require DBIx::Array::Connect};
my $error   = $@;
my $connect = $ENV{"ORACLE_NICK_NAME"};
my $skip    = $error && !$connect;

SKIP: {
  skip "DBIx::Array::Connect not installed or ORACLE_NICK_NAME not defined", 22 if $skip;

my $dac = DBIx::Array::Connect->new ();
isa_ok ($dac, 'DBIx::Array::Connect');
my $dba=$dac->connect($connect);
isa_ok ($dba, 'DBIx::Array');

is($dba->dbms_name, "Oracle", "dbms_name");

is($dba->action("one"), "one", 'action method');
is($dba->action, "one", 'action method');
is($dba->{"action"}, "one", 'action property');

{
  is($dba->action, "one", 'action method');
  is($dba->{"action"}, "one", 'action property');
  local $dba->{"action"}="two";
  is($dba->action, "two", 'action method');
  is($dba->{"action"}, "two", 'action property');
  my $list1=$dba->sqlarrayhash(&session_sql);
  is($list1->[0]->{"action"}, "two", 'v$session select');
  {
    is($dba->action, "two", 'action method');
    is($dba->{"action"}, "two", 'action property');
    my $list3=$dba->sqlarrayhash(&session_sql);
    is($list3->[0]->{"action"}, "two", 'v$session select');
    local $dba->{"action"}="three";
    is($dba->action, "three", 'action method');
    is($dba->{"action"}, "three", 'action property');
    my $list4=$dba->sqlarrayhash(&session_sql);
    is($list4->[0]->{"action"}, "three", 'v$session select');
    sleep 3;
  }
  is($dba->action, "two", 'action method');
  is($dba->{"action"}, "two", 'action property');
  my $list2=$dba->sqlarrayhash(&session_sql);
  is($list2->[0]->{"action"}, "two", 'v$session select');
  sleep 3;
}

is($dba->action, "one", 'action method');
is($dba->{"action"}, "one", 'action property');
my $list=$dba->sqlarrayhash(&session_sql);
is($list->[0]->{"action"}, "one", 'v$session select');
sleep 3;
}

sub session_sql {
  return qq{
            --Script: $0
            select MODULE AS "module",
                   ACTION AS "action",
                   CLIENT_INFO AS "client_info",
                   CLIENT_IDENTIFIER AS "client_identifier"
              FROM V\$SESSION
             where AUDSID=SYS_CONTEXT('USERENV','SESSIONID')
           };
}
