package Math::GMPn;

use 5.010001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw( GMP_LIMB_BITS
                  GMP_LIMB_BYTES

                  mpn_neg
                  mpn_add
                  mpn_sub
                  mpn_mul
                  mpn_sqr
                  mpn_emul
                  mpn_divrem
                  mpn_addmul
                  mpn_submul

                  mpn_popcount
                  mpn_hamdist

                  mpn_divexact_by3

                  mpn_mul_ext
                  mpn_sqr_ext

                  mpn_add_uint
                  mpn_sub_uint
                  mpn_mod_uint
                  mpn_mul_uint
                  mpn_addmul_uint
                  mpn_submul_uint

                  mpn_lshift
                  mpn_rshift

                  mpn_scan0
                  mpn_scan1

                  mpn_ior
                  mpn_xor
                  mpn_and
                  mpn_andn
                  mpn_iorn
                  mpn_nand
                  mpn_nior
                  mpn_xnor

                  mpn_ior_uint
                  mpn_xor_uint
                  mpn_and_uint
                  mpn_andn_uint
                  mpn_iorn_uint
                  mpn_nand_uint
                  mpn_nior_uint
                  mpn_xnor_uint

                  mpn_cmp
                  mpn_perfect_square_p

                  mpn_gcd_dest

                  mpn_get_str
                  mpn_get_str0
                  mpn_set_str
                  mpn_set_str0

                  mpn_set_uint
                  mpn_get_uint
                  mpn_setior_uint

                  mpn_set_bitlen
                  mpn_set_random

               );

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

L<Math::GMPz>, L<Math::Int128>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Salvador FaE<ntilde>dino E<lt>sfandino@yahoo.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
