# Consul Shared Config: Agent

datacenter = "dc1"

# Host IP
## eth1 = private VPC IP
bind_addr = "{{ GetInterfaceIP `eth1` }}"
# OinkServer dummy interface
## "{{ GetInterfaceIP \"oinkserver0\" }}"
client_addr = "169.254.1.1"

# Upstream DNS resolvers
recursors = ["1.1.1.1", "1.0.0.1"]
