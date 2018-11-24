
## Final project

### Introduction

In this final project you are expected to mix both the ARP and the ICMP exercises into one combined project. The idea is that, taking into account the table shown below, switches or hosts answer to ARP and ICMP requests. The idea is hosts send first ARP requests, get the answer and ping afterwards. The ARP part is automated when pinging if no record is found in the ARP table of the sender host.


### Tasks


#### Project structure

Form your own project directory base. You can copy the files from a past exercise of the final project and start editing from there. Alternatively you can create and edit the files in the directory. You might want to start from scratch adding files for a better learning experience but it is up to you (headers.p4, parser.p4, etc.).

#### P4 code

In terms of P4 content, remember the header structure from the ARP and ICMP final exercise. If you correctly programmed the past exercise you can reuse the header structure. Besides, you can reuse the header parsing part. Now, the Ingress and Egress, apart from the table management will actually differ. For instance, you might have used a table to do the ICMP section of the past exercise but you will need one now. 

#### Table

The application you create needs to follow the following table.

| Source Host | Destination Host |                  ARP                 |                  ICMP                 |
|:-----------:|:----------------:|:------------------------------------:|:-------------------------------------:|
|      H1     |        H2        | Switch 1 (S1) answers to ARP request |  Host 2 (H2) answers to ICMP request  |
|      H1     |        H3        |  Host 3 (H3) answers to ARP request  | Switch 1 (S1) answers to ICMP request |
|      H2     |        H1        |  Host 1 (H1) answers to ARP request  | Switch 2 (S2) answers to ICMP request |
|      H2     |        H3        | Switch 2 (S2) answers to ARP request |  Host 3 (H3) answers to ICMP request  |
|      H3     |        H1        | Switch 3 (S3) answers to ARP request | Switch 3 (S3) answers to ICMP request |
|      H3     |        H2        |  Host 2 (H2) answers to ARP request  |  Host 2 (H2) answers to ICMP request  |


#### Networking parameters

It is very important to change some networking parameters in order to make the table above make sense. First, as per previous exercises, hosts have always been in different networks (i.e. H1's IP is 10.0.1.1/24 while H2's is 10.0.2.2/24. Thus being in different networks). So that ARP requests/answers go host-to-host you need to change the IP addressing of H2 and H3. We will probably automatize this in next years, but for now, you will need to do this manually every time you build the network.

For instance, to add H2 or H3 to the network of H1 you will need to run these commands.

You can open an xterm and run this:

```
mininet> xterm h2
root@p4:~/# ifconfig h2-eth0 10.0.1.2 netmask 255.255.255.0 broadcast 255.255.255.255
```
or much easier, from mininet:

```
mininet> h2 ifconfig h2-eth0 10.0.1.2 netmask 255.255.255.0 broadcast 255.255.255.255
```
Do likewise for H3. Open an xterm and :

```
mininet> xterm h3
root@p4:~/# ifconfig h3-eth0 10.0.1.3 netmask 255.255.255.0 broadcast 255.255.255.255
```

or much easier, from mininet:

```
mininet> h3 ifconfig h3-eth0 10.0.1.3 netmask 255.255.255.0 broadcast 255.255.255.255
```

Hopefully when you do this, the routing table of hosts has also been updated (~/$ route -n). Now the past gateway will not be used to contact other hosts (makes sense as all hosts are under the same network address space). Check, for instance, the output from H3 when we run the commands above:

```
mininet> h3 ifconfig h3-eth0 10.0.1.3 netmask 255.255.255.0 broadcast 255.255.255.255
mininet> h3 ifconfig
h3-eth0   Link encap:Ethernet  HWaddr 00:00:00:00:03:03  
          inet addr:10.0.1.3  Bcast:255.255.255.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:7 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:730 (730.0 B)  TX bytes:348 (348.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

mininet> h3 route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.0.1.0        0.0.0.0         255.255.255.0   U     0      0        0 h3-eth0
```

4) There are some important considerations that will help you to complete this final project, here are some tips:

- Looking to the table above, is much easier to concentrate first on the ICMP part. Therefore try to solve first the switch/hosts answering requirements regarding ICMP. Once it works you can concentrate in the ARP part.

- If you start from the ICMP part, before pinging, you first need to populate the ARP table of hosts by hand (as if the ARP part of this exercise already worked). To do this, run the following command in H1:

```
mininet> h1 arp -s 10.0.1.2 00:00:00:00:02:02
mininet> h1 arp -s 10.0.1.3 00:00:00:00:03:03
```

In H2:

```
mininet> h1 arp -s 10.0.1.1 00:00:00:00:01:01
mininet> h1 arp -s 10.0.1.3 00:00:00:00:03:03
```

In H3:

```
mininet> h1 arp -s 10.0.1.1 00:00:00:00:01:01
mininet> h1 arp -s 10.0.1.2 00:00:00:00:02:02
```


- IMPORTANT: Consider that to decide whether a switch or a host answers to a ping (ICMP request) there needs to be a table that signals this action. For instance if a record is found in the table, a switch will answers and if no record is found, the packet will be matched against further tables (e.g. ipv4_forward) in order to forward it properly. As you see, you will also need the very basic logic from the first exercise in order to know how to forward packets. Remember though that hosts are in the same network so no MAC swapping is needed between P4 switches (you can keep remove the MAC stuff from the forward action), just forwarding to the correct port.

- To accomplish the ARP part you can follow the same design principles you did in the ICMP part. Although switches normally broadcast ARP requests, you can forward the request to the correct host as you know each host's location and you can look into the Target Protocol Address (IP of the host you want to know the MAC from) from the ARP request. Thus you may need another table for Ethernet forwarding in regards to the field mentioned before. You can also look into packet replication in the BMv2 switch to properly "broadcast" packets though this can be very time consuming (ask us any further questions if you want to go this way), but we recommend just forwarding requests to the proper hosts based on the TPA.

- In order to accomplish this exercise, you will need to heavily modify and create new runtime rules. Make sure you understand how rules are pushed and modify the rules you have used in previous exercises to meet the requirements of this current exercise (tables might be different, actions may have different arguments, etc.)
