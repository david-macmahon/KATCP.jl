"""
    estimate_fpga_clock(client, interval=1) -> Estimated clock frequency in MHz

Return an estimate of the FPGA clock frequency in MHz.

Read `sys_clkcounter` twice, sleeping `interval` seconds between the readings,
and compute the FPGA clock frequency.
"""
function estimate_fpga_clock(client::Client, interval=1)
    tic = regread(client, "sys_clkcounter")
    sleep(interval)
    toc = regread(client, "sys_clkcounter")
    (toc-tic) / interval / 1e6
end
