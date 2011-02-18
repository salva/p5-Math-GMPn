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
		     mpn_get_strp
		     mpn_set_str
		     mpn_set_strp

                     mpn_set_bitlen
		  );
our @EXPORT = @EXPORT_OK; # remove me!

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Math::GMPn', $VERSION);

1;
__END__

=head1 NAME

Math::GMPn - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Math::GMPn;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Math::GMPn, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



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
