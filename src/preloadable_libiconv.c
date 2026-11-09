/*
 * LD_PRELOAD shim for GNU libiconv which has been dropped since 1.16.
 */
#include <stddef.h>

typedef void *iconv_t;
iconv_t libiconv_open(const char *, const char *);
size_t libiconv(iconv_t, char **, size_t *, char **, size_t *);
int libiconv_close(iconv_t);

iconv_t iconv_open(const char *to, const char *from) { return libiconv_open(to, from); }
size_t iconv(iconv_t cd, char **in, size_t *inleft, char **out, size_t *outleft) { return libiconv(cd, in, inleft, out, outleft); }
int iconv_close(iconv_t cd) { return libiconv_close(cd); }
