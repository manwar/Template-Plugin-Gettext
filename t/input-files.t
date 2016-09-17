#! /usr/bin/env perl

# Copyright (C) 2016 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Library General Public License as published
# by the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.

# You should have received a copy of the GNU Library General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
# USA.

use strict;

use Test::More tests => 9;

use Locale::XGettext::TT2;

my $test_dir = __FILE__;
$test_dir =~ s/[-a-z0-9]+\.t$//i;
chdir $test_dir or die "cannot chdir to $test_dir: $!";

my $sep = '(?:"|\\\\n)';

sub find_entries;

my $po = Locale::XGettext::TT2->new({}, 'template.tt', 'additional.tt')->run->po;
is((scalar find_entries $po, msgid => qq{"Hello, world!\\n"}), 1);
is((scalar find_entries $po, msgid => qq{"Hello, Mars!\\n"}), 1);
is((scalar find_entries $po, msgid => qq{"Hello, extraterrestrials!\\n"}), 0);

$po = Locale::XGettext::TT2->new({files_from => ['POTFILES1']}, 'extra.tt')
                            ->run->po;
is((scalar find_entries $po, msgid => qq{"Hello, world!\\n"}), 1);
is((scalar find_entries $po, msgid => qq{"Hello, Mars!\\n"}), 1);
is((scalar find_entries $po, msgid => qq{"Hello, extraterrestrials!\\n"}), 1);

# Test that we can read from multiple files and that the entries are merged.
$po = Locale::XGettext::TT2->new({files_from => ['POTFILES1', 'POTFILES2']})
                            ->run->po;
is((scalar find_entries $po, msgid => qq{"Hello, world!\\n"}), 1);
is((scalar find_entries $po, msgid => qq{"Hello, Mars!\\n"}), 1);
is((scalar find_entries $po, msgid => qq{"Hello, extraterrestrials!\\n"}), 1);

sub find_entries {
    my ($po, %args) = @_;

    my @hits;
    foreach my $entry (@$po) {
        next if exists $args{msgid} && $entry->msgid ne $args{msgid};
        next if exists $args{msgstr} && $entry->msgstr ne $args{msgstr};
        push @hits, $entry;
    }

    return @hits;
}