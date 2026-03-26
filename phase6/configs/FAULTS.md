# FAULTS.md — Answer key for Lab 6.3 fault injection scenarios
# ============================================================
#
# FAULT 1 — Wrong remote-as on on-prem-router
#   File: configs/on-prem-broken.conf
#   Broken line:  neighbor 169.254.100.2 remote-as 99999
#   Fixed line:   neighbor 169.254.100.2 remote-as 64512
#   Symptom: BGP stays in "Active" or briefly "OpenSent" then resets
#
# FAULT 2 — Missing "activate" on aws-edge
#   File: configs/aws-edge-broken.conf
#   Missing line under address-family: neighbor 169.254.100.1 activate
#   Symptom: BGP session Established but no IPv4 routes exchanged
#
# FAULT 3 — network statement for prefix not in RIB on vpc-gw
#   File: configs/vpc-gw-broken.conf
#   Broken: network 10.0.0.0/24  (but loopback has 10.0.0.0/16 — prefix mismatch!)
#   Fix: change to network 10.0.0.0/24 AND add the /24 to the loopback interface
#   Symptom: BGP session up, aws-edge receives no VPC prefix from vpc-gw
#
# FAULT 4 — ip_forward disabled on aws-edge (BONUS — not pre-injected)
#   Unlike faults 1-3, this one is NOT broken in the deployed topology.
#   The exec section enables ip_forward. To practice this fault, manually
#   disable it after deploy:
#     docker exec clab-lab6-3-troubleshoot-aws-edge sysctl -w net.ipv4.ip_forward=0
#   Symptom: BGP works, routes installed everywhere, but ping through aws-edge fails
#   Fix: sysctl -w net.ipv4.ip_forward=1
