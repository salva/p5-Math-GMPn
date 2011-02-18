package Math::GMPn;

use 5.010001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw( mpn_add
		     mpn_sub
		     mpn_mul
		     mpn_sqr
		     mpn_emul
                     mpn_esqr
                     mpn_divrem

		     mpn_get_str
		     mpn_get_str0
		     mpn_set_str
		     mpn_set_str0

                     mpn_set_bitlen
		  );
our @EXPORT = @EXPORT_OK; # remove me!

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Math::GMPn', $VERSION);

1;
__END__

=head1 NAME

Math::GMPn - Fixed length integer arithmetic.

=head1 SYNOPSIS

  use Math::GMPn;

  # 128bits;
  mpn_set_str($a, "123450000000000", 10, 128);
  mpn_set_str($b, "100000000000001", 10, 128);
  mpn_set_str($c, "1f1f1f1f1f1f1f1", 16, 128); # hexadecimal
  mpn_set_num($d, 23 * 234);

  mpn_mul($r1, $a, $b);
  mpn_add($r2, $r1, $c);
  mpn_div($r3, $r4, $r2, $d);

  say mpn_get_str($r4);

=head1 DESCRIPTION

This module provides a set of functions to perform arithmetic on fixed
length but arbitrarily large bit strings implemented on top of the GMP
library.

The bit length of the strings passed to the module must be a
multiple of the native machine integer size (i.e. 32 or 64 bits). Most
operations do not check that condition and results are unspecified
when other sizes are used.

When strings of different length are used on the same operation, the
result lenght is equal to that of the largest input. For instance,
adding a 128bit string and a 256bit string will output a 256bit
string.




=head2 EXPORT

=over 4

=item mpn_set_str($to, $str, $base, $bitlen)


=back



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Salvador Fandino, E<lt>salva@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Salvador Fandino

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
