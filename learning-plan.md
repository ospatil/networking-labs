# Containerlab Learning Path: L2 to AWS Direct Connect

## Documents

| | |
|---|---|
| 📋 **learning-plan.md** | ← You are here — lab objectives and key concepts |
| 🗺 **[topologies.md](topologies.md)** | Mermaid topology diagrams for every lab |
| 📖 **[README.md](README.md)** | VM setup and step-by-step lab commands |

---

## Phase 1: Foundation Setup & L2 Basics

### Lab 1.1: Environment Setup
> 🗺 [Topology](topologies.md#lab-11--first-topology) · 📖 [Commands](README.md#lab-11--first-topology)
- Install Containerlab and Docker prerequisites
- Pull base images (FRRouting, Linux)
- Create first simple topology (2 nodes connected)
- Learn Containerlab CLI basics (deploy, destroy, inspect, exec)

### Lab 1.2: Layer 2 Connectivity
> 🗺 [Topology](topologies.md#lab-12--l2-connectivity) · 📖 [Commands](README.md#lab-12--l2-connectivity)
**Goal:** Understand basic Ethernet switching
- Create topology with 3+ hosts and a Linux bridge
- Verify L2 connectivity with ping
- Examine MAC address tables
- Observe ARP behavior
- Use tcpdump to see L2 frames

**Key concepts:** MAC addresses, broadcast domains, ARP

---

## Phase 2: VLANs & Trunking

### Lab 2.1: Basic VLAN Configuration
> 🗺 [Topology](topologies.md#lab-21--basic-vlans-access-ports) · 📖 [Commands](README.md#lab-21--basic-vlans)
**Goal:** Segment L2 networks with VLANs
- Create topology with switch and multiple hosts
- Configure access ports (untagged VLANs)
- Assign hosts to different VLANs
- Verify isolation between VLANs
- Test connectivity within same VLAN

**Key concepts:** VLAN IDs, access ports, broadcast domain separation

### Lab 2.2: VLAN Trunking (802.1Q)
> 🗺 [Topology](topologies.md#lab-22--vlan-trunking-8021q) · 📖 [Commands](README.md#lab-22--vlan-trunking)
**Goal:** Carry multiple VLANs over single link
- Create two switches connected by trunk link
- Configure 802.1Q tagging
- Distribute VLANs across both switches
- Verify VLAN traffic crosses trunk
- Capture and analyze tagged frames

**Key concepts:** Trunk ports, 802.1Q headers, VLAN tagging

---

## Phase 3: Layer 3 Routing

### Lab 3.1: Inter-VLAN Routing (Router on a Stick)
> 🗺 [Topology](topologies.md#lab-31--inter-vlan-routing-router-on-a-stick) · 📖 [Commands](README.md#lab-31--inter-vlan-routing-router-on-a-stick)
**Goal:** Route between VLANs using subinterfaces
- Add router with subinterfaces for each VLAN
- Configure 802.1Q subinterfaces
- Assign IP addresses to each VLAN
- Enable routing between VLANs
- Test cross-VLAN communication

**Key concepts:** Subinterfaces, default gateways, routing between subnets

### Lab 3.2: Layer 3 Switch (SVI)
> 🗺 [Topology](topologies.md#lab-32--layer-3-switch-svis) · 📖 [Commands](README.md#lab-32--layer-3-switch-svis)
**Goal:** Route using Switched Virtual Interfaces
- Configure SVIs on Linux bridge/switch
- Assign IP addresses to VLANs
- Enable IP forwarding
- Compare performance to router-on-stick

**Key concepts:** SVIs, L3 switching, routing efficiency

### Lab 3.3: Virtual Network Interfaces (ENI Concepts)
> 🗺 [Topology](topologies.md#lab-33--eni-simulation) · 📖 [Commands](README.md#lab-33--eni-simulation)
**Goal:** Understand dynamic interface management
- Create containers with multiple network interfaces
- Attach/detach interfaces to running containers
- Move interfaces between containers (simulating ENI movement)
- Preserve IP/MAC addresses during moves
- Configure primary and secondary IPs on interfaces
- Simulate interface failover scenarios

**Key concepts:** Network namespaces, interface lifecycle, hot-plugging, floating IPs

**AWS mapping:** This simulates Elastic Network Interfaces (ENIs) in EC2

---

## Phase 4: BGP Fundamentals

### Lab 4.1: Basic BGP Peering
> 🗺 [Topology](topologies.md#lab-41--basic-ebgp-peering) · 📖 [Commands](README.md#lab-41--basic-bgp-peering)
**Goal:** Establish first BGP session
- Create two routers in different AS numbers
- Configure eBGP peering
- Exchange simple prefixes
- Verify BGP neighbor state
- Examine BGP table and RIB

**Key concepts:** AS numbers, BGP neighbors, prefix advertisement, next-hop

### Lab 4.2: BGP Attributes & Path Selection
> 🗺 [Topology](topologies.md#lab-42--bgp-attributes--path-selection) · 📖 [Commands](README.md#lab-42--bgp-attributes--path-selection)
**Goal:** Understand BGP decision process
- Configure multiple paths to same destination
- Manipulate AS-PATH, LOCAL_PREF, MED
- Observe path selection changes
- Use BGP communities
- Implement basic route filtering

**Key concepts:** BGP attributes, best path selection, route policies

### Lab 4.3: iBGP and Route Reflectors
> 🗺 [Topology](topologies.md#lab-43--ibgp-with-route-reflector) · 📖 [Commands](README.md#lab-43--ibgp-with-route-reflector)
**Goal:** Scale BGP within an AS
- Create topology with multiple routers in same AS
- Configure iBGP full mesh
- Implement route reflector to reduce peerings
- Understand iBGP vs eBGP rules

**Key concepts:** iBGP, route reflectors, BGP scaling

---

## Phase 5: AWS Direct Connect Simulation

### Lab 5.1: Direct Connect Architecture Overview
> 🗺 [Topology](topologies.md#lab-51--direct-connect-architecture-overview) · 📖 [Commands](README.md#lab-51--direct-connect-architecture-overview)
**Goal:** Understand DX components
- Map DX concepts to network primitives
- Design lab topology mimicking AWS DX
- Identify: customer router, DX location, AWS edge, VGW/TGW

**Components to simulate:**
- Customer on-premises router
- "Direct Connect location" (cross-connect simulation)
- AWS edge router
- Virtual Private Gateway (VGW) or Transit Gateway (TGW)
- VPC routing

### Lab 5.2: Private Virtual Interface (VIF)
> 🗺 [Topology](topologies.md#lab-52--private-vif) · 📖 [Commands](README.md#lab-52--private-vif)
**Goal:** Simulate private VIF to VPC
- Create 802.1Q trunk between customer and AWS edge
- Configure VLAN for private VIF (e.g., VLAN 100)
- Establish eBGP session over the VLAN
- Customer advertises on-prem prefixes
- AWS advertises VPC CIDR
- Verify route propagation both directions
- Test connectivity to simulated EC2 instances

**Key concepts:** Private VIF, VPC integration, private IP routing

### Lab 5.3: Public Virtual Interface
> 🗺 [Topology](topologies.md#lab-53--public-vif) · 📖 [Commands](README.md#lab-53--public-vif)
**Goal:** Simulate public VIF for AWS services
- Add second VLAN on same trunk (e.g., VLAN 200)
- Configure public VIF with public IPs
- Establish eBGP session
- AWS advertises public service prefixes
- Customer advertises public IP space
- Implement prefix filtering and security

**Key concepts:** Public VIF, public AWS endpoints, BGP filtering

### Lab 5.4: Transit Virtual Interface with TGW
> 🗺 [Topology](topologies.md#lab-54--transit-vif-tgw) · 📖 [Commands](README.md#lab-54--transit-vif-tgw)
**Goal:** Multi-VPC routing via Transit Gateway
- Simulate multiple VPCs
- Create transit VIF to TGW
- Configure BGP to advertise multiple VPC CIDRs
- Implement route tables on TGW
- Test routing between on-prem and multiple VPCs

**Key concepts:** Transit Gateway, centralized routing, multi-VPC connectivity

### Lab 5.5: Advanced DX Scenarios
> 🗺 [Topology](topologies.md#lab-55--advanced-dx-redundant-connections) · 📖 [Commands](README.md#lab-55--redundant-dx-connections)
**Goal:** Production-like configurations
- Implement BGP communities for route control
- Configure AS-PATH prepending for traffic engineering
- Set up redundant DX connections (active/active or active/passive)
- Implement BFD for fast failure detection
- Add route filtering and prefix limits
- Simulate failover scenarios

**Key concepts:** High availability, traffic engineering, operational best practices

### Lab 5.6: ENI Simulation in VPC Context
> 🗺 [Topology](topologies.md#lab-56--eni-simulation-in-vpc) · 📖 [Commands](README.md#lab-56--eni-simulation-in-vpc)
**Goal:** Simulate AWS ENI behavior in VPC
- Create VPC topology with multiple subnets
- Configure instances with multiple ENIs
- Practice ENI attachment/detachment to running instances
- Implement multi-homed instances (ENIs in different subnets)
- Simulate elastic IP association/reassociation
- Create failover scenario using ENI movement
- Configure different security groups per ENI
- Test source/destination checking behavior

**Key concepts:** ENI lifecycle, multi-homing, elastic IPs, subnet isolation, HA patterns

**Real-world scenarios:**
- Database failover with floating IP
- NAT gateway redundancy
- Multi-subnet application instances
- Network appliance deployment

---

## Phase 6: Advanced Topics (Optional)

### Lab 6.1: ECMP and Load Balancing
> 🗺 [Topology](topologies.md#lab-61--ecmp--load-balancing-over-dx) · 📖 [Commands](README.md#lab-61--ecmp--load-balancing-over-dx)
- Multiple equal-cost paths over DX
- BGP multipath configuration
- Traffic distribution testing

### Lab 6.2: QoS and Traffic Shaping
> 🗺 [Topology](topologies.md#lab-62--qos--traffic-shaping) · 📖 [Commands](README.md#lab-62--qos--traffic-shaping)
- DSCP marking across DX
- Rate limiting and shaping
- Priority queuing

### Lab 6.3: Monitoring and Troubleshooting
> 🗺 [Topology](topologies.md#lab-63--monitoring--troubleshooting) · 📖 [Commands](README.md#lab-63--monitoring--troubleshooting)
- BGP session monitoring
- Flow analysis
- Common failure scenarios and resolution
- Using looking glasses and route servers

### Lab 6.4: Advanced ENI Patterns
> 🗺 [Topology](topologies.md#lab-64--advanced-eni-patterns) · 📖 [Commands](README.md#lab-64--advanced-eni-patterns)
**Goal:** Complex multi-interface scenarios
- Implement active/passive failover with ENI movement
- Create multi-tier applications with ENI isolation
- Simulate AWS Lambda ENI behavior (shared ENIs)
- Practice ENI trunking (multiple VLANs on single ENI)
- Build network appliance clusters with ENI failover
- Implement elastic fabric adapter concepts

**Key concepts:** Advanced HA, network function virtualization, performance optimization

---

## Learning Resources

**Documentation:**
- Containerlab official docs: https://containerlab.dev
- FRRouting documentation: https://docs.frrouting.org
- AWS Direct Connect docs: https://docs.aws.amazon.com/directconnect/

**Tools you'll use:**
- `tcpdump` / `wireshark` - packet analysis
- `ip` command - interface and route management
- `ip netns` - network namespace management (for ENI simulation)
- `vtysh` - FRRouting CLI
- `bridge` command - Linux bridge management
- `birdc` - BIRD routing daemon (alternative to FRR)
- `nsenter` - enter container namespaces for interface manipulation

**Practice approach:**
- Complete each lab before moving to next
- Break things intentionally to understand failure modes
- Document your configs for reference
- Try variations on each lab
- Build muscle memory with CLI commands

**Time estimate:** 
- 2-3 hours per lab
- ~50-60 hours total for complete path (including ENI labs)
- Can be done over 5-7 weeks at comfortable pace

**ENI-specific learning benefits:**
- Understand how AWS networking differs from traditional VMs
- Practice failure recovery patterns
- Learn network namespace manipulation (useful for Kubernetes, containers)
- Build skills for network automation and orchestration