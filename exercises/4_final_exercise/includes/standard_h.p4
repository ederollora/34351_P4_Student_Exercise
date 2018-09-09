


//STANDARD HEADERS
header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16> etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    // Diffserv -> DSCP + ECN
    bit<6>    dscp;
    bit<2>    ecn;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<3>  res;
    bit<3>  ecn;
    bit<6>  ctrl;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> length_;
    bit<16> checksum;
}

header aux_t{
    macAddr_t macAddr;
    ip4Addr_t ipAddr;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t    ethernet;
    arp_t         arp;
    ipv4_t        ipv4;
    icmp_t        icmp;
    icmp_data_t   icmp_data;
    tcp_t         tcp;
    udp_t         udp;
    bootp_t       bootp;
    // You need this aux_op_53 header to extract always the first
    // 3 bytes right after the bootp header. This 3 bytes will extract
    // the header type 53, which defines the type of DHCP message
    dhcp_op_53_t  aux_op_53;
    dhcp_disc_p_t dhcp_disc_p;
    dhcp_req_p_t  dhcp_req_p;
    aux_t         aux;
    //DHCP response: Offer/ACK
    dhcp_op_53_t  dhcp_op_53;
    dhcp_op_1_t   dhcp_op_1;
    dhcp_op_3_t   dhcp_op_3;
    dhcp_op_6_t   dhcp_op_6;
    dhcp_op_15_t  dhcp_op_15;
    dhcp_op_51_t  dhcp_op_51;
    dhcp_op_54_t  dhcp_op_54;
    dhcp_op_255_t dhcp_op_255;

}
