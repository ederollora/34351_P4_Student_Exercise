
## Final exercise

### Introduction

This is the final p4 exercise in the course "34351 Access- and Home Networks", the idea is to design an answering machine based on the p4 switch, just like phones nowadays answer automatically to calls when the phone owner is out of office or not available. You will build a switch that answers to ARP, ICMP and DHCP requests.

Although we could discuss the applicability in the real world of implementing an "answering machine" for ARP, ICMP and DHCP, the objective is that you can read protocol specifications, identify headers and understand how these protocols work. Once this study is carried out for each protocol, you can implement the “answering machine” behaviour by, for instance, answering to ARP requests or automatically sending back ICMP replies.


The main objective is to understand the potential of data plane programmability where the student can implement almost any behavior in the switch and parse headers in a very flexible way.


### Tasks

All the tasks (code that you need to add) is always shown along with a **TODO** tag in each ".p4" file..

For instance:

```
// TODO: Add ARP header fields;
```

Before proceeding with the implementation and code addition to the main file (switch.p4), take a look at the **captures** folder. We have included an ARP broadcast

Open the switch.p4 and the **includes** folder (with other p4 files) to follow the instructions denoted from now on.

#### Headers

You need to check several files in the **includes** folder to invertigate which tasks need to be done, especifically:
- arp.p4
- icmp.p4
- dhcp.p4: you only need to define some of the header fields, we actually defined most of them but regarding the **bootp** part, we have left defined some of the last headers. Check the file (there is a link as a hint too ;)) to add the necessary fields.

We recommend that you also check:
- defines.p4: Contains constants that are currently used and others that you could use in your implementation.
- standard_h.p4: This is the main header file to define the standard headers in the main (switch.p4) program, but we also import **arp.p4**, **icmp.p4** and **dhcp.p4** from **switch.p4** (along with **defines.p4**). This file (**standard_h.p4**) will actually define all the standard headers and their fields (Ethernet, IP, TCP, etc.). It is also used to define the name for every header established to be used along the exercise (see `struct headers { }` code block.

#### MyParser parser block

Regarding the header parsing part, check the `parser MyParser(){}` block. You will need to define the parsing of headers (all of them, starting from Ethernet until you get to DHCP) just as you have done for the basic, calculator and source routing exercises. Use these parsing code from the past exercises as a reference point. Please note that we have left a parsing state named `parse_bootp`. This also needs to be included but you will need to see which field from the underlying protocol brings you to this parsing state.

#### MyVerifyChecksum control block

Nothing to do here :)

#### MyIngress control block

This is the most important (task-wise) block of the exercise. Here you will have a total of 3 **tables**, 4 **actions**, and 1 **apply** block defined. The apply block is the block of code that will start the execution of your control block, which sometimes is just program into one table (or action) or another. this means that you need to check, inside the **apply** block, which kind of packet you are parsing (is it an ARP packet? an ICMP packet? a DHCP packet? None of those?) and then, depending on the kind of packet, you need to apply one table or another. For example, if your packet is an ARP request then the ARP table is the one to be applied. If you need more information, there is always an explanation with (maybe) hints and additional information in each **TODO** block of comment. Checking the rules to be pushed in each table (**s1-runtime.json**, **s2-runtime.json**, **s3-runtime.json**) will also help you to understand the relationship between the tables, the actions and the rules.

#### MyEgress control block

Nothing to do here

#### MyComputeChecksum control block

Although you don't need to do anything here, try to understand what is actually going on in this block, both for Ipv4 and ICMP. Understanding what is calculated here, will help you answering the questions for the final exercise.


#### MyDeparser control block

You need to emit all the headers you have parsed in **MyParser**, although we have left the DHCP options already there.


#### How to test that your implementation works

First of all you need to make sure that your code compiles. The way to do this is to navigate to the final exercise folder using the Linux terminal (the actual folder may be different for you):

```bash
cd /home/student/34351_Final_Exercise_lecturers/exercises/4_answering_machine
```

And now run the following command:
```bash
make build
```

If there is an error in the output, read carefully the error information and try to fix it on your own. But you can always ask us your doubts.

To run the exercise run the following command in the root folder of the final exercise:
```bash
make
```

Sometimes, when you run `make` the execution fails because your P4 program was incorrect and needs fixing or because your Mininet script is wrong. In this case run the following command:
```bash
make clean
```
With he command above we reset all the virtual interfaces and links and also clean all the p4 compiled code and logs.


To test if the switch is correctly answering to the ARP, ICMP and DHCP requests fist open a terminal for a host, say host 1 (**h1**). To do this make sure you run `make` in the final exercise folder and make sure that Mininet is up and running (i.e. no errors were found when running `make`):

```bash
mininet> xterm h1
```

Now a new terminal will open. This terminal lets you control h1 directly as if you were running command on the host itself. Run the commands below to test each protocol:

Test ARP:
```bash
sudo arping -I intfName -c targetIpAddress
```
In particular, for h1 terminal we want to discover h2´s mac address:
```bash
sudo arping -I h1-eth0 -c 1 10.0.2.2
ARPING 10.0.2.2
42 bytes from 00:00:00:00:02:02 (10.0.2.2): index=0 time=11.243 msec

--- 10.0.2.2 statistics ---
1 packets transmitted, 1 packets received,   0% unanswered (0 extra)
rtt min/avg/max/std-dev = 11.243/11.243/11.243/0.000 ms.2.2
```

Now, to test ICMP, we will use the `ping` command:
```bash
ping -s 40 targetIpAddress
```
In particular, for h1 terminal we want send the ICMP echo request to h2, but our switch will actually reply to this. Make sure that h2 is not responding by capturing (ONLY) h2's interface in Wireshark. You should see no traffic from h2 but still the `ping` should still work. You should also capture h1's interface to see that the ping is actually being answered. Sometimes Wireshark could complain that "No response was found" but actually for the response coming next, wireshark tells you there is a request in frame N. This may be a bug because if you export the captured traffic to a file (save it) and reopen it, Wireshark will correctly correlate the request and responses. It seems to be a runtime bug, but don't worry this will not affect to the exercise as you can still see in your terminal that requests are being responded (if you implement it correctly ;) ). We actually have provided you with an ICMP checksum function so Wireshark should say that the checksum of the response is correct. :


To test DHCP traffic, locate the script **dhcp.py** (we have done this for you, no need to add anything) and run it in this way from h1:
```bash
sudo python scripts/dhcp.py intfName
```
In particular, run it in this way and you should see and output like this if everything went well:
```bash
sudo python scripts/dhcp.py h1-eth0

CHECKING A PACKET
Message-Type:           [1]
CHECKING A PACKET
Message-Type:           [2]
Server:          10.0.0.1 [00:00:00:00:02:02]
DHCP IP:         10.0.1.1
DHCP options:
        message-type: 2
        subnet_mask: 255.255.255.0
        router: 10.0.0.1
        domain: ahn.course.dtu.dk
        lease_time: 167772161
        server_id: 10.0.0.1
CHECKING A PACKET
Message-Type:           [3]
CHECKING A PACKET
Message-Type:           [5]
Server:          10.0.0.1 [00:00:00:00:02:02]
DHCP IP:         10.0.1.1
DHCP options:
        message-type: 5
        subnet_mask: 255.255.255.0
        router: 10.0.0.1
        domain: ahn.course.dtu.dk
        lease_time: 167772161
        server_id: 10.0.0.1

```

What you see in the output is that we have printed messages of type 2 and 5 (you will need to discover what this means) but not 1 and 3. What you see from the output is actually the answer from the switch. Even though we are testing DHCP traffic, you should now that this will actually not configure the interface in the host. The ARP traffic tested will also not populate the ARP table of the host.

> Check the captures folder to see an example of the traffic exchange (ARP, ICMP and DHCP) that you should observe when testing each protocol. The DHCP catpture has an additional INFORM and ACK exchange that need not to be implemented nor taken into consideration. They are there for informational purposes, in case you wonder what and INFORMATIONAL request looks like and how the server answers to that.
