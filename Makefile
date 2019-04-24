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
	# set socket option IPV6_CHECKSUM to -2, expect error
	${SUDO} ./rip6-cksum -c -2 -e

REGRESS_TARGETS +=	run-error-odd
run-error-odd:
	@echo "\n======== $@ ========"
	# set socket option IPV6_CHECKSUM to 1, expect error
	${SUDO} ./rip6-cksum -c 1 -e

REGRESS_TARGETS +=	run-no-cksum
run-no-cksum:
	# send and receive packet without checksum
	@echo "\n======== $@ ========"
	${SUDO} ./rip6-cksum -s 8 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -r 8 -s 32

REGRESS_TARGETS +=	run-disable-cksum
run-disable-cksum:
	# send and receive packet with explicitly disabled checksum
	@echo "\n======== $@ ========"
	${SUDO} ./rip6-cksum -c -1 -s 8 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -r 8 -s 32

REGRESS_TARGETS +=	run-ckoff-0
run-ckoff-0:
	@echo "\n======== $@ ========"
	# use checksum at offset 0
	${SUDO} ./rip6-cksum -c 0 -s 8 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -c 0 -r 8 -s 32

REGRESS_TARGETS +=	run-ckoff-0-empty
run-ckoff-0-empty:
	@echo "\n======== $@ ========"
	# use checksum at offset 0, but packet is empty, expect icmp
	${SUDO} ./rip6-cksum -c 0 -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -i -s 0

REGRESS_TARGETS +=	run-ckoff-0-short
run-ckoff-0-short:
	@echo "\n======== $@ ========"
	# use checksum at offset 0, but packet is only 1 byte long, expect icmp
	${SUDO} ./rip6-cksum -c 0 -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -i -s 1

REGRESS_TARGETS +=	run-ckoff-0-exact
run-ckoff-0-exact:
	@echo "\n======== $@ ========"
	# use checksum at offset 0, packet is exactly 2 bytes long
	${SUDO} ./rip6-cksum -c 0 -s 2 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -c 0 -s 2

REGRESS_TARGETS +=	run-ckoff-0-long
run-ckoff-0-long:
	@echo "\n======== $@ ========"
	# use checksum at offset 0, packet is 3 bytes long
	${SUDO} ./rip6-cksum -c 0 -s 3 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -c 0 -s 3

REGRESS_TARGETS +=	run-ckoff-2
run-ckoff-2:
	@echo "\n======== $@ ========"
	# use checksum at offset 2
	${SUDO} ./rip6-cksum -c 2 -s 8 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -c 2 -r 8 -s 32

REGRESS_TARGETS +=	run-ckoff-2-empty
run-ckoff-2-empty:
	@echo "\n======== $@ ========"
	# use checksum at offset 2, but packet is empty, expect icmp
	${SUDO} ./rip6-cksum -c 2 -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -i -s 0

REGRESS_TARGETS +=	run-ckoff-2-short-1
run-ckoff-2-short-1:
	@echo "\n======== $@ ========"
	# use checksum at offset 2, but packet is only 1 byte long, expect icmp
	${SUDO} ./rip6-cksum -c 2 -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -i -s 1

REGRESS_TARGETS +=	run-ckoff-2-short-2
run-ckoff-2-short-2:
	@echo "\n======== $@ ========"
	# use checksum at offset 2, but packet is only 2 byte long, expect icmp
	${SUDO} ./rip6-cksum -c 2 -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -i -s 2

REGRESS_TARGETS +=	run-ckoff-2-short-3
run-ckoff-2-short-3:
	@echo "\n======== $@ ========"
	# use checksum at offset 2, but packet is only 3 byte long, expect icmp
	${SUDO} ./rip6-cksum -c 2 -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -i -s 3

REGRESS_TARGETS +=	run-ckoff-2-exact
run-ckoff-2-exact:
	@echo "\n======== $@ ========"
	# use checksum at offset 2, packet is exactly 4 bytes long
	${SUDO} ./rip6-cksum -c 2 -s 4 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -c 2 -s 4

REGRESS_TARGETS +=	run-ckoff-2-long
run-ckoff-2-long:
	@echo "\n======== $@ ========"
	# use checksum at offset 2, packet is 5 bytes long
	${SUDO} ./rip6-cksum -c 2 -s 5 -w -- \
	    python2 -u ${.CURDIR}/raw6-sendrecv.py -c 2 -s 5

${REGRESS_TARGETS}: ${PROG}

.include <bsd.regress.mk>
