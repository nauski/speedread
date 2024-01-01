use strict;
use warnings;
use Irssi;
use utf8;
use Encode;

our $VERSION = '1.2';
our %IRSSI = (
    authors     => 'Juha Kesti',
    contact     => 'nauski@nauski.com',
    name        => 'readsogood.pl',
    description => 'Bolds the first (1-3) characters of each word.',
    license     => 'Public Domain',
);

sub bold_first_three {
    my $msg = shift;
    my @chars = split //, $msg;
    my $new_msg = "";
    my $is_color_code = 0;
    my $char_count = 0;

    foreach my $char (@chars) {
        if ($char eq "\x03") { 
            $is_color_code = 1;
        } elsif ($char =~ /\s/ || $char =~ /\W/) {
            $char_count = 0;
            $is_color_code = 0;
        }

        if ($is_color_code) {
            $new_msg .= $char;
            if ($char =~ /[0-9,]/) {
                next;
            } else {
                $is_color_code = 0 if $char =~ /\s/;
            }
        } else {
            if ($char_count < 3 && $char =~ /\w/) {
                $new_msg .= "\x02" . $char . "\x02";
                $char_count++;
            } else {
                $new_msg .= $char;
                $char_count++ if $char =~ /\w/;
            }
        }
    }

    return $new_msg;
}

sub message_handler {
    my ($server, $msg, $nick, $address, $target) = @_;
    my $decoded_msg = Encode::decode_utf8($msg);
    my $new_msg = bold_first_three($decoded_msg);
    my $encoded_msg = Encode::encode_utf8($new_msg);
    Irssi::signal_continue($server, $encoded_msg, $nick, $address, $target);
}

Irssi::signal_add_first('message public', 'message_handler');
Irssi::signal_add_first('message own_public', 'message_handler');
