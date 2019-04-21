# $OpenBSD$

# The following ports must be installed:
#
# python-2.7          interpreted object-oriented programming language
# py-libdnet          python interface to libdnet
# scapy               powerful interactive packet manipulation in python

.if ! exists(/usr/local/bin/python2) || ! exists(/usr/local/bin/scapy)
regress:
	@echo Install python and the scapy module for additional tests.
	@echo SKIPPED
.endif

PROG =		rip6-cksum
WARNINGS =	yes

REGRESS_TARGETS +=	run-no-cksum
run-no-cksum: ${PROG}
	${SUDO} ./${PROG} -c 0 -w 10 -s 3 -- \
	    python2 -u ${.CURDIR}/sendrecv.py -c 0 -s 3000

.include <bsd.regress.mk>
