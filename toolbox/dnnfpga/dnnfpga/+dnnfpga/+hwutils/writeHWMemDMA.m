function readBack=writeHWMemDMA(hw,memSelect,v,width)



    dnnfpga.hwutils.includeHWAddresses(hw.target);


    mode=1;
    h=hw.jtagHandle;
    memS=dnnfpga.hwutils.debugSelectEncode(memSelect);

    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(ddrbase+writeScratchAddr),v,h);



    len=numel(v);

    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugSelect_offset),memS,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAEnable_offset),true,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMALength_offset),uint32(len),h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAWidth_offset),uint32(width),h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAOffset_offset),uint32(writeScratchAddr),h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMADirection_offset),true,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugEnable_offset),true,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAStart_offset),true,h);
    while(dnnfpga.hwutils.readSignal(1,dnnfpga.hwutils.numTo8Hex(dma_from_ddr4_done),1,0,h,'OutputDataType','uint32')~=1)
        pause(1);
    end
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAStart_offset),false,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAEnable_offset),false,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugEnable_offset),false,h);




    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugSelect_offset),memS,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAEnable_offset),true,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMALength_offset),uint32(len),h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAWidth_offset),uint32(width),h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAOffset_offset),uint32(readScratchAddr),h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMADirection_offset),false,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugEnable_offset),true,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAStart_offset),true,h);
    while(dnnfpga.hwutils.readSignal(1,dnnfpga.hwutils.numTo8Hex(dma_to_ddr4_done),1,0,h,'OutputDataType','uint32')~=1)
        pause(1);
    end
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAStart_offset),false,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugDMAEnable_offset),false,h);
    dnnfpga.hwutils.writeSignal(mode,dnnfpga.hwutils.numTo8Hex(debugEnable_offset),false,h);

    readBack=dnnfpga.hwutils.readSignal(mode,dnnfpga.hwutils.numTo8Hex(ddrbase+readScratchAddr),len,zeros(1,len),h,'OutputDataType','single');
end
