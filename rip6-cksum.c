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

#include <sys/select.h>
#include <sys/types.h>
#include <sys/socket.h>

void __dead usage(void);

void __dead
usage(void)
{
	fprintf(stderr, "rip6-cksum [-es] [-c ckoff] [-w waitpkt]\n"
	    "    -c ckoff   set checksum offset within rip header\n"
	    "    -e         expect error when setting ckoff\n"
	    "    -s sendsz  send packet of given size on socket\n"
	    "    -w waitpkt wait for packet on socket, timeout in seconds\n"
	);
	exit(1);
}

const struct in6_addr loop6 = IN6ADDR_LOOPBACK_INIT;
int
main(int argc, char *argv[])
{
	int s, ch, eflag, cflag, sflag, wflag;
	int ckoff;
	size_t sendsz;
	time_t waitpkt;
	const char *errstr;
	struct sockaddr_in6 sin6;

	eflag = cflag = sflag = wflag = 0;
	while ((ch = getopt(argc, argv, "c:es:w:")) != -1) {
		switch (ch) {
		case 'c':
			ckoff = strtonum(optarg, INT_MIN, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "ckoff is %s: %s", errstr, optarg);
			cflag = 1;
			break;
		case 'e':
			eflag = 1;
			break;
		case 's':
			sendsz = strtonum(optarg, 0, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "sendsz is %s: %s", errstr, optarg);
			sflag = 1;
			break;
		case 'w':
			waitpkt = strtonum(optarg, 0, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "waitpkt is %s: %s", errstr, optarg);
			wflag = 1;
			break;
		default:
			usage();
		}
	}
	argc -= optind;
	argv += optind;
	if (argc) {
		fprintf(stderr, "%s: too many arguments\n", getprogname());
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
	if (connect(s, (struct sockaddr *)&sin6, sizeof(sin6)) == -1)
		err(1, "connect ::1");

	if (cflag) {
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

	if (wflag) {
		fd_set fds;
		struct timeval to;

		FD_ZERO(&fds);
		FD_SET(s, &fds);
		to.tv_sec = waitpkt;
		to.tv_usec = 0;
		switch (select(s + 1, &fds, NULL, NULL, &to)) {
		case -1:
			err(1, "select");
		case 0:
			errx(1, "timeout");
		}
	}

	if (sflag) {
		char *buf;

		buf = malloc(sendsz);
		if (buf == NULL)
			err(1, "malloc sendsz");
		memset(buf, 0, sendsz);
		if (send(s, buf, sendsz, 0) == -1)
			err(1, "send");
		free(buf);
	}

	return 0;
}
