# KATCP.jl Documentation

KATCP.jl is a Julia package for communicating via the Karoo Array Telescope
Control Protocol (KATCP).  More information about KATCP can be found at the
[CASPER Wiki](http://casper.berkeley.edu/wiki/KATCP), including the [KATCP
specification](http://casper.berkeley.edu/wiki/images/1/11/NRF-KAT7-6.0-IFCE-002-Rev4.pdf)
in PDF format.


```@contents
```

## Connecting to a KATCP server

To communicate with a KATCP server you need to construct a `KATCP.Client`
object.  You will pass this object to other functions to read/write from/to
your KATCP-enabled device.

```@docs
KATCP.Client
```

### Example

```julia
client = KATCP.Client("katcphost") # Use default port 7147
client = KATCP.Client("katcphost", 7147) # Specify port explicitly
```

## Get list of devices

The [`listdev`](@ref) function returns a `Dict` that maps device names to device
sizes (in bytes).

```@docs
listdev
```

### Example

```julia-repl
julia> devmap = listdev(client)
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

## Reading and writing registers

You can use the [`regread`](@ref) and [`regwrite`](@ref) function to read/write
registers.

```@docs
regread
regwrite
```

### Example

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

## Reading and writing memory devices

The memory space of Block RAMs and Yellow Blocks can be read from and written to
using `read` and `write`.  This also works for registers, which are essentially
just 4 byte memories.

!!! info

    All reads and writes in `KATCP.jl` must be aligned on 4 byte boundaries.
    Currently, `read` only returns `UInt32` values.  Some conversion from other
    Integer types are supported by `write`, but this is subject to change.  You
    are stronly encouraged to `reinterpret` or `convert` your data as needed if
    you desire a different numerical type.

```@docs
read(::KATCP.Client, ::Any, ::Any, ::Any)
write(::KATCP.Client, ::Any, ::AbstractArray{<:UInt32}, ::Any)
```

### Example

```julia-repl
julia> write(client, "sys_scratchpad", 0x11223344)

julia> read(client, "sys_scratchpad", 0, 4)
1-element Vector{UInt32}:
 0x11223344
```

## Estimate FPGA clock frequency

```@docs
estimate_fpga_clock
```

### Example

```julia-repl
julia> estimate_fpga_clock(client)
257.542124
```

## Index

```@index
```
