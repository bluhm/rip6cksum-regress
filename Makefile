# $OpenBSD$

PROG =		rip6-cksum
WARNINGS =	yes

REGRESS_TARGETS +=	run-no-cksum
run-no-cksum: ${PROG}
	${SUDO} ./${PROG}

.include <bsd.regress.mk>
