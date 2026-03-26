# Network Topology Diagrams — Phases 1–6

## Documents

| | |
|---|---|
| 📋 **[learning-plan.md](learning-plan.md)** | Lab objectives, key concepts, and AWS mappings for each lab |
| 🗺 **topologies.md** | ← You are here — Mermaid topology diagrams for every lab |
| 📖 **[README.md](README.md)** | VM setup and step-by-step lab commands |

---

## Phase 1 — L2 Basics

### Lab 1.1 — First Topology
> 📋 [Learning objectives](learning-plan.md#lab-11-environment-setup) · 📖 [Commands](README.md#lab-11--first-topology)

Two hosts connected via a Linux bridge acting as a simple switch.

```mermaid
graph LR
    host1["host1"]
    bridge1(["bridge1 🔀"])
    host2["host2"]

    host1 --- bridge1 --- host2
```

### Lab 1.2 — L2 Connectivity
> 📋 [Learning objectives](learning-plan.md#lab-12-layer-2-connectivity) · 📖 [Commands](README.md#lab-12--l2-connectivity)

Three hosts on a shared Linux bridge. Explore MAC learning, ARP, and broadcast domains.

```mermaid
graph TD
    sw1(["sw1\nLinux Bridge"])

    host1["host1\n10.0.0.1/24"] --- sw1
    host2["host2\n10.0.0.2/24"] --- sw1
    host3["host3\n10.0.0.3/24"] --- sw1
```

---

## Phase 2 — VLANs & Trunking

### Lab 2.1 — Basic VLANs (Access Ports)
> 📋 [Learning objectives](learning-plan.md#lab-21-basic-vlan-configuration) · 📖 [Commands](README.md#lab-21--basic-vlans)

Two VLANs on a single VLAN-aware bridge. Intra-VLAN traffic is permitted; inter-VLAN is blocked.

```mermaid
graph TD
    sw1(["sw1\nVLAN-aware bridge"])

    subgraph VLAN10["VLAN 10 — 10.10.0.0/24"]
        sales1["sales1\n10.10.0.1"]
        sales2["sales2\n10.10.0.2"]
    end

    subgraph VLAN20["VLAN 20 — 10.20.0.0/24"]
        eng1["eng1\n10.20.0.1"]
        eng2["eng2\n10.20.0.2"]
    end

    sales1 --- sw1
    sales2 --- sw1
    eng1   --- sw1
    eng2   --- sw1
```

### Lab 2.2 — VLAN Trunking (802.1Q)
> 📋 [Learning objectives](learning-plan.md#lab-22-vlan-trunking-8021q) · 📖 [Commands](README.md#lab-22--vlan-trunking)

VLANs 10 and 20 span two switches via a tagged 802.1Q trunk link.

```mermaid
graph LR
    subgraph SW1["Switch 1"]
        hsv10["host-sw1-v10\n10.10.0.11  VLAN 10"]
        hsv20["host-sw1-v20\n10.20.0.11  VLAN 20"]
        sw1(["sw1"])
        hsv10 --- sw1
        hsv20 --- sw1
    end

    subgraph SW2["Switch 2"]
        sw2(["sw2"])
        hev10["host-sw2-v10\n10.10.0.22  VLAN 10"]
        hev20["host-sw2-v20\n10.20.0.22  VLAN 20"]
        sw2 --- hev10
        sw2 --- hev20
    end

    sw1 ---|"802.1Q trunk\nVLAN 10 + 20"| sw2
```

---

## Phase 3 — Layer 3 Routing & ENI Concepts

### Lab 3.1 — Inter-VLAN Routing (Router-on-a-Stick)
> 📋 [Learning objectives](learning-plan.md#lab-31-inter-vlan-routing-router-on-a-stick) · 📖 [Commands](README.md#lab-31--inter-vlan-routing-router-on-a-stick)

A single FRR router uses 802.1Q subinterfaces to route between VLANs via a trunk uplink from the switch.

```mermaid
graph LR
    subgraph VLAN10["VLAN 10 — 10.10.0.0/24"]
        hv10["host-v10\n10.10.0.1\ngw 10.10.0.254"]
    end

    subgraph VLAN20["VLAN 20 — 10.20.0.0/24"]
        hv20["host-v20\n10.20.0.1\ngw 10.20.0.254"]
    end

    sw1(["sw1\nL2 switch"])
    r1["router1\neth1.10 → 10.10.0.254\neth1.20 → 10.20.0.254"]

    hv10 --- sw1
    hv20 --- sw1
    sw1 ---|"802.1Q trunk\nVLAN 10 + 20"| r1
```

### Lab 3.2 — Layer 3 Switch (SVIs)
> 📋 [Learning objectives](learning-plan.md#lab-32-layer-3-switch-svi) · 📖 [Commands](README.md#lab-32--layer-3-switch-svis)

Routing happens inside the switch itself via Switched Virtual Interfaces — no external router needed.

```mermaid
graph TD
    l3sw["l3switch\nSVI br0.10 → 10.10.0.254\nSVI br0.20 → 10.20.0.254"]

    subgraph VLAN10["VLAN 10"]
        hv10a["host-v10-a\n10.10.0.1"]
        hv10b["host-v10-b\n10.10.0.2"]
    end

    subgraph VLAN20["VLAN 20"]
        hv20a["host-v20-a\n10.20.0.1"]
        hv20b["host-v20-b\n10.20.0.2"]
    end

    hv10a --- l3sw
    hv10b --- l3sw
    hv20a --- l3sw
    hv20b --- l3sw
```

### Lab 3.3 — ENI Simulation
> 📋 [Learning objectives](learning-plan.md#lab-33-virtual-network-interfaces-eni-concepts) · 📖 [Commands](README.md#lab-33--eni-simulation)

Demonstrates multi-homing, floating IPs, and failover using Linux network namespaces.

```mermaid
graph LR
    cl["client\n172.16.1.100"]
    vpc(["vpc-router\nsubnet-1: 172.16.1.254/24\nsubnet-2: 172.16.2.254/24"])
    ia["instance-a\neth1: 172.16.1.10\neth2: 172.16.2.10\nsecondary: .11, .12"]
    ib["instance-b\n172.16.1.20"]

    cl -->|"subnet-1"| vpc
    vpc -->|"eth1 → subnet-1"| ia
    vpc -->|"eth2 → subnet-2"| ia
    vpc --> ib
```

---

## Phase 4 — BGP Fundamentals

### Lab 4.1 — Basic eBGP Peering
> 📋 [Learning objectives](learning-plan.md#lab-41-basic-bgp-peering) · 📖 [Commands](README.md#lab-41--basic-bgp-peering)

Two routers in separate autonomous systems exchange prefixes over an eBGP session.

```mermaid
graph LR
    ra["router-a\nAS 65001\nlo: 192.168.1.0/24\nlink: 10.0.0.1/30"]
    rb["router-b\nAS 65002\nlo: 172.16.0.0/24\nlink: 10.0.0.2/30"]

    ra <-->|"eBGP"| rb
```

### Lab 4.2 — BGP Attributes & Path Selection
> 📋 [Learning objectives](learning-plan.md#lab-42-bgp-attributes--path-selection) · 📖 [Commands](README.md#lab-42--bgp-attributes--path-selection)

Triangle of three ASes. `router-c` has two paths to `router-a` — used to explore LOCAL_PREF, MED, and AS-PATH prepending.

```mermaid
graph TD
    ra["router-a\nAS 65001\nlo: 192.168.1.0/24"]
    rb["router-b\nAS 65002"]
    rc["router-c\nAS 65003\nlo: 172.16.3.0/24"]

    ra <-->|"eBGP\n10.0.12.x/30"| rb
    ra <-->|"eBGP\n10.0.13.x/30"| rc
    rb <-->|"eBGP\n10.0.23.x/30"| rc
```

### Lab 4.3 — iBGP with Route Reflector
> 📋 [Learning objectives](learning-plan.md#lab-43-ibgp-and-route-reflectors) · 📖 [Commands](README.md#lab-43--ibgp-with-route-reflector)

Four routers in AS 65000. `rr1` acts as a route reflector, eliminating the need for a full iBGP mesh.

```mermaid
graph TD
    rr1(["rr1\nRoute Reflector\nAS 65000\nlo: 10.255.0.1"])

    r1["r1\nlo: 10.255.0.11\n192.168.11.0/24"] <-->|"iBGP"| rr1
    r2["r2\nlo: 10.255.0.12\n192.168.12.0/24"] <-->|"iBGP"| rr1
    r3["r3\nlo: 10.255.0.13\n192.168.13.0/24"] <-->|"iBGP"| rr1
    r4["r4\nlo: 10.255.0.14\n192.168.14.0/24"] <-->|"iBGP"| rr1
```

---

## Phase 5 — AWS Direct Connect Simulation

### Lab 5.1 — Direct Connect Architecture Overview
> 📋 [Learning objectives](learning-plan.md#lab-51-direct-connect-architecture-overview) · 📖 [Commands](README.md#lab-51--direct-connect-architecture-overview)

Minimal L3-only chain introducing component names and roles before BGP is added in later labs.

```mermaid
graph LR
    cr["customer-router\n10.1.1.1/30"]
    dx(["dx-crossconnect\n10.1.1.2 / 10.1.2.1"])
    ae["aws-edge\n10.1.2.2 / 10.1.3.1"]
    vgw(["vgw\n10.1.3.2 / 10.0.0.254"])
    ec2["ec2\n10.0.0.10/24"]

    cr --- dx --- ae --- vgw --- ec2
```

### Lab 5.2 — Private VIF
> 📋 [Learning objectives](learning-plan.md#lab-52-private-virtual-interface-vif) · 📖 [Commands](README.md#lab-52--private-vif)

BGP over VLAN 100 between on-prem and VPC. Mirrors real AWS DX Private VIF architecture.

```mermaid
graph LR
    opr["on-prem-router\nAS 65001\nBGP: 169.254.100.1/30"]
    dx(["dx-location\nL2 bridge"])
    aer["aws-edge-router\nAS 64512\nBGP: 169.254.100.2/30"]
    vgw(["vpc-gateway\n10.200.0.2 / 10.0.0.254"])
    ec2["ec2-instance\n10.0.0.10/24"]

    opr ---|"VLAN 100 trunk"| dx
    dx  ---|"VLAN 100"| aer
    aer --- vgw --- ec2
```

### Lab 5.3 — Public VIF
> 📋 [Learning objectives](learning-plan.md#lab-53-public-virtual-interface) · 📖 [Commands](README.md#lab-53--public-vif)

Adds a second VIF (VLAN 200) on the same trunk to reach AWS public service endpoints directly over DX.

```mermaid
graph LR
    opr["on-prem-router\nAS 65001\npublic pfx: 203.0.113.0/24"]
    ae["aws-edge\nAS 64512"]

    subgraph PrivateVIF["Private VIF → VPC"]
        vgw(["vgw\n10.0.0.254/24"])
        ec2["ec2\n10.0.0.10"]
        vgw --> ec2
    end

    subgraph PublicVIF["Public VIF → AWS Services"]
        aps["aws-public-svc\nS3: 52.92.0.0/20\nDynamoDB: 52.94.0.0/22"]
    end

    opr -->|"VLAN 100: Private VIF"| ae
    opr -->|"VLAN 200: Public VIF"| ae
    ae --> vgw
    ae --> aps
```

### Lab 5.4 — Transit VIF (TGW)
> 📋 [Learning objectives](learning-plan.md#lab-54-transit-virtual-interface-with-tgw) · 📖 [Commands](README.md#lab-54--transit-vif-tgw)

A single DX connection reaches multiple VPCs via a Transit Gateway.

```mermaid
graph LR
    opr["on-prem-router\nAS 65001\n10.100.0.0/22"]
    ae["aws-edge\nAS 64512"]
    tgw(["Transit Gateway"])

    subgraph VPCA["VPC-A — 10.0.1.0/24"]
        vpa["vpc-a-gw\n10.0.1.254"]
        ea["ec2-vpc-a\n10.0.1.10"]
        vpa --> ea
    end

    subgraph VPCB["VPC-B — 10.0.2.0/24"]
        vpb["vpc-b-gw\n10.0.2.254"]
        eb["ec2-vpc-b\n10.0.2.10"]
        vpb --> eb
    end

    subgraph VPCC["VPC-C — 10.0.3.0/24"]
        vpcc["vpc-c-gw\n10.0.3.254"]
        ecc["ec2-vpc-c\n10.0.3.10"]
        vpcc --> ecc
    end

    opr -->|"VLAN 300: Transit VIF"| ae
    ae --> tgw
    tgw --> vpa
    tgw --> vpb
    tgw --> vpcc
```

### Lab 5.5 — Advanced DX: Redundant Connections
> 📋 [Learning objectives](learning-plan.md#lab-55-advanced-dx-scenarios) · 📖 [Commands](README.md#lab-55--redundant-dx-connections)

Active/passive failover across two DX links. The backup path uses AS-PATH prepending to be less preferred.

```mermaid
graph LR
    opr["on-prem-router\nAS 65001\n10.100.0.0/22"]

    subgraph Primary["Primary DX"]
        ae1["aws-edge-1\n169.254.100.2/30"]
    end

    subgraph Backup["Backup DX (AS-PATH prepended)"]
        ae2["aws-edge-2\n169.254.200.2/30"]
    end

    vgw(["vpc-gateway"])
    ec2["ec2-instance\n10.0.0.10"]

    opr -->|"VLAN 100 — active"| ae1
    opr -->|"VLAN 200 — standby"| ae2
    ae1 --> vgw
    ae2 -.->|"failover only"| vgw
    vgw --> ec2
```

### Lab 5.6 — ENI Simulation in VPC
> 📋 [Learning objectives](learning-plan.md#lab-56-eni-simulation-in-vpc-context) · 📖 [Commands](README.md#lab-56--eni-simulation-in-vpc)

Three-tier application across public, app, and DB subnets. Demonstrates floating IP failover between DB nodes.

```mermaid
graph TD
    ext["external-client\n10.0.1.50"]

    subgraph Public["Public Subnet — 10.0.1.0/24"]
        nat["nat-instance\npublic: 10.0.1.10\nEIP: 10.0.1.100"]
    end

    subgraph App["App Subnet — 10.0.2.0/24"]
        app["app-server\n10.0.2.20"]
    end

    subgraph DB["DB Subnet — 10.0.3.0/24"]
        dbp["db-primary\n10.0.3.10\nfloating: 10.0.3.100"]
        dbs["db-standby\n10.0.3.20"]
    end

    ext --> nat
    nat --> app
    app --> dbp
    dbp -.->|"failover"| dbs
```

---

## Phase 6 — Advanced Topics

### Lab 6.1 — ECMP & Load Balancing over DX
> 📋 [Learning objectives](learning-plan.md#lab-61-ecmp-and-load-balancing) · 📖 [Commands](README.md#lab-61--ecmp--load-balancing-over-dx)

Both DX paths active simultaneously with equal cost. Traffic is hash-distributed across them.

```mermaid
graph LR
    opr["on-prem-router\nAS 65001\nECMP max-paths 2"]
    ae1["aws-edge-1\n169.254.10.2/30"]
    ae2["aws-edge-2\n169.254.20.2/30"]
    vgw(["vpc-gw"])
    ec2["ec2\n10.0.0.10"]

    opr -->|"VLAN 100 — path A"| ae1
    opr -->|"VLAN 100 — path B"| ae2
    ae1 --> vgw
    ae2 --> vgw
    vgw --> ec2
```

### Lab 6.2 — QoS & Traffic Shaping
> 📋 [Learning objectives](learning-plan.md#lab-62-qos-and-traffic-shaping) · 📖 [Commands](README.md#lab-62--qos--traffic-shaping)

DSCP marking and HTB queuing at the CPE router simulating a rate-limited DX port.

```mermaid
graph LR
    oph["on-prem-host\n10.100.0.10/24"]
    opr["on-prem-router\nDSCP marking\nHTB shaper @ 100 Mbps"]
    ae["aws-endpoint\n10.0.0.10"]

    oph -->|"unmarked traffic"| opr
    opr -->|"EF / AF31 / AF21 / CS0"| ae
```

### Lab 6.3 — Monitoring & Troubleshooting
> 📋 [Learning objectives](learning-plan.md#lab-63-monitoring-and-troubleshooting) · 📖 [Commands](README.md#lab-63--monitoring--troubleshooting)

Intentionally broken Private VIF topology. Diagnose and fix deliberate faults in the BGP configs.

```mermaid
graph LR
    opr["on-prem-router\nAS 65001\n⚠ broken config"]
    ae["aws-edge\n⚠ broken config"]
    vgw(["vpc-gw\n⚠ broken config"])
    ec2["ec2\n10.0.0.10"]

    opr ---|"VLAN 100"| ae
    ae --- vgw --- ec2
```

### Lab 6.4 — Advanced ENI Patterns
> 📋 [Learning objectives](learning-plan.md#lab-64-advanced-eni-patterns) · 📖 [Commands](README.md#lab-64--advanced-eni-patterns)

Four concurrent scenarios: appliance cluster failover, per-ENI security isolation, Lambda-style shared ENI, and pod trunk ENI.

```mermaid
graph TD
    vr(["vpc-router\n10.0.x.254/24"])
    cl["client\n10.0.0.50"]

    subgraph HA["HA Appliance Cluster"]
        aa["appliance-active\n10.0.3.10  floating: 10.0.3.100"]
        asby["appliance-standby\n10.0.3.20"]
        aa -.->|"failover"| asby
    end

    subgraph MultiENI["Multi-ENI App Server"]
        app["app-server\nweb ENI: 10.0.0.30\napp ENI: 10.0.1.30\ndb  ENI: 10.0.2.30"]
    end

    subgraph SharedENI["Lambda-style Shared ENI"]
        leh["lambda-eni-host\n10.0.1.50–54/32"]
    end

    subgraph TrunkENI["Pod Trunk ENI"]
        etnh["eni-trunk-host\nVLAN 101–103\npods: .61 / .62 / .63"]
    end

    cl -->|"mgmt"| vr
    aa -->|"HA + mgmt"| vr
    asby -->|"HA + mgmt"| vr
    app -->|"web / app / db ENIs"| vr
    leh -->|"app subnet"| vr
    etnh -->|"trunked VLANs"| vr
```
