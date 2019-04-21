#!/usr/local/bin/python2.7

import os
from scapy.all import *
from struct import pack
import getopt, sys

def usage():
	print "raw6-sendrecv [-h] [-c ckoff] [-s sendsz]"
	print "    -c ckoff   set checksum offset within payload"
	print "    -s sendsz  set payload size"
	exit(1)

opts, args = getopt.getopt(sys.argv[1:], "c:hs:")

ip = IPv6(src="::1", dst="::1", nh=255)

for o, a in opts:
	if o == "-c":
		ckoff = int(a)
	elif o == "-s":
		sendsz = int(a)
	else:
		usage()

payload = "";
if sendsz is not None:
	for i in range(sendsz):
		payload += chr(i & 0xff)
	print "payload length is", len(payload)

if ckoff is not None:
	payload = payload[:ckoff] + pack("xx") + payload[ckoff+2:]
	cksum = in6_chksum(255, ip, payload)
	print "calculated checksum is", cksum
	payload = payload[:ckoff] + pack("!H", cksum) + payload[ckoff+2:]

req=ip/payload
# as we are sending from ::1 to ::1 we sniff our own packet as answer
# send it twice, ignore the first answer, interpret the second
p=[req,req]
ans=sr(p, iface="lo0")
print ans
res=ans[0][1][1]
res.show()

cksum = in6_chksum(255, res, res.payload.load)
print "received checksum is", cksum
if ckoff is not None and cksum != 0:
	print "received invalid checksum", cksum
	exit(1)
