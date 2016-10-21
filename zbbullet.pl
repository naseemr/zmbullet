#!/usr/bin/perl -T

use File::Basename;
use Data::Dumper;
use bytes;
use strict;
use WWW::PushBullet;
use lib '/usr/local/lib/x86_64-linux-gnu/perl5';
use POSIX;
use ZoneMinder;
use warnings;
use DBI;

$| = 1;


my $driver = "mysql";
my $database = "zm";
my $user = "admin";
my $password = "my1Sadia";


my $dbh = zmDbConnect();
my $sql = "select M.*, max(E.Id) as LastEventId from Monitors as M left join Events as E on M.Id = E.MonitorId where M.Function != 'None' group by (M.Id)";

my $sth = $dbh->prepare_cached( $sql )
    or Fatal( "Can't prepare '$sql': ".$dbh->errstr() );

my $res = $sth->execute() or die( "Can't execute '$sql': ".$sth->errstr() );
my @monitors;
while ( my $monitor = $sth->fetchrow_hashref() )
{
    push( @monitors, $monitor );
}

while( 1 )
{
    foreach my $monitor ( @monitors )
    {
        next if ( !zmMemVerify( $monitor ) );

        if ( my $last_event_id = zmHasAlarmed( $monitor, $monitor->{LastEventId} ) )
        {
            $monitor->{LastEventId} = $last_event_id;
            
            my $pb = WWW::PushBullet->new({apikey => 'your pushbullet api key'});
             $pb->push_link({ device_id => 'all', title => 'Motion event '.$last_event_id,url => 'http://<your domain>/zm/index.php?view=event&eid='.$last_event_id });
            while (zmInAlarm($monitor)) { };
        }
    }
    sleep( 1 );
}
