# $OpenBSD$

PROG =		rip6-cksum
WARNINGS =	yes

REGRESS_TARGETS +=	run-no-cksum
run-no-cksum: ${PROG}

.include <bsd.regress.mk>
