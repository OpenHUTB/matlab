function name=verboseNameHSP(vendor)




    switch(lower(vendor))
    case 'intel'
        name='Deep Learning HDL Toolbox Support Package for Intel FPGA and SoC Devices';
    case 'xilinx'
        name='Deep Learning HDL Toolbox Support Package for Xilinx FPGA and SoC Devices';
    otherwise
        msg=message('dnnfpga:workflow:InvalidVendor',vendor,'Intel, Xilinx');
        error(msg);
    end
end


