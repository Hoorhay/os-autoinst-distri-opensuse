# SUSE's openQA tests
#
# Copyright © 2019 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Transfer repositories to the public cloud instasnce
#
# Maintainer: Pavel Dostal <pdostal@suse.cz>

use base 'consoletest';
use registration;
use warnings;
use testapi;
use strict;
use utils;

sub run {
    my ($self, $args) = @_;

    my @addons = split(/,/, get_var('SCC_ADDONS', ''));

    select_console 'tunnel-console';

    $args->{my_instance}->run_ssh_command(cmd => "sudo SUSEConnect -r " . get_required_var('SCC_REGCODE'), timeout => 180) unless (get_var('FLAVOR') =~ 'On-Demand');

    for my $addon (@addons) {
        ssh_add_suseconnect_product($args->{my_instance}->public_ip, get_addon_fullname($addon)) unless ($addon eq '');
    }

    assert_script_run("rsync -va -e ssh ~/repos root@" . $args->{my_instance}->public_ip . ":'/tmp/repos'", timeout => 900);
    $args->{my_instance}->run_ssh_command(cmd => "sudo find /tmp/repos/ -name *.repo -exec sed -i 's,http://,/tmp/repos/repos/,g' '{}' \\;");
    $args->{my_instance}->run_ssh_command(cmd => "sudo find /tmp/repos/ -name *.repo -exec zypper ar '{}' \\;");
    $args->{my_instance}->run_ssh_command(cmd => "sudo find /tmp/repos/ -name *.repo -exec echo '{}' \\;");
}

sub test_flags {
    return {
        fatal                    => 1,
        milestone                => 1,
        publiccloud_multi_module => 1
    };
}

1;

