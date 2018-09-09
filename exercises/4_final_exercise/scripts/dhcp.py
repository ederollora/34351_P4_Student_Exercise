#!/usr/bin/env python2
import logging
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)
from scapy.all import *
import threading
import sys

def check_packet(p):
    dhcp = p.getlayer(DHCP)
    bootp = p.getlayer(BOOTP)
    print("CHECKING A PACKET")
    print "Message-Type:\t\t[%s]" % (str(dhcp.options[0][1]))
    for opt in dhcp.options:
        if opt[0] == "message-type" and (opt[1] == 2 or opt[1] == 5):
            eth     = p.getlayer(Ether)
            bootp   = p.getlayer(BOOTP)
            print "Server:\t\t %s [%s]" % (bootp.siaddr, eth.src)
            print "DHCP IP:\t %s" % bootp.yiaddr
            print_dhcp(dhcp)

            if(opt[1] == 2):
                send_request(p)
            return

def print_dhcp(dhcp):
    print "DHCP options:"
    for opt in dhcp.options:
        if opt != 'pad' and opt != 'end':
            if isinstance(opt,str):
                print "\t%s" % opt
            elif len(opt) == 2:
                print "\t%s: %s" % opt

def send_discover():
    eth     = Ether(dst='ff:ff:ff:ff:ff:ff', src=mac, type=0x0800)
    ip      = IP(src='0.0.0.0', dst='255.255.255.255')
    udp     = UDP(dport=67,sport=68)
    bootp   = BOOTP(op=1, xid=0x1234, chaddr=mac_raw[1])

    dhcp = DHCP(options=[('message-type','discover'), ('end')])
    discover = eth / ip / udp / bootp / dhcp
    sendp(discover, iface=iface, verbose=0)

def send_request(packet):

    myip, sip, xid = 0, 0, 0;

    dhcp = packet.getlayer(DHCP)
    for opt in dhcp.options:
        if opt[0] == "message-type" and opt[1] == 2:
            bootp = packet.getlayer(BOOTP)
            myip=bootp.yiaddr
            sip=bootp.siaddr
            xid=bootp.xid

    eth = Ether(src=mac,dst="ff:ff:ff:ff:ff:ff", type=0x0800)
    ip = IP(src="0.0.0.0",dst="255.255.255.255")
    udp = UDP(dport=67, sport=68)
    bootp = BOOTP(op=1, xid=xid, chaddr=mac_raw[1])
    dhcp = DHCP(options=[
            ("message-type","request"), # 3 bytes
            ("server_id",sip),          # 6 bytes
            ("requested_addr",myip),    # 6 bytes
            ("param_req_list",          # 6 bytes
                chr(scapy.all.DHCPRevOptions["subnet_mask"][0]),
                chr(scapy.all.DHCPRevOptions["router"][0]),
                chr(scapy.all.DHCPRevOptions["name_server"][0]),
                chr(scapy.all.DHCPRevOptions["domain"][0])
                #chr(15)
            ), #("param_req_list","pad"),
            "end"] # 1 byte
        )
    request = eth/ip/udp/bootp/dhcp
    sendp(request, iface=iface, verbose=0)

if len(sys.argv) != 2:
    print "USAGE: %s <interface>" % sys.argv[0]
    exit(1)
else:
    iface = sys.argv[1]

req_sent = False
mac = get_if_hwaddr(iface)
mac_raw = get_if_raw_hwaddr(iface)
filter  = "udp and port 68 and port 67"
timeout = 3

t = threading.Timer(0.2,send_discover)
t.start()

sniff(filter=filter,prn=check_packet,timeout=timeout)
