#!/usr/bin/perl
for (my $var = 0; $var <= 100; $var++) {
	print STDOUT "    Progress: $var%\n";
	sleep(1);
	if ($var < 100) {
		printf STDOUT "\e[A";
	}
}
