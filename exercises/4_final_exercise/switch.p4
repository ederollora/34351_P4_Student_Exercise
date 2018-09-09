/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

#include "includes/defines.p4"
#include "includes/arp.p4"
#include "includes/icmp.p4"
#include "includes/dhcp.p4"
#include "includes/standard_h.p4"


/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        // TODO: Start here parsing headers. Check basic.p4 to have an idea on
        // how to do the parsing. Remember to support parsing for
        // Ethernet, IPv4, TCP, UDP, ARP and ICMP. (Although we support TCP,
        // you might actually not use it even if you parse it)
        // DHCP (bootp + DHCP Options) is already done below.
    }

    state parse_bootp {
        packet.extract(hdr.bootp);
        packet.extract(hdr.aux_op_53);
        transition select(hdr.aux_op_53.type_) {
            // We extract the rest of the DHCP options but will not use
            // or check them afterwards
            DHCPDISCOVER: parse_disc_p;
            DHCPREQUEST : parse_req_p;
            default: accept;
        }
    }

    // These two parsing states below have a very simple function: Extract the
    // payload of DISCOVER and REQUEST DHCP options so that they are not included
    // as payload afterwards

    state parse_disc_p {
        // We extract DHCPDISCOVER payload, but do nothing with it
        // We assume it is fixed as we have defined payload in
        // the dhcp.py script
        packet.extract(hdr.dhcp_disc_p);
        transition accept;
    }

    state parse_req_p {
        // We extract DHCPREQUEST payload, but do nothing with it
        // Likewise for this payload
        packet.extract(hdr.dhcp_req_p);
        transition accept;
    }

}


/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {
        // Don't worry about this part
    }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action drop() {
        mark_to_drop();
    }

    // This action is the same as basic.p4
    // It is here to support IPv4 forwarding
    // All is done so go further below ;)
    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    action arp_answer(macAddr_t addr) {

        // TODO: Set egress_spec (i.e. outgoing port), and think about the
        // port it needs to go out to

        // TODO: Modify the Ethernet fields that need to be modified for an ARP
        // answer. Check the pcap file for ARP to know which fields change
        // from request to request

        // TODO: Modify the necessary ARP fields to return a valid ARP answer
        // Hint: Analyse the ARP pcap file
    }

    table arp_tb {
        key = {
            // TODO: add key to match in this table
        }
        actions = {
            // TODO: Add the action when there is a hit in this table
            drop;
            NoAction;
        }

        size = 1024;
        default_action = NoAction();
    }

    action icmp_answer() {

        // TODO: Set egress_spec (i.e. outgoing port), and think about the
        // port it needs to go out to

        // TODO: Modify the Ethernet fields that need to be modified for an ICMP
        // answer. Check the pcap file for ICMP to know which fields change
        // from request to request. You might need an auxilary variable to
        // temporarily hold a value and be able to "swap" fields.

        // TODO: Do likewise for IP, identify which fields need to change. Not
        // all fields change from request to response.

        // TODO: Do likewise for ICMP, identify which fields need to change.
        // Specially in this case there might be very few that change AND
        // don't worry about the checksum field. Leave it as it is.

        hdr.icmp.chk = 0;
    }

    action send_dhcp_offer_ack(macAddr_t mac_s, ip4Addr_t ip_s, ip4Addr_t ip_c) {

        // TODO: Set egress_spec (i.e. outgoing port), and think about the
        // port it needs to go out to

        // Leave these two as is. We run these two statements because although
        // we extract those two headers, we actually discard them as we don't
        // need them for the answer.
        hdr.dhcp_disc_p.setInvalid();
        hdr.dhcp_req_p.setInvalid();

        // TODO: Modify the Ethernet fields that need to be changed for a DHCP
        // OFFER/ACK. Check the pcap file for DHCP to know which fields change
        // from request to response

        // TODO: Do likewise for IP, identify which fields need to change. Not
        // all fields change from request to response. Actually check the pcap
        // for DHCP since there might be less changing fields at Ethernet and IP
        // layers compared to ARP and ICMP.

        // TODO: Modify the necessary fields for the UDP layer. Not too
        // much to do ;)

        //Bootp & DHCP options
        hdr.bootp.op = BOOTREPLY;
        hdr.bootp.yIpAddr = ip_c; //IP proposed for the client
        hdr.bootp.sIpAddr = ip_s;
        hdr.bootp.rIpAddr = ip_s;
        hdr.bootp.chAddr = hdr.ethernet.srcAddr;

        //Options
        hdr.dhcp_op_53.setValid();
        hdr.dhcp_op_1.setValid();
        hdr.dhcp_op_3.setValid();
        hdr.dhcp_op_6.setValid();
        hdr.dhcp_op_15.setValid();
        hdr.dhcp_op_51.setValid();
        hdr.dhcp_op_54.setValid();
        hdr.dhcp_op_255.setValid();

        // TYPE 53
        hdr.dhcp_op_53.op = 53;
        hdr.dhcp_op_53.length_ = 1;
        // TODO: Check the "hdr.aux_op_53.type_" field and assign the proper value
        // to "hdr.dhcp_op_53.type_". The value to assign to "hdr.dhcp_op_53.type_"
        // is what the answer from the switch will be. Check the constants in the
        // "defines.p4" file (e.g. DHCPDISCOVER, DHCPACK ...). You can use these
        // constants to check and assign values. In other words, depending on the
        // value of "hdr.aux_op_53.type_" then a certain value needs to be
        // assigned to "hdr.dhcp_op_53.type_".

        // TYPE 1
        hdr.dhcp_op_1.op = 1;
        hdr.dhcp_op_1.length_ = 4;
        hdr.dhcp_op_1.subnet_mask = DHCP_MASK;

        // TYPE 3
        hdr.dhcp_op_3.op = 3;
        hdr.dhcp_op_3.length_ = 4;
        hdr.dhcp_op_3.router = ROUTER_IP;

        // TYPE 6
        hdr.dhcp_op_6.op = 6;
        hdr.dhcp_op_6.length_ = 8;
        hdr.dhcp_op_6.dns_server_1 = DNS_IP_1;
        hdr.dhcp_op_6.dns_server_2 = DNS_IP_2;

        // TYPE 15
        hdr.dhcp_op_15.op = 15;
        hdr.dhcp_op_15.length_ = DOMAIN_LENGTH;
        hdr.dhcp_op_15.domain = DOMAIN;

        // TYPE 51
        hdr.dhcp_op_51.op = 51;
        hdr.dhcp_op_51.length_ = 4;
        hdr.dhcp_op_51.lease_time = LEASE_TIME;

        // 6 bytes
        hdr.dhcp_op_54.op = 54;
        hdr.dhcp_op_54.length_ = 4;
        hdr.dhcp_op_54.ipAddr = ROUTER_IP;

        hdr.dhcp_op_255.opt_end = 0xFF; // always 0xFF for end option

        // We update the length in IPv4 header and UDP header to reflect
        // the actual bytes from their layer and on.
        hdr.udp.length_ = 240+57+8; // DHCP opts+Bootp+UDP
        hdr.ipv4.totalLen = hdr.udp.length_ + 20; //All before + IP
    }

    table dhcp_tb {
        key = {
            hdr.bootp.op: exact;
        }
        actions = {
            send_dhcp_offer_ack;
            drop;
            NoAction;
        }

        size = 1024;
        default_action = NoAction();
    }

    apply {

        // TODO: This is the key part of the application
        // you have to check if you have received:
        // * an ARP request
        // * an ICMP request
        // * a DHCP DISCOVER or REQUEST (Hint: base it on a UDP field)
        // Check defines.p4 for constants.
        // Hint: pseudocode as reference:
        //
        // if (ARP_header is valid && ARP type is REQUEST){
        //      apply the ARP table;
        // } else if (ICMP ...)
        //      for ICMP you don't need a table but you do apply a function
        // } else if DHCP)
        //      apply DHCP table
        // } else {
        //      apply the Ipv4 forward table;
        // }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    	update_checksum(
    	    hdr.ipv4.isValid(),{
                hdr.ipv4.version,
    	        hdr.ipv4.ihl,
                hdr.ipv4.dscp,
                hdr.ipv4.ecn,
                hdr.ipv4.totalLen,
                hdr.ipv4.identification,
                hdr.ipv4.flags,
                hdr.ipv4.fragOffset,
                hdr.ipv4.ttl,
                hdr.ipv4.protocol,
                hdr.ipv4.srcAddr,
                hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16
        );
        update_checksum(
            hdr.icmp.isValid(),{
                hdr.icmp.tp,
                hdr.icmp.code,
                hdr.icmp.id,
                hdr.icmp.seqNum,
                hdr.icmp_ts.timestamp,
                hdr.icmp_p.payload },
            hdr.icmp.chk,
            HashAlgorithm.csum16
        );
    }
}


/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        // TODO: emit all the headers you have parsed in "MyParser"
        // To ease the implementation, we have left the DHCP options but
        // you still need to emit the "bootp" part of the DHCP header
        packet.emit(hdr.dhcp_op_53);
        packet.emit(hdr.dhcp_op_1);
        packet.emit(hdr.dhcp_op_3);
        packet.emit(hdr.dhcp_op_6);
        packet.emit(hdr.dhcp_op_15);
        packet.emit(hdr.dhcp_op_51);
        packet.emit(hdr.dhcp_op_54);
        packet.emit(hdr.dhcp_op_255);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
