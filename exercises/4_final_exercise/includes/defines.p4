
typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

const bit<16> ARP_REQ = 0x0001;
const bit<16> ARP_REP = 0x0002;

const bit<16> TYPE_ARP  = 0x0806;
const bit<16> TYPE_IPV4 = 0x0800;

const bit<8> TYPE_ICMP = 0x01;
const bit<8> TYPE_TCP  = 0x06;
const bit<8> TYPE_UDP  = 0x11;

const bit<8> ICMP_REQ = 0x08; // type of ICMP (request)
const bit<8> ICMP_REP = 0x00; // type of ICMP (reply)

const bit<16> DHCP_SERVER = 0x0043; // port 67 in UDP
const bit<16> DHCP_CLIENT = 0x0044; // port 68 in UDP

const bit<8> BOOTREQUEST = 0x01;
const bit<8> BOOTREPLY = 0x02;

const bit<8> DHCPDISCOVER = 0x01;
const bit<8> DHCPREQUEST = 0x03;


// FAKE DHCP server identifiers. This is taken now from the table
const macAddr_t FK_MAC_DHCP_S = 0x000000010101;
const ip4Addr_t FK_IP_DHCP_S  = 0x0A000001;

// DHCP Offer constants. This is taken now from the table
const ip4Addr_t PROP_IP = 0x0A000004;// yIpAddr, 10.0.0.4

// Some Constants for DHCP Offer//ACK

// DHCP OPTION 53
// DHCP OFFER/ACK
const bit<8> DHCPOFFER = 0x02;
const bit<8> DHCPACK= 0x05;

// DHCP OPTION 1
// Subnet Mask
const ip4Addr_t DHCP_MASK = 0xFFFFFF00; // 255.255.255.0

// DHCP OPTION 3
// Router IP
const ip4Addr_t ROUTER_IP = 0x0A000001; // 10.0.0.1

// DHCP OPTION 6
// Domain Name Server
const ip4Addr_t DNS_IP_1 = 0x08080808; // 8.8.8.8
const ip4Addr_t DNS_IP_2 = 0x08080404; // 8.8.4.4

// DHCP OPTION 15
// Name server:
// Convert the string above to hex (ascii -> hex)
// ahn.course.dtu.dk = 61 68 6e 2e 63 6f 75 72 73 65 2e 64 74 75 2e 64 6b
// Length in bits for the hex representation: 17 * 8 = 136 bits
const bit<136> DOMAIN = 0x61686e2e636f757273652e6474752e646b;
const bit<8> DOMAIN_LENGTH = 0x11; // Length in bytes, 17.

// DHCP OPTION 51
// IP Address Lease Time (in seconds)
const bit<32> LEASE_TIME = 0x0A000001; // 86400s

// DHCP OPTION 54
// DHCP Server Identifier (ip address in hex)
// This time same as option 3

// Some Constants for DHCP ACK//
// Some constants may have already been defined in Offer constants
