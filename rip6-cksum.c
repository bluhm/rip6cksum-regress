/*	$OpenBSD$	*/
/*
 * Copyright (c) 2019 Alexander Bluhm <bluhm@openbsd.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <errno.h>
#include <err.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <netinet/in.h>

#include <sys/types.h>
#include <sys/socket.h>

void __dead usage(void);

void __dead
usage(void)
{
	fprintf(stderr, "rip6-cksum [-es] [-c ckoff] [-w wait]\n"
	    "    -c ckoff   set checksum offset within rip header\n"
	    "    -e         expect error when setting ckoff\n"
	    "    -s         send packet on socket\n"
	    "    -w wait    wait for packet on socket, timeout in seconds\n"
	);
	exit(1);
}

const struct in6_addr loop6 = IN6ADDR_LOOPBACK_INIT;
int
main(int argc, char *argv[])
{
	int s, ch, eflag, ckoff, sflag, wait;
	const char *errstr;
	struct sockaddr_in6 sin6;

	eflag = ckoff = sflag = wait = 0;
	while ((ch = getopt(argc, argv, "c:esw:")) != -1) {
		switch (ch) {
		case 'c':
			ckoff = strtonum(optarg, INT_MIN, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "ckoff is %s: %s", errstr, optarg);
			break;
		case 'e':
			eflag = 1;
			break;
		case 's':
			sflag = 1;
			break;
		case 'w':
			wait = strtonum(optarg, INT_MIN, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "wait is %s: %s", errstr, optarg);
			break;
		default:
			usage();
		}
	}
	argc -= optind;
	argv += optind;
	if (argc) {
		fprintf(stderr, "too many arguments\n");
		usage();
	}

	s = socket(AF_INET6, SOCK_RAW, 255);
	if (s == -1)
		err(1, "socket raw");
	memset(&sin6, 0, sizeof(sin6));
	sin6.sin6_family = AF_INET6;
	sin6.sin6_addr = loop6;
	if (bind(s, (struct sockaddr *)&sin6, sizeof(sin6)) == -1)
		err(1, "bind ::1");

	if (ckoff) {
		if (setsockopt(s, IPPROTO_IPV6, IPV6_CHECKSUM, &ckoff,
		     sizeof(ckoff)) == -1) {
			if (!eflag)
				err(1, "setsockopt ckoff");
		} else {
			if (eflag) {
				errno = 0;
				err(1, "setsockopt ckoff");
			}
		}
	}

	return 0;
}
