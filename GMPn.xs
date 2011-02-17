/* -*- Mode: C -*- */

#define PERL_NO_GET_CONTEXT 1

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"
#include <gmp.h>

void
mulmod(mp_limb_t *rp, mp_limb_t *s1p, mp_size_t s1n, mp_limb_t *s2p, mp_size_t s2n) {
    if (s1n && s2n) {
        if (s2n > s1n) s2n = s1n;
        mpn_mul_1(rp++, s1p++, s1n--, *(s2p++));
        while (s1n) mpn_addmul_1(rp++, s1p++, s1n--, *(s2p++));
    }
    else
        nmp_zero(rp, s1n);
}


#define extract(sv) ((sv ## p = (mp_limb_t*)SvPV_nolen(sv)), (sv ## l = SvCUR(sv)))

#define n(sv) (sv ## l / sizeof(mp_limb_t))

MODULE = Math::GMPn		PACKAGE = Math::GMPn		

int
sizeof_mp_limb_t()
CODE:
    RETVAL = sizeof(mp_limb_t);
OUTPUT:
    RETVAL

void
mpn_add(r, s1, s2)
    SV *r
    SV *s1
    SV *s2
PREINIT:
    mp_limb_t *s1p, *s2p, *rp;
    STRLEN s1l, s2l, rl;
CODE:
    extract(s1);
    extract(s2);
    extract(r);
    if (s1l < s2l) {
        if (rl < s2l) rp = (mp_limb_t*)sv_grow(r, s2l);
        mpn_add(rp, s2p, n(s2), s1p, n(s1));
        SvPOK_on(r);
        SvCUR_set(r, s2l);
    }
    else {
        if (rl < s1l) rp = (mp_limb_t*)sv_grow(r, s1l);
        mpn_add(rp, s1p, n(s1), s2p, n(s2));
        SvPOK_on(r);
        SvCUR_set(r, s1l);
    }

void
mpn_sub(r, s1, s2)
    SV *r
    SV *s1
    SV *s2
PREINIT:
    mp_limb_t *s1p, *s2p, *rp;
    STRLEN s1l, s2l, rl;
CODE:
    extract(s1);
    extract(s2);
    extract(r);
    if (s1l < s2l) {
        if (rl < s2l) rp = (mp_limb_t*)sv_grow(r, s2l);
        mpn_sub(rp, s2p, n(s2), s1p, n(s1));
        mpn_neg_n(rp, rp, n(s2));
        SvPOK_on(r);
        SvCUR_set(r, s2l);
    }
    else {
        if (rl < s1l) rp = (mp_limb_t*)sv_grow(r, s1l);
        mpn_sub(rp, s1p, n(s1), s2p, n(s2));
        SvPOK_on(r);
        SvCUR_set(r, s1l);
    }

void
mpn_mul_ext(r, s1, s2)
    SV *r
    SV *s1       
    SV *s2
PREINIT:
    mp_limb_t *s1p, *s2p, *rp;
    STRLEN s1l, s2l, s12l, rl;
CODE:
    extract(s1);
    extract(s2);
    extract(r);
    s12l = s1l + s2l;
    if (rl < s12l)
        rp = (mp_limb_t*)sv_grow(r, s12l);
    if (s1l < s2l)
        mpn_mul(rp, s2p, n(s2), s1p, n(s1));
    else 
        mpn_mul(rp, s1p, n(s1), s2p, n(s2));
    SvPOK_on(r);
    SvCUR_set(r, s12l);

void
mpn_mul(r, s1, s2)
    SV *r
    SV *s1       
    SV *s2
PREINIT:
    mp_limb_t *s1p, *s2p, *rp;
    STRLEN s1l, s2l, s12l, rl;
CODE:
    extract(s1);
    extract(s2);
    extract(r);
    if (rl < s1l)
        rp = (mp_limb_t*)sv_grow(r, s12l);
    mulmod(rp, s1p, n(s1), s2p, n(s2));
    SvPOK_on(r);
    SvCUR_set(r, s1l);

void
mpn_sqr(r, s1)
    SV *r
    SV *s1
PREINIT:
    mp_limb_t *s1p, *rp;
    STRLEN s1l, s1l2, rl;
CODE:
    extract(s1);
    extract(r);
    s1l2 = s1l * 2;
    if (rl < s1l2)
        rp = (mp_limb_t*)sv_grow(r, s1l2);
    mpn_sqr(rp, s1p, n(s1));
    SvPOK_on(r);
    SvCUR_set(r, s1l2);

SV *
mpn_get_str(s1, base = 10)
    SV *s1
    int base;
ALIAS:
    mpn_get_strp = 1
PREINIT:
    mp_limb_t *s1p;
    STRLEN s1l, rl, scale;
CODE:
    if (base < 2) Perl_croak(aTHX_ "base < 2 in get_str");
    s1 = sv_2mortal(newSVsv(s1));
    extract(s1);
    scale = ( (base ==  2) ? 8 :
              (base ==  3) ? 6 :
              (base <=  6) ? 4 :
              (base <= 16) ? 3 :
                             2 );
    RETVAL = newSV(s1l * scale + 1);
    SvPOK_on(RETVAL);
    rl = mpn_get_str(SvPV_nolen(RETVAL), base, s1p, n(s1));
    SvCUR_set(RETVAL, rl);
    if (ix) {
        STRLEN i;
        char *pv = SvPV_nolen(RETVAL);
        for (i = 0; i < rl; i++) {
            char c = pv[i];
            if (c < 10) pv[i] = c + '0';
            else pv[i] = c + 'a' - 10;
        }
    }
OUTPUT:
    RETVAL

void
mpn_set_str(r, s, base = 10)
    SV *r
    SV *s
    int base
ALIAS:
    mpn_set_strp = 1
PREINIT:
    mp_limb_t *rp;
    STRLEN rl, rl1, sl, scale;
    mp_size_t rn;
    unsigned char *spv;
CODE:
    extract(r);
    if (ix)
        s = sv_2mortal(newSVsv(s));
    spv = SvPV(s, sl);
    if (ix) {
        STRLEN i;
        for (i = 0; i < sl; i++) {
            char c = spv[i];
            if ((c >= '0') && (c <= '9'))
                spv[i] = c - '0';
            else if ((c >= 'a') && (c <= 'z'))
                spv[i] = c - 'a' + 10;
            else if ((c >= 'A') && (c <= 'Z'))
                spv[i] = c - 'A' + 10;
            else
                Perl_croak(aTHX_ "bad digit, ascii code: %d", c);
        }
    }
    scale = ( (base ==  2) ? 8 :
              (base ==  3) ? 5 :
              (base ==  4) ? 4 :
              (base <=  6) ? 3 :
              (base <= 16) ? 2 :
                             1 );
    rl1 = ((rl / scale + sizeof(mp_limb_t)) / sizeof(mp_limb_t) + 1) * sizeof(mp_limb_t);
    if (rl1 > rl)
        rp = (mp_limb_t*) sv_grow(r, rl1);
    rn = mpn_set_str(rp, spv, sl, base);
    SvPOK_on(r);
    SvCUR_set(r, rn * sizeof(mp_limb_t));

