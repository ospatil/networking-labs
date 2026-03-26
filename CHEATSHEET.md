# Containerlab Lab Kit — Quick Reference

> **How to use this cheatsheet:** work top-to-bottom the first time through.
> Once the VM is running, jump directly to the section you need.

---

## 1. Multipass VM Lifecycle

```bash
# First-time setup (run on your Mac)
./setup-multipass.sh

# Copy lab files into the VM
multipass transfer -r ./networking-labs clab:/home/ubuntu/

# Access the VM
multipass shell clab
```

| Command | What it does |
| --- | --- |
| `multipass list` | List all VMs and their state |
| `multipass shell clab` | Open a shell inside the VM |
| `multipass stop clab` | Suspend the VM (saves RAM) |
| `multipass start clab` | Resume the VM |
| `multipass info clab` | Show IP, CPU, memory, disk |
| `multipass delete clab && multipass purge` | Permanently destroy VM |

---

## 2. Containerlab Core Commands

Run all `containerlab` and `docker` commands **inside the Multipass VM**, not on your Mac.

```bash
# Deploy a lab
sudo containerlab deploy -t <file>.clab.yml

# Tear down a lab (always destroy before starting the next one)
sudo containerlab destroy -t <file>.clab.yml

# List running nodes, management IPs, and container names
sudo containerlab inspect -t <file>.clab.yml

# Open topology diagram in browser (port 50080)
sudo containerlab graph -t <file>.clab.yml

# Force redeploy without destroying first (useful after config edits)
sudo containerlab deploy -t <file>.clab.yml --reconfigure
```

> **Container naming:** `clab-<topology-name>-<node-name>`
> Example: topology `lab2-1-vlans`, node `sw1` → `clab-lab2-1-vlans-sw1`

---

## 3. Container Access

```bash
# Interactive shell into a node
sudo docker exec -it clab-<topo>-<node> bash

# Run a single command without entering the shell
sudo docker exec clab-<topo>-<node> ping -c3 10.0.0.1

# Open the FRR Cisco-style CLI (vtysh)
sudo docker exec -it clab-<topo>-<node> vtysh

# View container startup logs (useful when a node crashes)
sudo docker logs clab-<topo>-<node>

# List all running lab containers
sudo docker ps --filter "label=containerlab"
```

---

## 4. IP & Interface Commands

Run these **inside a container** (`docker exec … bash` first).

### Interfaces

```bash
ip link show                          # list all interfaces and state
ip link set eth1 up                   # bring interface up
ip link set eth1 down                 # bring interface down
ip addr show                          # show all IPs on all interfaces
ip addr show dev eth1                 # show IPs on eth1 only
ip addr add 10.0.0.1/24 dev eth1      # assign IP
ip addr del 10.0.0.1/24 dev eth1      # remove IP
```

### Routes

```bash
ip route show                                    # full routing table
ip route add 0.0.0.0/0 via 10.0.0.254           # default gateway
ip route add 192.168.0.0/16 via 10.0.0.1        # specific prefix
ip route del 192.168.0.0/16                      # remove route
ip route get 10.20.0.1                           # show which route would be used
```

### ARP & Neighbours

```bash
ip neigh show                         # ARP table
ip neigh flush dev eth1               # clear ARP cache on interface
arp -n                                # classic ARP table (no DNS lookup)
```

### IP Forwarding (routers only)

```bash
sysctl -w net.ipv4.ip_forward=1       # enable routing between interfaces
```

---

## 5. VLAN Commands

### VLAN Subinterfaces (802.1Q)

```bash
# Create a subinterface tagged with VLAN 100
ip link add link eth1 name eth1.100 type vlan id 100
ip link set eth1 up
ip link set eth1.100 up
ip addr add 169.254.100.1/30 dev eth1.100

# Remove a subinterface
ip link del eth1.100
```

### VLAN-Aware Linux Bridge

```bash
# Create the bridge
ip link add name br0 type bridge vlan_filtering 1
ip link set br0 up

# Add ports to the bridge
ip link set eth1 master br0
ip link set eth2 master br0

# Access port — untagged ingress, assigned to VLAN 10
bridge vlan add vid 10 dev eth1 pvid untagged
bridge vlan del vid 1  dev eth1          # remove default VLAN 1

# Trunk port — tagged, carries VLANs 10 and 20
bridge vlan add vid 10 dev eth2
bridge vlan add vid 20 dev eth2
bridge vlan del vid 1  dev eth2

# SVI — give the bridge itself an IP for a VLAN (L3 switching)
ip link add link br0 name br0.10 type vlan id 10
ip link set br0.10 up
ip addr add 10.10.0.254/24 dev br0.10
bridge vlan add vid 10 dev br0 self
```

### Inspecting VLANs

```bash
bridge vlan show                      # all ports and their VLAN memberships
bridge vlan show dev eth1             # VLAN membership for a specific port
bridge fdb show                       # MAC address table (all VLANs)
bridge fdb show dev br0               # MAC table for a specific bridge
```

---

## 6. FRR / vtysh Commands

Enter the FRR CLI first: `sudo docker exec -it <container> vtysh`

### View Commands

```sh
show bgp summary                                    ! all BGP neighbours + state
show bgp ipv4 unicast                               ! full BGP table
show bgp ipv4 unicast 192.168.1.0/24                ! detail for one prefix
show bgp neighbors <IP>                             ! full neighbour detail
show bgp neighbors <IP> advertised-routes           ! prefixes we are sending
show bgp neighbors <IP> received-routes             ! prefixes we are receiving
show ip route                                       ! IP RIB (B=BGP, C=connected)
show ip route 10.0.0.0/24                           ! detail for one prefix
show running-config                                 ! current active config
```

### BGP Neighbour States

| State | Meaning |
| --- | --- |
| `Idle` | BGP disabled or interface down |
| `Connect` | TCP SYN sent, waiting for reply |
| `Active` | TCP not connecting — wrong IP, ACL, or peer not running |
| `OpenSent` | TCP connected, OPEN message sent |
| `OpenConfirm` | OPEN received — often ASN mismatch if stuck here |
| `Established` | ✅ Session up, exchanging routes |

### Basic BGP Configuration

```sh
conf t
router bgp 65001
 bgp router-id 10.0.0.1
 neighbor 10.0.0.2 remote-as 65002
 neighbor 10.0.0.2 description peer-name
 !
 address-family ipv4 unicast
  network 192.168.1.0/24               ! advertise this prefix
  neighbor 10.0.0.2 activate
  neighbor 10.0.0.2 soft-reconfiguration inbound
  neighbor 10.0.0.2 next-hop-self      ! rewrite next-hop (needed for iBGP)
 exit-address-family
end
write memory                            ! save to /etc/frr/frr.conf
```

### Traffic Engineering & Policy

```sh
! AS-PATH prepending (make this path less preferred by remote peer)
route-map BACKUP-OUT permit 10
 set as-path prepend 65001 65001 65001

! LOCAL_PREF (prefer one inbound path — higher wins, default is 100)
route-map PREFER-THIS permit 10
 set local-preference 200

! Apply route-maps to a neighbour
router bgp 65001
 address-family ipv4 unicast
  neighbor 10.0.0.2 route-map BACKUP-OUT out
  neighbor 10.0.0.2 route-map PREFER-THIS in

! Soft-reset after a policy change (no session teardown)
clear bgp ipv4 unicast 10.0.0.2 soft
clear bgp ipv4 unicast 10.0.0.2 soft out
clear bgp ipv4 unicast 10.0.0.2 soft in

! ECMP — allow multiple equal-cost BGP paths
router bgp 65001
 address-family ipv4 unicast
  maximum-paths 2         ! eBGP ECMP
  maximum-paths ibgp 2    ! iBGP ECMP
```

---

## 7. tcpdump Recipes

```bash
tcpdump -i eth1 -n                    # all traffic, no DNS resolution
tcpdump -i eth1 -n arp                # ARP only — watch broadcasts and replies
tcpdump -i eth1 -n -e vlan            # show 802.1Q VLAN tag in each line
tcpdump -i eth1 -n port 179           # BGP (TCP 179) only
tcpdump -i eth1 -n icmp               # ICMP/ping only
tcpdump -i eth1 -n -v ip              # verbose — shows DSCP/TOS field
tcpdump -i eth1 -w /tmp/cap.pcap      # save to file (open in Wireshark)
tcpdump -i eth1 -n host 10.0.0.1      # traffic to/from one IP only
tcpdump -i eth1 -n 'vlan 100'         # only VLAN-100 tagged frames
```

> **Tip:** Run tcpdump in one terminal while generating traffic in another.
> Use `&` to background it, then `kill %1` to stop.

---

## 8. Network Namespaces & ENI Simulation

These commands run on the **VM host** (not inside a container).

```bash
# Find the Linux PID of a running container
PID=$(docker inspect -f '{{.State.Pid}}' <container-name>)
echo $PID

# Enter a container's network namespace from the host (non-destructive inspection)
sudo nsenter -t $PID -n ip addr show
sudo nsenter -t $PID -n ip route show

# Move an interface INTO a container's namespace (hot-attach / ENI attach)
sudo ip link set <iface> netns $PID

# Move an interface OUT of a container back to the host namespace (ENI detach)
sudo nsenter -t $PID -n ip link set <iface> netns 1

# Create a veth pair (virtual ethernet cable — two linked ends)
sudo ip link add veth0 type veth peer name veth1
sudo ip link set veth0 up

# Watch interface packet counters live
watch -n1 "ip -s link show eth1"
```

---

## 9. iptables (Security Group Simulation)

```bash
# List all rules with packet and byte counters
iptables -L -v -n

# Allow a port inbound, drop everything else (simulates SG ingress allow rule)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -j DROP

# Block a specific source subnet from a port
iptables -A INPUT -s 10.0.2.0/24 -p tcp --dport 3306 -j DROP

# DSCP marking for QoS (used in lab 6.2)
iptables -t mangle -A FORWARD -p udp --dport 5060 -j DSCP --set-dscp 46

# Flush all rules (reset to open)
iptables -F
iptables -t mangle -F
```

---

## 10. Troubleshooting Checklists

### Can't ping between two nodes?

Work through these in order — stop at the first failure:

1. **Interface up?** `ip link show` — state must show `UP`
2. **IP assigned?** `ip addr show` — correct address and prefix length?
3. **Route exists?** `ip route show` — is there a path to the destination subnet?
4. **Packets arriving?** `tcpdump -i eth1 -n icmp` on the *destination* — do ICMP requests show up?
5. **Firewall?** `iptables -L -v -n` — any unexpected DROP rules?
6. **IP forwarding on routers?** `sysctl net.ipv4.ip_forward` — must return `1`

### BGP session not reaching Established?

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Stuck in `Active` | TCP not connecting | Verify peer IP, check interface is up, try `ping <peer>` |
| Stuck in `OpenSent` | Peer not responding | Check peer has FRR running — `docker logs <node>` |
| Resets at `OpenConfirm` | ASN mismatch | Confirm `remote-as` matches the peer's actual AS number |
| `Established` but no routes | Missing `activate` or `network` | Check address-family config on both sides |
| Routes installed, ping fails | IP forwarding off | `sysctl -w net.ipv4.ip_forward=1` on the router |
| Prefix not advertised | Not in RIB | Add the IP to loopback so the `network` statement matches |

```bash
# Quick BGP diagnostic sequence — run these top to bottom
docker exec -it <router> vtysh -c "show bgp summary"
docker exec -it <router> vtysh -c "show bgp neighbors <peer-ip>"
docker exec     <router> ping -c3 <peer-ip>
docker exec -it <router> tcpdump -i eth1 -n port 179 -c 10
docker          logs <router>
```

### Direct Connect / Private VIF not working?

1. **VLAN subinterface up?** `ip link show eth1.100` — must be `UP`
2. **BGP peer reachable?** `ping 169.254.x.x` — link-local, must always work if wired correctly
3. **VLAN ID matches both ends?** Customer and AWS side must use identical VLAN
4. **ASNs correct?** Customer = your AS, AWS side = 64512 (reserved private ASN)
5. **Prefix in RIB?** `ip addr show lo` — loopback must carry the advertised prefix
6. **iBGP next-hop reachable?** If VGW cannot reach on-prem next-hop, add `next-hop-self` on the AWS edge

---

## 11. Lab-by-Lab Command Reference

### Phase 1–2: L2 and VLANs

```bash
# Deploy
sudo containerlab deploy -t lab1.1-first-topology.clab.yml

# View MAC table from VM host (not inside a container)
bridge fdb show

# Prove VLAN isolation — eng1 should see NO ARP from sales1
docker exec -it clab-lab2-1-vlans-eng1 tcpdump -i eth1 -n arp &
docker exec     clab-lab2-1-vlans-sales1 ping -c3 10.10.0.2
```

### Phase 3: Routing & ENI

```bash
# Traceroute confirms inter-VLAN routing hop through the router
docker exec clab-lab3-1-intervlan-host-v10 traceroute 10.20.0.1

# Floating IP failover (simulates ENI reassociation)
docker exec clab-lab3-3-eni-instance-a ip addr add 172.16.1.50/32 dev eth1
docker exec clab-lab3-3-eni-instance-a ip addr del 172.16.1.50/32 dev eth1
docker exec clab-lab3-3-eni-instance-b ip addr add 172.16.1.50/32 dev eth1
```

### Phase 4: BGP

```bash
# Watch BGP establish in real time immediately after deploy
watch -n2 "docker exec clab-lab4-1-bgp-basic-router-a vtysh -c 'show bgp summary'"

# Check both path options in lab4.2 triangle topology
docker exec -it clab-lab4-2-bgp-attributes-router-c \
  vtysh -c "show bgp ipv4 unicast 192.168.1.0/24"
```

### Phase 5: Direct Connect

```bash
# Verify Private VIF BGP session and trace the full DX path
docker exec -it clab-lab5-2-private-vif-on-prem-router \
  vtysh -c "show bgp summary"
docker exec clab-lab5-2-private-vif-on-prem-router traceroute 10.0.0.10

# Dual DX failover — kill primary, watch convergence
docker stop clab-lab5-5-dx-advanced-aws-edge-1
watch -n2 "docker exec clab-lab5-5-dx-advanced-on-prem-router \
  vtysh -c 'show bgp summary'"

# Database failover via floating IP (lab5.6)
docker exec clab-lab5-6-eni-vpc-db-primary  ip addr del 10.0.3.100/32 dev eth1
docker exec clab-lab5-6-eni-vpc-db-standby  ip addr add 10.0.3.100/32 dev eth1
```

### Phase 6: Advanced

```bash
# ECMP — verify both paths and watch traffic distribute
docker exec -it clab-lab6-1-ecmp-on-prem-router \
  vtysh -c "show ip route 10.0.0.0/24"
docker exec clab-lab6-1-ecmp-on-prem-router iperf3 -c 10.0.0.10 -t 30 -P 8 &
watch -n1 "docker exec clab-lab6-1-ecmp-on-prem-router ip -s link show eth1.100"

# QoS — view HTB class statistics during congestion
docker exec clab-lab6-2-qos-on-prem-router tc -s class show dev eth2

# Troubleshooting lab — find the BGP notification that caused the drop
docker exec -it clab-lab6-3-troubleshoot-on-prem-router \
  vtysh -c "show bgp neighbors 169.254.100.2" | grep -A5 "Last notification"
```

---

## 12. Useful One-Liners

```bash
# Save a running FRR config out to a local file
docker exec <container> vtysh -c "show running-config" > saved.conf

# Restart a single container (re-runs its exec startup commands)
docker restart clab-<topo>-<node>

# Time how long BGP convergence takes after a failure
date && docker stop clab-<topo>-<edge> && \
  watch -n0.5 "docker exec clab-<topo>-<router> \
    vtysh -c 'show bgp summary' | grep -E 'Neighbor|[0-9]+\.[0-9]+\.[0-9]+'"

# Find a container name by partial node name (when you forget the full name)
docker ps --filter "label=containerlab" --format "{{.Names}}" | grep <partial-name>

# Check disk space inside the VM (containers consume storage)
df -h

# Pull fresh container images
docker pull frrouting/frr:latest
docker pull ghcr.io/hellt/network-multitool
```
