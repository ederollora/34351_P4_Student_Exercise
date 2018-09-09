header icmp_t{
    // TODO: Add ICMP fields
    // The names of the variables can eb any, but check the "update_checksum" function
    // regarding ICMP to see which names we picked and use those.
}


header icmp_ts_t{
    // TODO: looks like unix hosts insert a timestamp between the ICMP header
    // and the payload. Set the correct size for this field. Check the pcap file to
    // discover the size of this field. Remeber that the size in p4 fields
    // is always in bits.
    bit</*Size in bits*/> timestamp;
}

header icmp_p_t{
    // TODO: When you finish implementing the "ICMP answering machine" we will
    // use the following command to check if the ICMP implementation works:
    // $ root@p4:~/path# ping -s 40 destination_ip
    // Investigate and discover what that 40 means, you can check both the pcap
    // file of the man page for ping. But the pcap file can be more interactive
    // to discover how the number 40 relates to the size of the ICMP requests
    // Hint: the timestamp seen before is actually excluded from this 40 number
    // Therefore, set the correct bit size for this field based on what you
    // discover about the number 40 seen above. 
    bit</*Size in bits*/> payload;
}
