#!/usr/local/bin/python2.7
# $OpenBSD$

import os
from scapy.all import *
from struct import pack
import getopt, sys

def usage():
	print "raw6-sendrecv [-hi] [-c ckoff] [-s sendsz]"
	print "    -c ckoff   set checksum offset within payload"
	print "    -h         help, show usage"
	print "    -i         expect icmp6 error message as response"
	print "    -s sendsz  set payload size"
	exit(1)

opts, args = getopt.getopt(sys.argv[1:], "c:his:")

ip = IPv6(src="::1", dst="::1", nh=255)

ckoff = None
icmp = False
sendsz = None
for o, a in opts:
	if o == "-c":
		ckoff = int(a)
	elif o == "-i":
		icmp = True
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
ans=sr(p, iface="lo0", timeout=10)
print ans
res=ans[0][1][1]
res.show()

print "response protocol next header is", res.nh
if icmp:
	if res.nh != 58:
		print "response wrong protocol, expected icmp6"
		exit(1)
	print "response icmp6 type is", res.payload.type
	if res.payload.type != 4:
		print "response wrong icmp6 type, expected parameter problem"
		exit(1)
	exit(0)

if res.nh != 255:
	print "response with wrong protocol, expected 255, got"
	exit(1)

cksum = in6_chksum(255, res, res.payload.load)
print "received checksum is", cksum
if ckoff is not None and cksum != 0:
	print "received invalid checksum", cksum
	exit(1)
