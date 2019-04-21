#!/usr/local/bin/python2.7

from struct import pack
import os
from scapy.all import *

ip=IPv6(src="::1", dst="::1", nh=255)
pay=pack("xx")
cksum=in6_chksum(255,ip,pay)
print cksum
req=ip/pack("!H",cksum)
# as we are sending from ::1 to ::1 we sniff our own packet as answer
p=[req,req]

ans=sr(p, iface="lo0")

print ans
rep=ans[0][1][1]
rep.show()
print in6_chksum(255,rep,rep.payload.load)
