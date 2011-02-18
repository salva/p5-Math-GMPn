/* -*- Mode: C -*- */

#define PERL_NO_GET_CONTEXT 1

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"
#include <gmp.h>

static void
my_mul(mp_limb_t *rp, mp_limb_t *s1p, mp_size_t s1n, mp_limb_t *s2p, mp_size_t s2n) {
    if (s1n && s2n) {
        mp_size_t i = s2n;
        mpn_mul_1(rp, s1p, s1n, *s2p);
        while (--i)
            mpn_addmul_1(rp + i, s1p, s1n - i, s2p[i]);
    }
    else
        nmp_zero(rp, s1n);
}

static void
my_sqr(mp_limb_t *rp, mp_limb_t *s1p, mp_size_t s1n) {
    if (s1n) {
        mp_size_t i = s1n;
        mpn_mul_1(rp, s1p, s1n, *s1p);
        while (--i)
            mpn_addmul_1(rp + i, s1p, s1n - i, s1p[i]);
    }
}

static void
my_set_bitlen(pTHX_ SV *sv, int bitlen, int sign_extend) {
    STRLEN len;
    mp_size_t n;
    n = bitlen / GMP_NUMB_BITS;
    if (n * GMP_NUMB_BITS != bitlen)
        Perl_croak(aTHX_ "invalid bit length %d, on this machine a multiple of %d is required",
                   bitlen, GMP_NUMB_BITS);
    len = n *sizeof(mp_limb_t);
    if (!SvPOK(sv) || (len > SvCUR(sv))) {
        mp_limb_t *p;
        mp_size_t i;
        SvUPGRADE(sv, SVt_PV);
        SvPOK_on(sv);
        i = SvCUR(sv) / sizeof(mp_limb_t);
        p = (mp_limb_t*)SvGROW(sv, len);
        if (sign_extend && i && (p[i - 1] & (1<< (GMP_NUMB_BITS -1))))
            for (; i < n; i++) p[i] = ~0;  
        else
            for (; i < n; i++) p[i] = 0;  

    }
    SvCUR_set(sv, len);
}

static mp_limb_t *prepare_result(pTHX_ SV *sv, STRLEN l) {
    mp_limb_t *r;
    SvUPGRADE(sv, SVt_PV);
    r = (mp_limb_t*)SvGROW(sv, l);
    SvCUR_set(sv, l);
    SvPOK_on(sv);
    return r;
}


#define EXTRACT(sv) ((sv ## p = (mp_limb_t*)SvPV_nolen(sv)), (sv ## l = SvCUR(sv)))
#define RESULT(sv, len) (sv ## p = prepare_result(aTHX_ sv, (len)))
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
    EXTRACT(s1);
    EXTRACT(s2);
    if (s1l < s2l) {
        RESULT(r, s2l);
        mpn_add(rp, s2p, n(s2), s1p, n(s1));
    }
    else {
        RESULT(r, s1l);
        mpn_add(rp, s1p, n(s1), s2p, n(s2));
    }

void
mpn_sub(r, s1, s2)
    SV *r
    SV *s1
    SV *s2
PREINIT:
    mp_limb_t *s1p, *s2p, *rp;
    STRLEN s1l, s2l;
CODE:
    EXTRACT(s1);
    EXTRACT(s2);
    if (s1l < s2l) {
        RESULT(r, s1l);
        mpn_sub(rp, s2p, n(s2), s1p, n(s1));
        mpn_neg_n(rp, rp, n(s2));
    }
    else {
        RESULT(r, s2l);
        mpn_sub(rp, s1p, n(s1), s2p, n(s2));
    }

void
mpn_emul(r, s1, s2)
    SV *r
    SV *s1       
    SV *s2
PREINIT:
    mp_limb_t *s1p, *s2p, *rp;
    STRLEN s1l, s2l;
CODE:
    EXTRACT(s1);
    EXTRACT(s2);
    RESULT(r, s1l + s2l);
    if (s1l < s2l)
        mpn_mul(rp, s2p, n(s2), s1p, n(s1));
    else 
        mpn_mul(rp, s1p, n(s1), s2p, n(s2));

void
mpn_mul(r, s1, s2)
    SV *r
    SV *s1       
    SV *s2
PREINIT:
    mp_limb_t *s1p, *s2p, *rp;
    STRLEN s1l, s2l;
CODE:
    EXTRACT(s1);
    EXTRACT(s2);
    if (s1l < s2l) {
        RESULT(r, s2l);
        my_mul(rp, s2p, n(s2), s1p, n(s1));
    }
    else {
        RESULT(r, s1l);
        my_mul(rp, s1p, n(s1), s2p, n(s2));
    }

void
mpn_esqr(r, s1)
    SV *r
    SV *s1
PREINIT:
    mp_limb_t *s1p, *rp;
    STRLEN s1l;
CODE:
    EXTRACT(s1);
    RESULT(r, s1l * 2);
    mpn_sqr(rp, s1p, n(s1));

void
mpn_sqr(r, s1)
    SV *r
    SV *s1
PREINIT:
    mp_limb_t *s1p, *rp;
    STRLEN s1l, s1l2, rl;
CODE:
    EXTRACT(s1);
    RESULT(r, s1l);
    my_sqr(rp, s1p, n(s1));

void
mpn_divrem(q, r, n, d)
    SV *q
    SV *r
    SV *n
    SV *d
PREINIT:
    mp_limb_t *np, *dp, *qp, *rp;
    STRLEN nl, dl, ql;
    mp_size_t dn, nn;
CODE:
    EXTRACT(n);
    nn = nl / sizeof(mp_limb_t);
    EXTRACT(d);
    dn = dl / sizeof(mp_limb_t);
    ql = (nl > dl ? nl : dl);
    RESULT(q, ql);
    while(1) {
        if (dn == 0)
            Perl_croak(aTHX_ "division by zero");
        if (dp[dn - 1]) break;
        dn--;
    }
    if (dn > nn) {
        sv_setpvn(r, (char*)np, nl);
        Zero(qp, ql, char);
    }
    else {
        mp_size_t i, qn = ql / sizeof(mp_limb_t);
        RESULT(r, dl);
        mpn_tdiv_qr(qp, rp, 0, np, nn, dp, dn);
        for (i = nn - dn + 1; i < qn; i++)
            qp[i] = 0;
    }

SV *
mpn_get_str(s1, base = 10)
    SV *s1
    int base;
ALIAS:
    mpn_get_strp = 1
PREINIT:
    mp_limb_t *s1p;
    STRLEN s1l, rl, scale, i;
    char *rp;
CODE:
    if (base < 2) Perl_croak(aTHX_ "base < 2 in get_str");
    s1 = sv_2mortal(newSVsv(s1));
    EXTRACT(s1);
    scale = ( (base ==  2) ? 8 :
              (base ==  3) ? 6 :
              (base <=  6) ? 4 :
              (base <= 16) ? 3 :
                             2 );
    RETVAL = newSV(s1l * scale + 1);
    SvPOK_on(RETVAL);
    rp = SvPV_nolen(RETVAL);
    rl = mpn_get_str(rp, base, s1p, n(s1));
    for (i = 0; (i < rl - 1) && (rp[i] == 0); i++);
    if (i) {
        rl -= i;
        Move(rp + i, rp, rl, char);
    }
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
mpn_set_str(r, s, base = 10, bitlen = 0)
    SV *r
    SV *s
    int base
    int bitlen
ALIAS:
    mpn_set_strp = 1
PREINIT:
    mp_limb_t *rp;
    STRLEN rl, sl, scale;
    mp_size_t rn;
    unsigned char *spv;
CODE:
    if (ix) {
        STRLEN i;
        s = sv_2mortal(newSVsv(s));
        spv = SvPV(s, sl);
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
    else
        spv = SvPV(s, sl);
    scale = ( (base ==  2) ? 8 :
              (base ==  3) ? 5 :
              (base ==  4) ? 4 :
              (base <=  6) ? 3 :
              (base <= 16) ? 2 :
                             1 );
    rl = sl / scale + 2 * sizeof(mp_limb_t);
    RESULT(r, rl);
    rn = mpn_set_str(rp, spv, sl, base);
    SvCUR_set(r, rn * sizeof(mp_limb_t));
    if (bitlen)
        my_set_bitlen(aTHX_ r, bitlen, 0);

void
mpn_set_bitlen(r, bitlen, sign_extend = 0)
    SV *r
    int bitlen
    int sign_extend
CODE:
    my_set_bitlen(aTHX_ r, bitlen, sign_extend);

