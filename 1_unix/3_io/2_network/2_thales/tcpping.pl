#!/usr/bin/perl -w
#
# tcpping  - ping a TCP port on a server, ssh by default. 
#            Perl, Unix/Linux/Windows...
#
# USAGE:    tcpping [-h] | hostname [port]
#           
#           -h              # print help
#           hostname        # host to TCP ping
#           port            # port number to use (default is 22)
#                       runs                    # number of times to try connection (default 3)
#                       rest                    # number of seconds to wait before trying again(default 10sec)
##########################################################################################

use strict;
use IO::Socket;

#
#  Command line arguments
#
my $host = defined $ARGV[0] ? $ARGV[0] : "";
usage() if $host =~ /^(-h|--help|)$/;
my $port = defined $ARGV[1] ? $ARGV[1] : 22;    # default port
my $runs = defined $ARGV[2] ? $ARGV[2] : 3;    # default port
my $rest = defined $ARGV[3] ? $ARGV[3] : 10;    # default port

for (my $i=1; $i <= $runs; $i++) {
#
#  Try to connect
#
my $remote = IO::Socket::INET->new(
    Proto    => "tcp",
    PeerAddr => $host,
    PeerPort => $port,
    Timeout  => 8,
);

#
#  Print response
#
if ($remote) {
    print "$host is alive\n";
    close $remote;
    exit 0;
}
else {
    print "$host failed\n";
        sleep $rest;
}
}
exit 1;
# usage - print usage message and exit
#
sub usage {
    print STDERR "USAGE: portping [-h] | hostname [port]\n";
    print STDERR "   eg, portping mars      # try port 22 (ssh) on mars\n";
    print STDERR "       portping mars 21   # try port 21 on mars\n";
    exit 1;
}
### FIN ###
