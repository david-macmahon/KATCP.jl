# KATCP.jl

Karoo Array Telescope Control Protocol client for Julia

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://david-macmahon.github.io/KATCP.jl/dev)

## Introduction

KATCP.jl is a Julia package for communicating via the Karoo Array Telescope
Control Protocol (KATCP).  More information about KATCP can be found at the
[CASPER Wiki][], including the [KATCP specification][] in PDF format.

[CASPER Wiki]: http://casper.berkeley.edu/wiki/KATCP
[KATCP Specification]: http://casper.berkeley.edu/wiki/images/1/11/NRF-KAT7-6.0-IFCE-002-Rev4.pdf

## Usage

### Connect to KATCP server

```
client = KATCP.client("katcphost")
client = KATCP.client("katcphost", 7147)
```

### Get list of devices

The `listdev` function returns a `Dict` mapping device names to device sizes (in
bytes).

```julia-repl
julia> listdev(client)
Dict{String, Int64} with 51 entries:
  "onehundred_gbe_gmac_reg_arp_size"             => 4
  "onehundred_gbe_gmac_reg_word_size"            => 4
  "onehundred_gbe_gmac_reg_local_ip_netmask"     => 4
  "sys"                                          => 32
  "onehundred_gbe_gmac_arp_cache_read_data"      => 4
  "onehundred_gbe_gmac_reg_bytes_rdy"            => 4
  "onehundred_gbe_gmac_reg_core_type"            => 4
  "onehundred_gbe_gmac_reg_tx_almost_full_count" => 4
  "onehundred_gbe_gmac_arp_cache_write_address"  => 4
  "lpmode"                                       => 4
  "sys_scratchpad"                               => 4
  "onehundred_gbe_gmac_arp_cache_read_address"   => 4
  "onehundred_gbe_gmac_reg_mac_address_h"        => 4
  "onehundred_gbe_gmac_reg_tx_packet_rate"       => 4
  "onehundred_gbe_gmac_reg_phy_status_h"         => 4
  "qsfp_rst"                                     => 4
  "onehundred_gbe"                               => 65536
  ⋮                                              => ⋮
```

### Read and write registers

```julia-repl
julia> regread(client, "sys_scratchpad")
0x00000000

julia> regwrite(client, "sys_scratchpad", 12345678)

julia> regread(client, "sys_scratchpad")
0x00bc614e

julia> regwrite(client, "sys_scratchpad", 0x12345678)

julia> regread(client, "sys_scratchpad")
0x12345678

julia> regwrite(client, "sys_scratchpad", 0)

julia> regread(client, "sys_scratchpad")
0x00000000
```

### Reading and writing memory devices

The memory space of Block RAMs and Yellow Blocks can be read from and written to
using `read` and `write`.  This also works for registers, which are essentially
just 4 byte memories.  See the documentation for data type details.

```julia
Base.read(client::KATCP.Client, name, offset, length)
Base.read(client::KATCP.Client, name; offset=0, length=4)

Base.write(client::KATCP.Client, name, data, offset=0)
```

```julia-repl
julia> write(client, "sys_scratchpad", 0x11223344)

julia> read(client, "sys_scratchpad", 0, 4)
1-element Vector{UInt32}:
 0x11223344
```

### Estimate FPGA clock frequency

```julia
estimate_fpga_clock(client, interval=1)
```

```julia-repl
julia> estimate_fpga_clock(client)
257.542124
```
