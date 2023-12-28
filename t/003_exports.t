# -*- perl -*-
use strict;
use warnings;
use Test::More tests => 13;

BEGIN { use_ok( 'DBIx::Array::Export' ); }

my $dba = DBIx::Array::Export->new ();
isa_ok ($dba, 'DBIx::Array::Export');
$dba->connect("dbi:CSV:f_dir=.", "", "", {RaiseError=>1, AutoCommit=>1});
my $table="DBIxArray";
$dba->dbh->do("DROP TABLE IF EXISTS $table");
$dba->dbh->do("CREATE TABLE $table (COL1 INTEGER,COL2 CHAR(1),COL3 VARCHAR(20))");
is($dba->sqlinsert("INSERT INTO $table (COL1,COL2,COL3)
                 VALUES (?,?,?)", 1,"a",q{Say "Yes!"}), 1, 'insert');
is($dba->sqlinsert("INSERT INTO $table (COL1,COL2,COL3)
                 VALUES (?,?,?)", 2,"b",q{One, Two, or Three}), 1, 'insert');
is($dba->insert("INSERT INTO $table (COL1,COL2,COL3)
                 VALUES (?,?,?)", 3,"c",q{OK, "Already"}), 1, 'insert');
my $data=$dba->sqlarrayarrayname("SELECT COL1 AS COL1, COL2 AS COL2, COL3 AS COL3 FROM $table ORDER BY COL1");


my $csv=qq{COL1,COL2,COL3\r\n1,a,"Say ""Yes!"""\r\n2,b,"One, Two, or Three"\r\n3,c,"OK, ""Already"""\r\n};

SKIP: {
  eval { require Text::CSV_XS };
  skip "Text::CSV_XS not installed", 2 if $@;

  is(1,1, "Running Tests that depend on Text::CSV_XS");

  is($dba->csv_arrayarrayname($data), $csv, 'csv_arrayarrayname');

}

my $xml=q{<?xml version='1.0' standalone='yes'?>
<document>
  <body>
    <rows>
      <row>
        <COL1>1</COL1>
        <COL2>a</COL2>
        <COL3>Say &quot;Yes!&quot;</COL3>
      </row>
      <row>
        <COL1>2</COL1>
        <COL2>b</COL2>
        <COL3>One, Two, or Three</COL3>
      </row>
      <row>
        <COL1>3</COL1>
        <COL2>c</COL2>
        <COL3>OK, &quot;Already&quot;</COL3>
      </row>
    </rows>
  </body>
  <head>
    <columns>
      <column uom="unit1">COL1</column>
      <column>COL2</column>
      <column uom="unit2">COL3</column>
    </columns>
    <counts>
      <columns>3</columns>
      <rows>3</rows>
    </counts>
  </head>
</document>
};

SKIP: {
  eval { require XML::Simple };
  skip "XML::Simple not installed", 2 if $@;

  is(1,1, "Running Tests that depend on XML::Simple");

  $data=$dba->sqlarrayhashname("SELECT COL1 AS COL1,
                                       COL2 AS COL2,
                                       COL3 AS COL3
                                  FROM $table
                              ORDER BY COL1");
  my $out=$dba->xml_arrayhashname(data=>$data,
                                  uom=>{COL1=>"unit1", COL3=>"unit2"});
  is($out, $xml, "xml_arrayhashname");

}

my $sth=$dba->sqlcursor("SELECT COL1 AS COL1, COL2 AS COL2, COL3 AS COL3 FROM $table ORDER BY COL1");

isa_ok($sth, "DBI::st");

SKIP: {
  eval { require IO::Scalar };
  skip "IO::Scalar not installed", 2 if $@;

  is(1,1, "Running Tests that depend on IO::Scalar");

  $data='';
  my $fh=IO::Scalar->new(\$data);
  $dba->csv_cursor($fh, $sth);
  is($data, $csv, "csv_cursor");

}

SKIP: {
  eval { require Spreadsheet::WriteExcel::Simple::Tabs };
  skip "Spreadsheet::WriteExcel::Simple::Tabs not installed", 1 if $@;

  is(1,1, "Running Tests that depend on Spreadsheet::WriteExcel::Simple::Tabs");

}

$dba->dbh->do("DROP TABLE IF EXISTS $table");
