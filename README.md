# Networking Learning Labs

## From L2 Basics to AWS Direct Connect using ContainerLab

---

## Documents

| | |
|---|---|
| 📋 **[learning-plan.md](learning-plan.md)** | Lab objectives, key concepts, and AWS mappings for each lab |
| 🗺 **[topologies.md](topologies.md)** | Mermaid topology diagrams for every lab |
| 📖 **README.md** | ← You are here — environment setup and step-by-step lab commands |

---

## Prerequisites

All labs run inside an **Ubuntu 24.04 LTS** environment with:

- **4 vCPUs** (minimum 2)
- **8 GB RAM** (16 GB recommended)
- **40 GB disk space**

You can get this environment via any of the options below.

---

## Environment Setup — Choose One

### Option A: macOS with Multipass (local laptop)

Best for: quick local setup on a Mac.

**Requirements:** macOS (Apple Silicon or Intel), Homebrew installed.

1. Install Multipass:

```bash
brew install --cask multipass
```

2. Run the setup script (creates an Ubuntu 24.04 VM with Docker + Containerlab):

```bash
chmod +x setup-multipass.sh
./setup-multipass.sh
```

3. Copy lab files into the VM:

```bash
multipass transfer -r ./networking-labs clab:/home/ubuntu/
```

4. Access the VM:

```bash
multipass shell clab
```

### Option B: Amazon EC2 (cloud)

Best for: no local resources needed, accessible from anywhere.

> **Note:** Containerlab uses Docker containers, not nested VMs, so you do NOT need bare-metal or nested virtualization support. A regular `t3.xlarge` (4 vCPU, 16 GB) works fine.

1. Launch an **Ubuntu 24.04 LTS** instance (`t3.xlarge` or larger, 40 GB gp3 root volume).

2. SSH in and clone the repo:

```bash
ssh ubuntu@<instance-ip>
git clone <your-repo-url> networking-labs
cd networking-labs
```

3. Run the setup script:

```bash
chmod +x setup-ubuntu.sh
sudo ./setup-ubuntu.sh
```

4. Log out and back in (so the docker group takes effect):

```bash
exit
ssh ubuntu@<instance-ip>
```

### Option C: Proxmox (home lab)

Best for: dedicated lab environment on a mini-PC or server.

1. Create an Ubuntu 24.04 LTS VM in Proxmox (4 vCPU, 8 GB RAM, 40 GB disk).

2. SSH in and clone the repo:

```bash
ssh user@<vm-ip>
git clone <your-repo-url> networking-labs
cd networking-labs
```

3. Run the setup script:

```bash
chmod +x setup-ubuntu.sh
sudo ./setup-ubuntu.sh
```

4. Log out and back in (so the docker group takes effect):

```bash
exit
ssh user@<vm-ip>
```

---

After setup, you are inside an Ubuntu environment. All `containerlab` and `docker` commands run here.

---

## Lab Directory Structure

```sh
networking-labs/
├── setup-multipass.sh          ← Run this on your Mac first
├── setup-ubuntu.sh             ← Run this on EC2 / Proxmox / any Ubuntu
├── CHEATSHEET.md               ← Quick command reference
├── README.md                   ← This file
│
├── phase1/                     ← L2 Basics
│   ├── lab1.1-first-topology.clab.yml
│   └── lab1.2-l2-connectivity.clab.yml
│
├── phase2/                     ← VLANs & Trunking
│   ├── lab2.1-vlans.clab.yml
│   └── lab2.2-trunking.clab.yml
│
├── phase3/                     ← Layer 3 Routing & ENI Concepts
│   ├── lab3.1-intervlan.clab.yml
│   ├── lab3.2-svi.clab.yml
│   └── lab3.3-eni.clab.yml
│
├── phase4/                     ← BGP Fundamentals
│   ├── lab4.1-bgp-basic.clab.yml
│   ├── lab4.2-bgp-attributes.clab.yml
│   ├── lab4.3-ibgp-rr.clab.yml
│   ├── router-a-frr.conf
│   ├── router-b-frr.conf
│   └── daemons
│
├── phase5/                     ← AWS Direct Connect Simulation
│   ├── lab5.1-dx-overview.clab.yml
│   ├── lab5.2-private-vif.clab.yml
│   ├── lab5.3-public-vif.clab.yml
│   ├── lab5.4-transit-vif.clab.yml
│   ├── lab5.5-dx-advanced.clab.yml
│   ├── lab5.6-eni-vpc.clab.yml
│   ├── configs/
│   ├── advanced-configs/
│   ├── pub-configs/
│   └── tgw-configs/
│
└── phase6/                     ← Advanced Topics
    ├── lab6.1-ecmp.clab.yml
    ├── lab6.2-qos.clab.yml
    ├── lab6.3-troubleshooting.clab.yml
    ├── lab6.4-advanced-eni.clab.yml
    └── configs/
```

---

## How to Run Any Lab

### Deploy

```bash
cd ~/networking-labs/phase1
sudo containerlab deploy -t lab1.1-first-topology.clab.yml
```

### Inspect (see node names and management IPs)

```bash
sudo containerlab inspect -t lab1.1-first-topology.clab.yml
```

### Shell into a node

Container names follow the pattern: `clab-<topology-name>-<node-name>`

```bash
sudo docker exec -it clab-lab1-1-first-topology-host1 bash
```

### Destroy when done

```bash
sudo containerlab destroy -t lab1.1-first-topology.clab.yml
```

> **Tip:** Only run one lab at a time unless you have plenty of RAM. Destroy a lab before deploying the next one.

---

## Phase-by-Phase Guide

---

### Phase 1 — Foundation (L2 Basics)

**What you'll learn:** How Ethernet works. MAC addresses, ARP, broadcast domains.

#### Lab 1.1 — First Topology
> 📋 [Learning objectives](learning-plan.md#lab-11-environment-setup) · 🗺 [Topology](topologies.md#lab-11--first-topology)

```bash
cd ~/networking-labs/phase1
sudo containerlab deploy -t lab1.1-first-topology.clab.yml
sudo docker exec -it clab-lab1-1-first-topology-host1 bash
ping 192.168.1.2
```

**Key exercise:** Run `tcpdump -i eth1 arp` on host2 while host1 pings. Watch the ARP request arrive (broadcast), and the reply go back (unicast).

#### Lab 1.2 — L2 Connectivity
> 📋 [Learning objectives](learning-plan.md#lab-12-layer-2-connectivity) · 🗺 [Topology](topologies.md#lab-12--l2-connectivity)

```bash
sudo containerlab deploy -t lab1.2-l2-connectivity.clab.yml
```

**Key exercise:** Run `bridge fdb show` from the VM host (not inside a container) to see the MAC table of the Linux bridge. Watch entries appear as hosts communicate.

---

### Phase 2 — VLANs & Trunking

**What you'll learn:** How VLANs segment broadcast domains. How 802.1Q tags work on trunk links.

#### Lab 2.1 — Basic VLANs
> 📋 [Learning objectives](learning-plan.md#lab-21-basic-vlan-configuration) · 🗺 [Topology](topologies.md#lab-21--basic-vlans-access-ports)

```bash
cd ~/networking-labs/phase2
sudo containerlab deploy -t lab2.1-vlans.clab.yml
```

**Key exercise:** Confirm sales1 cannot ping eng1 even though they're on the same switch. Use `bridge vlan show` inside the switch container to see port VLAN assignments.

#### Lab 2.2 — VLAN Trunking
> 📋 [Learning objectives](learning-plan.md#lab-22-vlan-trunking-8021q) · 🗺 [Topology](topologies.md#lab-22--vlan-trunking-8021q)

```bash
sudo containerlab deploy -t lab2.2-trunking.clab.yml
```

**Key exercise:** Capture traffic on the trunk link. You should see frames with 802.1Q headers (VLAN tags):

```bash
sudo docker exec -it clab-lab2-2-trunking-sw1 tcpdump -i eth3 -n -e vlan
```

---

### Phase 3 — Layer 3 Routing

**What you'll learn:** How routers connect VLANs. How AWS ENIs work using Linux network namespaces.

#### Lab 3.1 — Inter-VLAN Routing (Router on a Stick)
> 📋 [Learning objectives](learning-plan.md#lab-31-inter-vlan-routing-router-on-a-stick) · 🗺 [Topology](topologies.md#lab-31--inter-vlan-routing-router-on-a-stick)

```bash
cd ~/networking-labs/phase3
sudo containerlab deploy -t lab3.1-intervlan.clab.yml
```

**Key exercise:** Traceroute from host-v10 to host-v20. You'll see the packet go to the router (10.10.0.254) and then cross to the other VLAN. This is exactly how AWS routes between subnets.

```bash
sudo docker exec clab-lab3-1-intervlan-host-v10 traceroute 10.20.0.1
```

#### Lab 3.2 — Layer 3 Switch (SVIs)
> 📋 [Learning objectives](learning-plan.md#lab-32-layer-3-switch-svi) · 🗺 [Topology](topologies.md#lab-32--layer-3-switch-svis)

```bash
sudo containerlab deploy -t lab3.2-svi.clab.yml
```

**Key exercise:** Traceroute inter-VLAN — notice only ONE hop (the SVI itself), compared to two hops in lab 3.1:

```bash
sudo docker exec clab-lab3-2-svi-host-v10-a traceroute 10.20.0.1
```

View the SVIs and routing table on the L3 switch:

```bash
sudo docker exec clab-lab3-2-svi-l3switch ip addr show
sudo docker exec clab-lab3-2-svi-l3switch ip route show
```

#### Lab 3.3 — ENI Simulation
> 📋 [Learning objectives](learning-plan.md#lab-33-virtual-network-interfaces-eni-concepts) · 🗺 [Topology](topologies.md#lab-33--eni-simulation)

```bash
sudo containerlab deploy -t lab3.3-eni.clab.yml
```

**Key exercise:** Simulate moving a floating IP (Elastic IP) between instances:

```bash
# Assign "Elastic IP" to instance-a
sudo docker exec clab-lab3-3-eni-instance-a ip addr add 172.16.1.50/32 dev eth1

# Verify reachability from client
sudo docker exec clab-lab3-3-eni-client ping -c3 172.16.1.50

# Move "Elastic IP" to instance-b (simulates ENI reassociation)
sudo docker exec clab-lab3-3-eni-instance-a ip addr del 172.16.1.50/32 dev eth1
sudo docker exec clab-lab3-3-eni-instance-b ip addr add 172.16.1.50/32 dev eth1

# Client immediately hits new instance — no DNS TTL delay
sudo docker exec clab-lab3-3-eni-client ping -c3 172.16.1.50
```

---

### Phase 4 — BGP Fundamentals

**What you'll learn:** How BGP works. ASNs, peering, prefix advertisement, path selection.

#### Lab 4.1 — Basic BGP Peering
> 📋 [Learning objectives](learning-plan.md#lab-41-basic-bgp-peering) · 🗺 [Topology](topologies.md#lab-41--basic-ebgp-peering)

> **Important:** The FRR config files must be in the **same directory** as the `.clab.yml` file before deploying.

```bash
cd ~/networking-labs/phase4
sudo containerlab deploy -t lab4.1-bgp-basic.clab.yml
```

Enter the FRR CLI on router-a:

```bash
sudo docker exec -it clab-lab4-1-bgp-basic-router-a vtysh
```

Inside vtysh:

```sh
show bgp summary
show bgp ipv4 unicast
show ip route
exit
```

**Key exercise:** Watch the BGP session establish:

```bash
# On router-a, capture BGP OPEN and KEEPALIVE messages:
sudo docker exec -it clab-lab4-1-bgp-basic-router-a \
  tcpdump -i eth1 -n port 179 -A
```

**Experiment — break and fix BGP:**

```bash
# Misconfigure the ASN on one side and watch it fail:
sudo docker exec -it clab-lab4-1-bgp-basic-router-a vtysh
conf t
router bgp 65001
 neighbor 10.0.0.2 remote-as 99999   ← wrong ASN
end
show bgp summary   ← session drops to "Active"

# Fix it:
conf t
router bgp 65001
 neighbor 10.0.0.2 remote-as 65002
end
```

#### Lab 4.2 — BGP Attributes & Path Selection
> 📋 [Learning objectives](learning-plan.md#lab-42-bgp-attributes--path-selection) · 🗺 [Topology](topologies.md#lab-42--bgp-attributes--path-selection)

```bash
sudo containerlab deploy -t lab4.2-bgp-attributes.clab.yml
```

Verify all three BGP sessions are up on router-c:

```bash
sudo docker exec -it clab-lab4-2-bgp-attributes-router-c \
  vtysh -c "show bgp summary"
```

View the two paths to `192.168.1.0/24` — the `>` marks the best path:

```bash
sudo docker exec -it clab-lab4-2-bgp-attributes-router-c \
  vtysh -c "show bgp ipv4 unicast 192.168.1.0/24"
```

**Key exercise — AS-PATH prepending:** Make the direct path less preferred by prepending on router-a:

```bash
sudo docker exec -it clab-lab4-2-bgp-attributes-router-a vtysh
conf t
route-map PREPEND-TO-C permit 10
 set as-path prepend 65001 65001 65001
router bgp 65001
 address-family ipv4 unicast
  neighbor 10.0.13.2 route-map PREPEND-TO-C out
end
clear bgp ipv4 unicast 10.0.13.2 soft out
```

Re-check — router-c now prefers the path via router-b:

```bash
sudo docker exec -it clab-lab4-2-bgp-attributes-router-c \
  vtysh -c "show bgp ipv4 unicast 192.168.1.0/24"
```

**Key exercise — LOCAL_PREF:** Override AS-PATH by setting LOCAL_PREF=200 on router-c for the direct path (LOCAL_PREF is evaluated before AS-PATH):

```bash
sudo docker exec -it clab-lab4-2-bgp-attributes-router-c vtysh
conf t
route-map PREFER-DIRECT permit 10
 set local-preference 200
router bgp 65003
 address-family ipv4 unicast
  neighbor 10.0.13.1 route-map PREFER-DIRECT in
end
clear bgp ipv4 unicast * soft in
```

#### Lab 4.3 — iBGP with Route Reflector
> 📋 [Learning objectives](learning-plan.md#lab-43-ibgp-and-route-reflectors) · 🗺 [Topology](topologies.md#lab-43--ibgp-with-route-reflector)

```bash
sudo containerlab deploy -t lab4.3-ibgp-rr.clab.yml
```

Verify all four iBGP sessions on rr1:

```bash
sudo docker exec -it clab-lab4-3-ibgp-rr-rr1 \
  vtysh -c "show bgp summary"
```

Confirm r1 sees prefixes from r3 and r4 (reflected by rr1):

```bash
sudo docker exec -it clab-lab4-3-ibgp-rr-r1 \
  vtysh -c "show bgp ipv4 unicast"
```

**Key exercise — ORIGINATOR_ID and CLUSTER_LIST:** These loop-prevention attributes are added by the route reflector:

```bash
sudo docker exec -it clab-lab4-3-ibgp-rr-r1 \
  vtysh -c "show bgp ipv4 unicast 192.168.13.0/24"
```

**Key exercise — iBGP next-hop behaviour:** In iBGP, next-hop is NOT changed when reflecting. Observe that r1 sees r3's address as next-hop, not rr1's:

```bash
sudo docker exec -it clab-lab4-3-ibgp-rr-r1 \
  vtysh -c "show bgp ipv4 unicast 192.168.12.0/24"
```

Fix with `next-hop-self` on rr1 so r1 uses rr1 as next-hop:

```bash
sudo docker exec -it clab-lab4-3-ibgp-rr-rr1 vtysh
conf t
router bgp 65000
 address-family ipv4 unicast
  neighbor 10.0.0.2 next-hop-self
end
clear bgp ipv4 unicast 10.0.0.2 soft out
```

---

### Phase 5 — AWS Direct Connect Simulation

**What you'll learn:** How DX private VIF works end-to-end. BGP over VLAN-tagged trunk. Redundant DX with failover. ENI patterns in a VPC.

#### Lab 5.1 — Direct Connect Architecture Overview
> 📋 [Learning objectives](learning-plan.md#lab-51-direct-connect-architecture-overview) · 🗺 [Topology](topologies.md#lab-51--direct-connect-architecture-overview)

A static-routing walkthrough of the full DX component chain before BGP is introduced.

```bash
cd ~/networking-labs/phase5
sudo containerlab deploy -t lab5.1-dx-overview.clab.yml
```

Verify each hop is reachable from the customer router:

```bash
sudo docker exec clab-lab5-1-dx-overview-customer-router ping -c3 10.1.1.2   # DX cross-connect
sudo docker exec clab-lab5-1-dx-overview-customer-router ping -c3 10.1.2.2   # AWS edge
```

Add a static route and test full end-to-end connectivity (customer → EC2):

```bash
sudo docker exec clab-lab5-1-dx-overview-customer-router \
  ip route add 10.0.0.0/24 via 10.1.1.2
sudo docker exec clab-lab5-1-dx-overview-customer-router ping -c3 10.0.0.10
```

**AWS concept mapping:**

| Lab Component      | Real AWS Equivalent            |
|--------------------|--------------------------------|
| `customer-router`  | Customer router (CPE)          |
| `dx-crossconnect`  | DX location cross-connect      |
| `aws-edge`         | AWS DX endpoint router         |
| `vgw`              | Virtual Private Gateway (VGW)  |
| `ec2`              | EC2 instance in private subnet |

#### Lab 5.2 — Private VIF
> 📋 [Learning objectives](learning-plan.md#lab-52-private-virtual-interface-vif) · 🗺 [Topology](topologies.md#lab-52--private-vif)

This is the core DX lab. The topology mirrors real AWS:

```sh
[on-prem] --VLAN 100--> [DX location] --VLAN 100--> [AWS edge] --> [VGW] --> [EC2]
```

```bash
cd ~/networking-labs/phase5
sudo containerlab deploy -t lab5.2-private-vif.clab.yml
```

Check BGP session on the Private VIF:

```bash
sudo docker exec -it clab-lab5-2-private-vif-on-prem-router \
  vtysh -c "show bgp summary"
```

Wait for state: **Established**

Verify route advertisement (on-prem prefix reaches AWS):

```bash
sudo docker exec -it clab-lab5-2-private-vif-vpc-gateway \
  vtysh -c "show bgp ipv4 unicast"
# Should see 10.100.0.0/24 with AS_PATH via 64512 65001
```

Test end-to-end (on-prem → EC2):

```bash
sudo docker exec clab-lab5-2-private-vif-on-prem-router \
  traceroute 10.0.0.10
```

**AWS concept mapping:**

| Lab Component        | Real AWS Equivalent             |
|----------------------|---------------------------------|
| `on-prem-router`     | Customer router at DX location  |
| `dx-location`        | Cross-connect / Meet-me-room    |
| `eth1.100` (VLAN 100)| Private Virtual Interface (VIF) |
| `169.254.x.x` IPs    | Link-local BGP peering IPs      |
| `aws-edge-router`    | AWS DX endpoint router          |
| `vpc-gateway`        | Virtual Private Gateway (VGW)   |
| `ec2-instance`       | EC2 instance in private subnet  |

#### Lab 5.3 — Public VIF
> 📋 [Learning objectives](learning-plan.md#lab-53-public-virtual-interface) · 🗺 [Topology](topologies.md#lab-53--public-vif)

Adds a second VIF (VLAN 200) on the same trunk to reach AWS public service endpoints directly over DX.

```bash
sudo containerlab deploy -t lab5.3-public-vif.clab.yml
```

Verify both BGP sessions are up (private VIF on VLAN 100 + public VIF on VLAN 200):

```bash
sudo docker exec -it clab-lab5-3-public-vif-on-prem-router \
  vtysh -c "show bgp summary"
```

Check what AWS is advertising on the public VIF (simulated S3/DynamoDB prefixes):

```bash
sudo docker exec -it clab-lab5-3-public-vif-on-prem-router \
  vtysh -c "show bgp ipv4 unicast neighbors 169.254.200.2 received-routes"
```

Reach AWS public services from on-prem (via DX, not internet):

```bash
sudo docker exec clab-lab5-3-public-vif-on-prem-router ping -c3 52.92.0.1
```

**Key exercise — prefix filtering on public VIF:** On-prem must only advertise its own public prefix, never RFC1918 or a default route:

```bash
sudo docker exec -it clab-lab5-3-public-vif-on-prem-router vtysh
conf t
ip prefix-list PUBLIC-OUT permit 203.0.113.0/24
ip prefix-list PUBLIC-OUT deny any
router bgp 65001
 address-family ipv4 unicast
  neighbor 169.254.200.2 prefix-list PUBLIC-OUT out
end
clear bgp 169.254.200.2 soft out
```

#### Lab 5.4 — Transit VIF (TGW)
> 📋 [Learning objectives](learning-plan.md#lab-54-transit-virtual-interface-with-tgw) · 🗺 [Topology](topologies.md#lab-54--transit-vif-tgw)

A single DX connection reaches multiple VPCs via a Transit Gateway.

```bash
sudo containerlab deploy -t lab5.4-transit-vif.clab.yml
```

Verify the Transit VIF BGP session:

```bash
sudo docker exec -it clab-lab5-4-transit-vif-on-prem-router \
  vtysh -c "show bgp summary"
```

On-prem reaches all three VPCs via the single DX connection:

```bash
sudo docker exec clab-lab5-4-transit-vif-on-prem-router ping -c3 10.0.1.10
sudo docker exec clab-lab5-4-transit-vif-on-prem-router ping -c3 10.0.2.10
sudo docker exec clab-lab5-4-transit-vif-on-prem-router ping -c3 10.0.3.10
```

**Key exercise — TGW route table isolation:** Block VPC-A from reaching VPC-B (simulates TGW route table segmentation):

```bash
sudo docker exec -it clab-lab5-4-transit-vif-tgw vtysh
conf t
ip prefix-list BLOCK-VPC-B deny 10.0.2.0/24
ip prefix-list BLOCK-VPC-B permit any
router bgp 64512
 address-family ipv4 unicast
  neighbor 10.200.1.2 prefix-list BLOCK-VPC-B out
end
clear bgp 10.200.1.2 soft out
```

Verify: VPC-A cannot reach VPC-B, but on-prem still can:

```bash
sudo docker exec clab-lab5-4-transit-vif-ec2-vpc-a ping -c3 10.0.2.10   # blocked
sudo docker exec clab-lab5-4-transit-vif-on-prem-router ping -c3 10.0.2.10  # works
```

#### Lab 5.5 — Redundant DX Connections
> 📋 [Learning objectives](learning-plan.md#lab-55-advanced-dx-scenarios) · 🗺 [Topology](topologies.md#lab-55--advanced-dx-redundant-connections)

```bash
sudo containerlab deploy -t lab5.5-dx-advanced.clab.yml
```

**Key exercise — failover test:**

```bash
# 1. Verify both BGP sessions up
sudo docker exec -it clab-lab5-5-dx-advanced-on-prem-router \
  vtysh -c "show bgp summary"

# 2. Check AWS prefers primary path (shorter AS-PATH)
sudo docker exec -it clab-lab5-5-dx-advanced-vpc-gateway \
  vtysh -c "show bgp ipv4 unicast 10.100.0.0/22"

# 3. Kill primary DX connection
sudo docker stop clab-lab5-5-dx-advanced-aws-edge-1

# 4. Watch BGP reconverge (~30s, or <1s with BFD)
watch -n2 "sudo docker exec clab-lab5-5-dx-advanced-on-prem-router \
  vtysh -c 'show bgp summary'"

# 5. Traffic flows via backup — confirm traceroute path changed
sudo docker exec clab-lab5-5-dx-advanced-on-prem-router \
  traceroute 10.0.0.10
```

#### Lab 5.6 — ENI Simulation in VPC
> 📋 [Learning objectives](learning-plan.md#lab-56-eni-simulation-in-vpc-context) · 🗺 [Topology](topologies.md#lab-56--eni-simulation-in-vpc)

```bash
sudo containerlab deploy -t lab5.6-eni-vpc.clab.yml
```

**Key exercise — database failover:**

```bash
# App connects to DB via floating IP 10.0.3.100 (currently on db-primary)
sudo docker exec clab-lab5-6-eni-vpc-app-server ping -c3 10.0.3.100

# Simulate db-primary failure: remove floating IP
sudo docker exec clab-lab5-6-eni-vpc-db-primary \
  ip addr del 10.0.3.100/32 dev eth1

# ENI reassociation: move floating IP to db-standby
sudo docker exec clab-lab5-6-eni-vpc-db-standby \
  ip addr add 10.0.3.100/32 dev eth1

# App immediately reaches standby — no restart needed
sudo docker exec clab-lab5-6-eni-vpc-app-server ping -c3 10.0.3.100
```

---

## Phase 6 — Advanced Topics

**What you'll learn:** ECMP load balancing, QoS/DSCP marking, BGP fault diagnosis, and advanced ENI patterns.

#### Lab 6.1 — ECMP & Load Balancing over DX
> 📋 [Learning objectives](learning-plan.md#lab-61-ecmp-and-load-balancing) · 🗺 [Topology](topologies.md#lab-61--ecmp--load-balancing-over-dx)

Both DX paths active simultaneously — traffic is hash-distributed across them.

```bash
cd ~/networking-labs/phase6
sudo containerlab deploy -t lab6.1-ecmp.clab.yml
```

Verify both BGP sessions are up and ECMP routes are installed:

```bash
sudo docker exec -it clab-lab6-1-ecmp-on-prem-router \
  vtysh -c "show bgp summary"
sudo docker exec -it clab-lab6-1-ecmp-on-prem-router \
  vtysh -c "show ip route 10.0.0.0/24"
```

**Key exercise — observe ECMP distribution under load:**

```bash
# Start iperf3 traffic with 8 parallel streams:
sudo docker exec clab-lab6-1-ecmp-on-prem-router \
  iperf3 -c 10.0.0.10 -t 30 -P 8

# In another terminal, watch per-interface packet counts:
sudo docker exec clab-lab6-1-ecmp-on-prem-router \
  watch -n1 "ip -s link show eth1.100 && ip -s link show eth2.100"
```

**Key exercise — failover from ECMP to single path:**

```bash
sudo docker stop clab-lab6-1-ecmp-aws-edge-1
sudo docker exec clab-lab6-1-ecmp-on-prem-router \
  vtysh -c "show ip route 10.0.0.0/24"
# Only one next-hop remains
```

#### Lab 6.2 — QoS & Traffic Shaping
> 📋 [Learning objectives](learning-plan.md#lab-62-qos-and-traffic-shaping) · 🗺 [Topology](topologies.md#lab-62--qos--traffic-shaping)

DSCP marking and HTB queuing at the CPE router simulating a rate-limited DX port.

```bash
sudo containerlab deploy -t lab6.2-qos.clab.yml
```

View the HTB QoS policy on the router's WAN interface:

```bash
sudo docker exec clab-lab6-2-qos-on-prem-router tc -s class show dev eth2
```

**Key exercise — priority queuing under congestion:**

```bash
# Terminal 1 — flood the link with bulk best-effort traffic:
sudo docker exec clab-lab6-2-qos-on-prem-host \
  iperf3 -c 10.0.0.10 -p 5201 -t 60 -b 100M

# Terminal 2 — start "VoIP" traffic (DSCP EF) while bulk is running:
sudo docker exec clab-lab6-2-qos-on-prem-host \
  iperf3 -c 10.0.0.10 -p 5202 -t 30 -u -b 5M -S 0xb8
```

Verify DSCP markings are applied on the WAN interface:

```bash
sudo docker exec clab-lab6-2-qos-on-prem-router \
  tcpdump -i eth2 -n -v ip | grep "tos"
# Look for "tos 0xb8" (EF) on VoIP packets
```

#### Lab 6.3 — Monitoring & Troubleshooting
> 📋 [Learning objectives](learning-plan.md#lab-63-monitoring-and-troubleshooting) · 🗺 [Topology](topologies.md#lab-63--monitoring--troubleshooting)

Intentionally broken Private VIF topology. Diagnose and fix deliberate faults. See `phase6/configs/FAULTS.md` for the answer key.

```bash
sudo containerlab deploy -t lab6.3-troubleshooting.clab.yml
```

**Troubleshooting workflow — work through these steps in order:**

```bash
# Step 1 — Is the BGP session up?
sudo docker exec -it clab-lab6-3-troubleshoot-on-prem-router \
  vtysh -c "show bgp summary"

# Step 2 — Can we reach the BGP peer IP?
sudo docker exec clab-lab6-3-troubleshoot-on-prem-router \
  ping -c3 169.254.100.2

# Step 3 — Is TCP port 179 open?
sudo docker exec clab-lab6-3-troubleshoot-on-prem-router \
  nc -zv 169.254.100.2 179

# Step 4 — Session up but no routes? Check advertisements:
sudo docker exec -it clab-lab6-3-troubleshoot-on-prem-router \
  vtysh -c "show bgp ipv4 unicast neighbors 169.254.100.2 advertised-routes"

# Step 5 — Are routes reaching vpc-gw?
sudo docker exec -it clab-lab6-3-troubleshoot-vpc-gw \
  vtysh -c "show ip route"

# Step 6 — Watch for packets at the AWS edge:
sudo docker exec -it clab-lab6-3-troubleshoot-aws-edge \
  tcpdump -i eth1.100 -n icmp
```

#### Lab 6.4 — Advanced ENI Patterns
> 📋 [Learning objectives](learning-plan.md#lab-64-advanced-eni-patterns) · 🗺 [Topology](topologies.md#lab-64--advanced-eni-patterns)

Four concurrent scenarios: appliance cluster failover, per-ENI security isolation, Lambda-style shared ENI, and pod trunk ENI.

```bash
sudo containerlab deploy -t lab6.4-advanced-eni.clab.yml
```

**Scenario A — appliance cluster failover:**

```bash
# Traffic flows through active appliance (floating IP 10.0.3.100):
sudo docker exec clab-lab6-4-adv-eni-client ping -c3 10.0.3.100

# Simulate failure — remove floating IP from active:
sudo docker exec clab-lab6-4-adv-eni-appliance-active \
  ip addr del 10.0.3.100/32 dev eth1

# Promote standby:
sudo docker exec clab-lab6-4-adv-eni-appliance-standby \
  ip addr add 10.0.3.100/32 dev eth1

# Client resumes with no config change:
sudo docker exec clab-lab6-4-adv-eni-client ping -c3 10.0.3.100
```

**Scenario B — per-ENI security group enforcement:**

```bash
# HTTP allowed on web ENI:
sudo docker exec clab-lab6-4-adv-eni-client nc -zv 10.0.0.30 80
# SSH blocked on web ENI:
sudo docker exec clab-lab6-4-adv-eni-client nc -zv 10.0.0.30 22
```

**Scenario C — Lambda-style shared ENI:**

```bash
# All four function IPs reachable:
for ip in 51 52 53 54; do
  sudo docker exec clab-lab6-4-adv-eni-client ping -c1 10.0.1.$ip
done
```

**Scenario D — pod trunk ENI:**

```bash
# Each pod IP on its own VLAN subinterface:
sudo docker exec clab-lab6-4-adv-eni-client ping -c1 10.0.1.61
sudo docker exec clab-lab6-4-adv-eni-client ping -c1 10.0.1.62
sudo docker exec clab-lab6-4-adv-eni-client ping -c1 10.0.1.63

# View the VLAN subinterfaces simulating pod ENIs:
sudo docker exec clab-lab6-4-adv-eni-eni-trunk-host ip addr show
```

---

## Saving Your Work

Containerlab configs are ephemeral — containers are recreated on each deploy. To persist FRR configs across deploys:

```bash
# Copy running config out of a container to a file:
sudo docker exec clab-lab4-1-bgp-basic-router-a \
  vtysh -c "show running-config" > my-router-a.conf
```

Then reference this file in your `.clab.yml` bind mount.

---

## Troubleshooting

### "Image not found" on deploy

```bash
docker pull frrouting/frr:latest
docker pull ghcr.io/hellt/network-multitool
```

### Container exited immediately after deploy

```bash
sudo docker logs clab-<topo>-<node>
```

### BGP stuck in "Active" state

- Can you ping the BGP peer IP? Check L3 connectivity first.
- Do ASNs match on both sides?
- Is bgpd enabled in the `daemons` file?
- Check the FRR log: `sudo docker exec <node> cat /var/log/frr/bgpd.log`

### Slow BGP convergence after failure

- Default BGP hold timer is 90 seconds. After a link failure, convergence takes up to 90s.
- Add BFD to speed this up to sub-second: `neighbor <IP> bfd` in both routers' BGP config.

### Multipass VM ran out of disk

```bash
# From your Mac:
multipass stop clab
# Resize requires recreating the VM — plan 40GB+ upfront
```

### EC2 instance ran out of disk

Expand the EBS volume in the AWS Console, then grow the filesystem:

```bash
sudo growpart /dev/nvme0n1 1
sudo resize2fs /dev/nvme0n1p1
```

---

## VM Lifecycle

### Multipass (macOS)

```bash
# Suspend VM when not in use (saves RAM):
multipass stop clab

# Resume:
multipass start clab && multipass shell clab

# Full cleanup:
multipass delete clab && multipass purge
```

### EC2

```bash
# Stop instance (no compute charges while stopped):
aws ec2 stop-instances --instance-ids <instance-id>

# Start again:
aws ec2 start-instances --instance-ids <instance-id>
```

### Proxmox

Use the Proxmox web UI or `qm` CLI:

```bash
qm shutdown <vmid>
qm start <vmid>
```
