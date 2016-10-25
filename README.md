# zmbullet
Zoneminder instant notification through PushBullet 

Zoneminder email notification is not instant enough. so I thought of using pushbullet.
Need perl module WWW::PushBullet.

1. update apikey and domain and then copy zmbullet.pl  file in /usr/bin/  with execute permission
2. Edit /usr/bin/zmdc.pl and in the array @daemons (starting line 80) add 'zmbullet.pl' 
3. Edit /usr/bin/zmpkg.pl and around line 260, right after the comment that says #this is now started unconditionally and right before the line that says runCommand( "zmdc.pl start zmfilter.pl" ); start zmbullet.pl by adding runCommand( "zmdc.pl start zmbullet.pl" ); 
