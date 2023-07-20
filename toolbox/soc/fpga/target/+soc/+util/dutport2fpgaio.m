function fpga_io=dutport2fpgaio(vendor,dut_blk,dut_port,intfInfo)
    ip_name=soc.util.getIPCoreName(dut_blk);
    thisIntfInfo=intfInfo([dut_blk,'/',dut_port]);
    IO_intf=thisIntfInfo.interface;
    if strcmpi(IO_intf,'External Port')
        port_name=regexprep(strtrim(dut_port),'[\W]*','_');

        port_name=regexprep(port_name,'(_)+','_');
    else
        port_name=regexprep(IO_intf,'[\W]*','_');
    end

    if strcmpi(vendor,'xilinx')
        fpga_io=[ip_name,'/',port_name];
    else
        fpga_io=[ip_name,'.',port_name];
    end

end