header bootp_t {
    // TODO: Add the missing bootp/DHCP message format fields.
    // Hint, check: http://www.tcpipguide.com/free/t_BOOTPMessageFormat.htm
    // Also check: http://www.tcpipguide.com/free/t_DHCPMessageFormat.htm
    // We have kept some of the fields, to ease the process :)
    macAddr_t chAddr;
    bit<80> pad; //chAddr + padding  = 16 bytes
    bit<512> server_host; // 16 bytes
    bit<1024> boot_file;  // 32 bytes
    bit<32> cookie;
}

// DHCP OFFER/ACK options to return as DHCP options after the bootp header
// Types: 53,1,3,6,15,51,54,255

header dhcp_op_53_t{ // DHCP msg type
    bit<8> op;
    bit<8> length_;
    bit<8> type_;
}

header dhcp_op_1_t{ // Subnet Mask
    bit<8> op;
    bit<8> length_;
    bit<32> subnet_mask;
}

header dhcp_op_3_t{ // Router IP
    bit<8> op;
    bit<8> length_;
    bit<32> router;
}

header dhcp_op_6_t{ //Domain Name Servers
    bit<8> op;
    bit<8> length_;
    bit<32> dns_server_1;
    bit<32> dns_server_2; // 32 bits per dns server ip, in this example 2
}

header dhcp_op_15_t{ // Domain name
    bit<8> op;
    bit<8> length_;
    bit<136> domain;
}

header dhcp_op_51_t{
    bit<8> op;
    bit<8> length_;
    bit<32> lease_time;
}

header dhcp_op_54_t{ //DHCP server identifier
    bit<8> op;
    bit<8> length_;
    ip4Addr_t ipAddr;
}

header dhcp_op_255_t{ // end
    bit<8> opt_end;
}

//Fixed length headers for this final_exercise in order to extract the payload
// of the DHCP DISCOVER and the REQUEST.
header dhcp_disc_p_t{ // rest of discover payload
    bit<8> rest_disc_h;
}

header dhcp_req_p_t{ // rest of request payload
    bit<152> rest_req_h;
}
