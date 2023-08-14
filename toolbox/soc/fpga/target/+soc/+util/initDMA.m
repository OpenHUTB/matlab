function initDMA(jtagMaster,dmaInfo,memoryRegion)



    switch dmaInfo.type
    case 'read'
        jtagMaster.writememory(dmaInfo.MM2S_ENABLE,uint32(1));
        jtagMaster.writememory(dmaInfo.MM2S_SA,uint32(hex2dec(memoryRegion.DMAReadMemRegion)));

        jtagMaster.writememory(dmaInfo.MM2S_LENGTH,uint32(dmaInfo.bufferSize-1));
        jtagMaster.writememory(dmaInfo.MM2S_START,uint32(1));
    case 'write'
        jtagMaster.writememory(dmaInfo.S2MM_ENABLE,uint32(1));
        jtagMaster.writememory(dmaInfo.S2MM_DA,uint32(hex2dec(memoryRegion.DMAWriteMemRegion)));

        jtagMaster.writememory(dmaInfo.S2MM_LENGTH,uint32(dmaInfo.bufferSize-1));
        jtagMaster.writememory(dmaInfo.S2MM_START,uint32(1));
    otherwise
        error('cannot recognize the type of this DMA');
    end
end

