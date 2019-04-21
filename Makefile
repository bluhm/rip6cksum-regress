# $OpenBSD$

PROG =		rip6-cksum
WARNINGS =	yes

REGRESS_TARGETS +=	run-no-cksum
run-no-cksum: ${PROG}
	${SUDO} ./${PROG} -c 0 -w 10 -s 3 -- \
	    python2 ${.CURDIR}/sendrecv.py

.include <bsd.regress.mk>
