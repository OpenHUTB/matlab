function ipcore_name=getIPCoreName(dut_gcb)

    ipcore_name=soc.util.formatIPCoreName(get_param(dut_gcb,'Name'));
end


