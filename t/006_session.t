# -*- perl -*-
use strict;
use warnings;
use Test::More tests => 18;

BEGIN { use_ok( 'DBIx::Array' ); }
BEGIN { use_ok( 'DBIx::Array::Connect' ); }

my $dac = DBIx::Array::Connect->new ();
isa_ok ($dac, 'DBIx::Array::Connect');

my $connect = $ENV{"ORACLE_NICK_NAME"};

SKIP: {
  skip "ORACLE_NICK_NAME not defined", 15 unless $connect;

my $dba=$dac->connect($connect);
isa_ok ($dba, 'DBIx::Array');

is($dba->dbms_name, "Oracle", "dbms_name");

{
  is($dba->module("foo"), "foo", 'module method');
  is($dba->module, "foo", 'module method');
  my $list=$dba->sqlarrayhash(&session_sql);
  is($list->[0]->{"module"}, "foo", 'v$session select');
}

{
  is($dba->client_info("bar"), "bar", 'client_info method');
  is($dba->client_info, "bar", 'client_info method');
  my $list=$dba->sqlarrayhash(&session_sql);
  is($list->[0]->{"client_info"}, "bar", 'v$session select');
}

{
  is($dba->action("baz"), "baz", 'action method');
  is($dba->action, "baz", 'action method');
  my $list=$dba->sqlarrayhash(&session_sql);
  is($list->[0]->{"action"}, "baz", 'v$session select');
}

{
  is($dba->client_identifier("buz"), "buz", 'client_identifier method');
  is($dba->client_identifier, "buz", 'client_identifier method');
  my $list=$dba->sqlarrayhash(&session_sql);
  is($list->[0]->{"client_identifier"}, "buz", 'v$session select');
}

{
  my $list=$dba->sqlarrayhash(&session_sql);
  like($list->[0]->{"program"}, qr/\Aperl:006_session.t\@/, 'v$session program');
}
}


sub session_sql {
  return qq{
            --Script: $0
            select MODULE AS "module",
                   ACTION AS "action",
                   CLIENT_INFO AS "client_info",
                   CLIENT_IDENTIFIER AS "client_identifier",
                   PROGRAM           AS "program"
              FROM V\$SESSION
             where AUDSID=SYS_CONTEXT('USERENV','SESSIONID')
           };
}

