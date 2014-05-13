use base "basetest";
use bmwqemu;

sub is_applicable() {
    return $ENV{DESKTOP} eq "gnome";
}

sub run() {
    my $self = shift;
    x11_start_program("evolution");
    if ( $ENV{UPGRADE} ) { send_key "alt-f4"; wait_idle; }    # close mail format change notifier
    assert_screen 'test-evolution-1', 3;
    sleep 1;
    send_key "ctrl-q";                                        # really quit (alt-f4 just backgrounds)
    send_key "alt-f4";
    wait_idle;
}

1;
# vim: set sw=4 et:
