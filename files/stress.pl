#!/usr/bin/perl

# apt-get install -y libmongodb-perl libparallel-forkmanager-perl libstring-random-perl

use strict;
use warnings;

use MongoDB;
use Tie::IxHash;
use String::Random qw(random_regex random_string);
use Parallel::ForkManager;

if(!$ARGV[0] || !$ARGV[1]) {
	print "Especifique o número de conexões paralelas e o número de execuções. Ex: perl $0 32 1000\n";
	exit(1);
}

my ($nconn, $nexec) = @ARGV;

my $pm = Parallel::ForkManager->new($nconn);
$pm->run_on_start(sub { srand });

LOOP:
for(my $n = 0; $n < $nconn; $n++) {
	$pm->start and next LOOP;
	my $client = MongoDB->connect('mongodb://localhost');
	my $stress = $client->ns('perl.stress'); # database stress, collection data
	for(my $i = 0; $i < $nexec; $i++) {
		my $data = Tie::IxHash->new(
			number => int(random_regex('[1-9][0-9]{4}')),
			string =>  random_string('cccccccccccccccccccc')
		);
		my $result = $stress->insert_one($data);
	}
	$pm->finish;
}

$pm->wait_all_children;
