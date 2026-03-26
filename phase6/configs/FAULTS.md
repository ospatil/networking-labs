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
# FAULT 4 — ip_forward disabled on aws-edge
#   Not in FRR config — in the exec section. Remove the sysctl line and redeploy.
#   Symptom: BGP works, routes installed everywhere, but ping through aws-edge fails
