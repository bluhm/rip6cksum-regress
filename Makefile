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

REGRESS_TARGETS +=	run-error-negative
run-error-negative:
	@echo "\n======== $@ ========"
	# set socket option IPV6_CHECKSUM to -2 must result in an error
	${SUDO} ./rip6-cksum -c -2 -e

REGRESS_TARGETS +=	run-error-odd
run-error-odd:
	@echo "\n======== $@ ========"
	# set socket option IPV6_CHECKSUM to 1 must result in an error
	${SUDO} ./rip6-cksum -c 1 -e

REGRESS_TARGETS +=	run-no-cksum
run-no-cksum:
	# sending packets without checksum must succeed
	@echo "\n======== $@ ========"
	${SUDO} ./rip6-cksum -s 8 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -s 32

REGRESS_TARGETS +=	run-disable-cksum
run-disable-cksum:
	# explicitly disabling checksum and sending packets must succeed
	@echo "\n======== $@ ========"
	${SUDO} ./rip6-cksum -c -1 -s 8 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -s 32

REGRESS_TARGETS +=	run-ckoff-0
run-ckoff-0:
	@echo "\n======== $@ ========"
	# use checksum at offset 0
	${SUDO} ./rip6-cksum -c 0 -s 8 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -c 0 -s 32

REGRESS_TARGETS +=	run-ckoff-0-empty
run-ckoff-0-empty:
	@echo "\n======== $@ ========"
	# use checksum at offset 0, but packet is empty
	${SUDO} ./rip6-cksum -c 0 -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -i -s 0

REGRESS_TARGETS +=	run-ckoff-2
run-ckoff-2:
	@echo "\n======== $@ ========"
	# use checksum at offset 2
	${SUDO} ./rip6-cksum -c 2 -s 8 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -c 2 -s 32

REGRESS_TARGETS +=	run-ckoff-over
run-ckoff-over:
	@echo "\n======== $@ ========"
	# use checksum at offset 2, but packet is only 
	${SUDO} ./rip6-cksum -c 2 -s 8 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -c 2 -s 32

REGRESS_TARGETS: ${PROG}

.include <bsd.regress.mk>
