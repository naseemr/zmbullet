#!/usr/bin/perl -w

use strict;
use WWW::PushBullet;
use ZoneMinder;
use DBI;


$| = 1;


my $dbh = zmDbConnect();

my $sql = "select M.*, max(E.Id) as LastEventId from Monitors as M left join Events as E on M.Id = E.MonitorId where M.Function != 'None' group by (M.Id)";
my $sth = $dbh->prepare_cached( $sql ) or die( "Can't prepare '$sql': ".$dbh->errstr() );

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
              $pb->push_link({ device_id => 'all', title => 'Motion event '.$last_event_id,url => '<your zm url>/zm/index.php?view=event&eid='.$last_event_id });
             while (zmInAlarm($monitor)) { };
        }
    }
    sleep( 1 );
}
