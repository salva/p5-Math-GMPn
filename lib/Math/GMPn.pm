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
library low level functions (see
L<http://gmplib.org/manual/Low_002dlevel-Functions.html>).

Numbers are represented as arrays of GMP mp_limb_t integers (usually,
the native unsigned int) packed into Perl scalars without any
additional wrapping.

The bit length of the strings passed to the module must be a multiple
of the mp_limb_t bit size (32 and 64 bits for 32bit and 64bit machines
respectively). Most operations do not check that condition and their
results are unspecified when non conforming sizes are used.

Also, the strings passed must not b

When strings of different length are used on the same operation, the
result lenght is equal to that of the largest input. For instance,
adding a 128bit string and a 256bit string will output a 256bit
string.

=head2 EXPORT

=over 4

=item GMP_LIMB_BYTES()

Return the size in bytes of the mp_limb_t type used internally by GMP to
represent numbers. It is 4 for 32bit machines and 8 for 64bit ones.

=item GMP_LIMB_BITS()

Return the size in bits of the mp_limb_t type. 32 or 64 for 32bit and
64 bit machines respectively.

=item mpn_set_str($r, $str, $base, $bitlen)

Converts an ASCII representation of the number in the given base
C<$base> to the internal representation used by Math::GMPn.

Digits must be in the range '0'-'9' and 'a'-'z' or 'A'-'Z'.

C<$base> must be between 2 and 36 (inclusive) and defaults to 10.

If C<$bitlen> is not given, the minimum plausible bit length able to
store the given number is used.

=item mpn_set_str0($r, $str, $base, $bitlen)

Converts a byte representation of the number in the given base
C<$base> to the internal representation.

For instance, the following calls are equivalent:

  mpn_set_str0($a1, "\xf0\xaa\x01", 16, 128);
  mpn_set_str0($a2, "f0aa01", 16, 128);

=item mpn_set_random($r, $bitlen)

Generate a random number of length <$bitlen>. The most significant
limb is always non-zero.

=item mpn_set_uint($r, $u1, $bitlen)

Converts a Perl native number to Math::GMPn internal format.

=item mpn_setior_uint($r, $u1, $offset, $bitlen)

Sets the 

=item mpn_set_bitlen($r, $bitlen, sign_extend)

=item mpn_get_str($s1, $base)

=item mpn_get_str0($s1, $base)

=item mpn_get_uint($s1, $offset)

=item mpn_ior($r, $s1, $s2)

=item mpn_xor($r, $s1, $s2)

=item mpn_and($r, $s1, $s2)

=item mpn_andn($r, $s1, $s2)

=item mpn_iorn($r, $s1, $s2)

=item mpn_nand($r, $s1, $s2)

=item mpn_nior($r, $s1, $s2)

=item mpn_xnor($r, $s1, $s2)

=item mpn_add($r, $s1, $s2)

=item mpn_sub($r, $s1, $s2)

=item mpn_mul($r, $s1, $s2)

=item mpn_mul_ext($r, $s1, $s2)

=item mpn_sqr($r, $s1)

=item mpn_sqr_ext($r, $s1)

=item mpn_divrem($q, $r, $s1, $s2)

=item mpn_divexact_by3($r, $s)

=item mpn_addmul($r, $s1, $s2)

=item mpn_submul($r, $s1, $s2)

=item mpn_lshift($r, $u1)

=item mpn_rshift($r, $u1)

=item $cnt = mpn_popcount($s1)

=item $cnt = mpn_hamdist($s1, $s2)

=item $pos = mpn_scan0($s1, $start)

=item $pos = mpn_scan1($s1, $start)

=item $cmp = mpn_cmp($s1, $s2)

=item $bool = mpn_perfect_square_p($s1)

=item $mpn_gcd_dest($r, $sd1, $sd2)

=item mpn_ior_uint($r, $s1, $u1)

=item mpn_xor_uint($r, $s1, $u1)

=item mpn_and_uint($r, $s1, $u1)

=item mpn_andn_uint($r, $s1, $u1)

=item mpn_iorn_uint($r, $s1, $u1)

=item mpn_nand_uint($r, $s1, $u1)

=item mpn_nior_uint($r, $s1, $u1)

=item mpn_xnor_uint($r, $s1, $u1)

=item mpn_add_uint($r, $s1, $u1)

=item mpn_sub_uint($r, $s1, $u1)

=item mpn_mod_uint($r, $s1, $u1)

=item mpn_mul_uint($r, $s1, $u1)

=item mpn_addmul_uint($r, $s1, $u1)

=item mpn_submul_uint($r, $s1, $u1)

=back


=head1 SEE ALSO

L<Math::GMPz>, L<Math::Int128>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Salvador FaE<ntilde>dino E<lt>sfandino@yahoo.comE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
