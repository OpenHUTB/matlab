function isuse=useNFP(hPC)




    switch(class(hPC))
    case 'dnnfpga.config.CNN4ProcessorConfig'


        convModule=hPC.getModule("conv");
        dataType=convModule.KernelDataType;
        isuse=strcmpi(hPC.SynthesisTool,'Xilinx Vivado')||...
        (strcmpi(dataType,'int8')&&strcmpi(hPC.SynthesisTool,'Altera QUARTUS II'));
    case 'dnnfpga.config.CNN5ProcessorConfig'


        convModule=hPC.getModule("conv");
        dataType=convModule.KernelDataType;
        isuse=strcmpi(hPC.SynthesisTool,'Xilinx Vivado')||...
        (strcmpi(dataType,'int8')&&strcmpi(hPC.SynthesisTool,'Altera QUARTUS II'));

    otherwise
        isuse=0;
    end

end

