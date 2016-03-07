#!/Users/mac/perl5/perlbrew/perls/perl-5.16.0/bin/perl

# Version-2016-03-07
#---To Do List---
# Relatively Download Path
# Compress
# Double Byte Character
# Start/Stop download Chapter/Volume
# GUI
# multiple download
# log

use strict;
use warnings;
use LWP::Simple;

#######################
##    URL & TITLE    ##
#######################
#進擊的巨人
my $name = "AttachOnTitan";
my $url  = 'http://www.mh5.tw/comic/3212/8032';

#######################
##      CHAPTER      ##
#######################
my $chap = 1; #start chapter/volume



#----------------------------PROGRAM START------------------------------#

## Check OS
my $os = $^O;
print "OS is >$os<\n";
#exit 0;

my $RenameCMD; # Rename Command
if ($os eq "darwin"){
	$RenameCMD = "mv";
}else{
	$RenameCMD = "rename";
}

$url =~ /\/(\d+)$/;
my $urlNum = $1;
print "urlNum:$urlNum";

$url =~ /(.*)\/comic/;
my $urlBase = $1;
#print "$urlBase\n";

my $content = get($url) or die 'Unable to get page';
#print "my \$content=>\n";
#exit 0;

$content =~ /chapterTree=(.*);/;
my $chapter = $1;
#print "$chapter\n";
$chapter = RemoveBrackets($chapter);
#print $chapter;

my @chapter = split(',',$chapter);


my $Cnt;
foreach(@chapter){
    $Cnt++;
	$_ =~ /\/\d+\/(\d+)$/;
	my $chapter_url_num = $1;
	#print "chapURL:>$chapter_url_num<";
	if( $chapter_url_num < $urlNum ){
		print "Escape Chapter/Volume:>$Cnt<\n";
		next;
	}
	
	print "\n\n----->Start to download Vol.$chap";
	my $url = $urlBase.$_;
	#print "$url\n";
	my $content = get($url) or die 'Unable to get page';
	$content =~ /picTree =(.*);/;
	my $pics = $1;
	$content =~ /pic_base =(.*);/;
	my $source = $1;
	#print "$pics\n\n\n$source\n";
	DownloadPics($pics,$chap,$source);
	$chap++;
	#exit 0;
}




sub RemoveBrackets{
	my $var = shift;
	$var =~s/\[//;
	$var =~s/\]//;
	$var =~s/\\//g;
	$var =~s/"//g;
	$var =~s/\'//g;
	$var =~s/\s//g;
	#print "return:$var\n";
	return $var;
}

sub DownloadPics{
    my $pics   = shift;
	my $vol    = shift;
	my $source = shift;
	my $pgnum  = 1;
	$pics      = RemoveBrackets($pics);
	$source    = RemoveBrackets($source);
	
	my @pic = split(",",$pics);

	if (-e $name){
		print "\n\n";
		print "--->Directory is already exist!\n";
		print "\n\n";
		sleep 1;
	}else{
		#print "mkdir $name";
		system "mkdir $name";
		#<STDIN>;
	}

	if (-e $vol){
		print "\n\n";
		print "--->Directory is already exist!\n";
		print "\n\n";
		sleep 1;
	}else{
		$vol = sprintf("%02d",$vol);
		system "mkdir \"$name\/$vol\"";
		#<STDIN>;
	}

	foreach(@pic){
		
		$_ =~ s/\"//g;
		#print $_ . "\n";

		#<STDIN>;
		my $cmd = "wget $source$_";
		#print "\n\n\n>CMD:$cmd<\n\n\n";
		system "wget $cmd";
		
		my $newName = sprintf ( "%03d", $pgnum);
		print "\n\n----------------------------------------------------------------------\n";
		print "------>$name-$vol-$newName.jpg\n";
		print "----------------------------------------------------------------------\n\n\n";
		
		my $cmd1 = "$RenameCMD $_ \"$name\/$vol\/$name-$vol-$newName.jpg\"";
		print ">$cmd1<\n";
		system $cmd1;
		sleep 1;
		$pgnum++;
		#exit;
		#<STDIN>;
	}
	sleep 1;
	
}

print "\n\n----------------------------------------------------------------------\n";
print "----------------------------------------------------------------------\n";
print "------>MISSION  COMPLETED !!\n";
print "----------------------------------------------------------------------\n";
print "----------------------------------------------------------------------\n\n\n";

exit 0;
