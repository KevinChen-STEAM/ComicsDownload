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
# Correct Title
# Download tmp directory
#
#---Change History---
#	2016-03-07 Add Stop chapter
#              Mkdir temp directory
#              Remove exist files

use strict;
use warnings;
use LWP::Simple;

#----------------------------Setting------------------------------#
#######################
##    URL & TITLE    ##
#######################
my $name = "JoJo";
my $url  = 'http://www.mh5.tw/comic/9113/25513';

#######################
##      CHAPTER      ##
#######################
my $chap     = 1; #start chapter/volume
my $chapStop = 80;

#######################
##      CHAPTER      ##
#######################
my $binDir = "\/Users\/mac\/data\/Comics\/pgm\/bin\/";
my $tmpDir = "\/Users\/mac\/data\/Comics\/tmp\/";


#----------------------------PROGRAM START------------------------------#

print "\n\n------>Start to download Comics >$name< !! \n\n";

## Check OS
my $os = $^O;
#print "OS is >$os<\n";
#exit 0;

my $RenameCMD; # Rename Command
my $rmCMD;
if ($os eq "darwin"){
	$RenameCMD = "mv";
	$rmCMD     = "rm";
}else{
	$RenameCMD = "rename";
	$rmCMD     = "del";
}

$url =~ /\/(\d+)$/;
my $urlNum = $1;
#print "urlNum:$urlNum";

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
	
	print "\n----->Start to download Vol.$chap\n";
	my $url = $urlBase.$_;
	#print "$url\n";
	my $content = get($url) or die 'Unable to get page';
	$content =~ /picTree =(.*);/;
	my $pics = $1;
	$content =~ /pic_base =(.*);/;
	my $source = $1;
	#print "$pics\n\n\n$source\n";
	
    my $FirstLevelDir = "$tmpDir$name";
    MkDir("$FirstLevelDir");
    
    $chap = sprintf ( "%03d", $chap);
	my $SecLevelDir = "$FirstLevelDir\/$chap";
	MkDir("$SecLevelDir");
	
	DownloadPics( $pics,$chap,$source,$SecLevelDir );
	
	if ( ( $chapStop != 0 ) && ( $chap == $chapStop ) ){
		print "\n\n----------------------------------------------------------------------\n";
		print "----------------------------------------------------------------------\n";
		print "----->Stop Downlaod At Chapter/Volume >$chap< !!\n";
		print "----------------------------------------------------------------------\n";
		print "----------------------------------------------------------------------\n\n\n";
		exit 0;
	}
	
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

sub MkDir{
    my $dir = shift;
	if (-e $dir){
		print "\n\n----->Directory >$dir< is already exist!\n";
		sleep 1;
	}else{
		print "\n\n----->mkdir $dir\n\n";
		system "mkdir $dir";
	}
}

sub DownloadPics{
    my $pics   = shift;
	my $vol    = shift;
	my $source = shift;
	my $dir    = shift;
	my $pgnum  = 1;
	$pics      = RemoveBrackets($pics);
	$source    = RemoveBrackets($source);
	
	my @pic = split(",",$pics);

	foreach(@pic){

		$_ =~ s/\"//g;
		#print "\n\n\n>$binDir$_<\n\n\n";
		if (-e "$binDir$_"){
			print "--->Pic >$binDir$_<is already exist !!\n";
			print "--->rm $binDir$_\*";
			system "$rmCMD $binDir$_\*";
		}

		#<STDIN>;
		my $cmd = "wget $source$_";
		#print "\n\n\n>CMD:$cmd<\n\n\n";
		system "wget $cmd";
		
		my $newName = sprintf ( "%03d", $pgnum);
		print "\n\n----------------------------------------------------------------------\n";
		print "------>$name-$vol-$newName.jpg\n";
		print "----------------------------------------------------------------------\n\n\n";
		
		my $cmd1 = "$RenameCMD $_ \"$dir\/$name-$vol-$newName.jpg\"";
		#print ">$cmd1<\n";
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
