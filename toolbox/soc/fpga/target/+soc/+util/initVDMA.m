function initVDMA(jtagMaster,vdmaInfo,frameParam,memoryRegion)



    videoParam.vdmaWidth=frameParam.width*frameParam.bytePerPixel;
    videoParam.vdmaHeight=frameParam.height;
    videoParam.vdmaStride=frameParam.width*frameParam.bytePerPixel;
    videoParam.frameStride=videoParam.vdmaWidth*videoParam.vdmaHeight;


    switch vdmaInfo.type
    case 'read'
        writememory(jtagMaster,vdmaInfo.MM2S_ENABLE,uint32(0));
        writememory(jtagMaster,vdmaInfo.MM2S_ENABLE,uint32(1));
        writememory(jtagMaster,vdmaInfo.MM2S_FLAGS,uint32(3));
        writememory(jtagMaster,vdmaInfo.MM2S_SA,uint32(hex2dec(memoryRegion.VDMAReadMemRegion)));
        writememory(jtagMaster,vdmaInfo.MM2S_XLENGTH,uint32(videoParam.vdmaWidth-1));
        writememory(jtagMaster,vdmaInfo.MM2S_YLENGTH,uint32(videoParam.vdmaHeight-1));
        writememory(jtagMaster,vdmaInfo.MM2S_SRCSTRIDE,uint32(videoParam.vdmaWidth));
        writememory(jtagMaster,vdmaInfo.MM2S_FLOCK,uint32(1));
        writememory(jtagMaster,vdmaInfo.MM2S_FRAMESTRIDE,uint32(videoParam.frameStride));
        writememory(jtagMaster,vdmaInfo.MM2S_START,uint32(1));
    case 'write'
        writememory(jtagMaster,vdmaInfo.S2MM_ENABLE,uint32(0));
        writememory(jtagMaster,vdmaInfo.S2MM_ENABLE,uint32(1));
        writememory(jtagMaster,vdmaInfo.S2MM_FLAGS,uint32(3));
        writememory(jtagMaster,vdmaInfo.S2MM_DA,uint32(hex2dec(memoryRegion.VDMAWriteMemRegion)));
        writememory(jtagMaster,vdmaInfo.S2MM_XLENGTH,uint32(videoParam.vdmaWidth-1));
        writememory(jtagMaster,vdmaInfo.S2MM_YLENGTH,uint32(videoParam.vdmaHeight-1));
        writememory(jtagMaster,vdmaInfo.S2MM_DESTSTRIDE,uint32(videoParam.vdmaWidth));
        writememory(jtagMaster,vdmaInfo.S2MM_FLOCK,uint32(1));
        writememory(jtagMaster,vdmaInfo.S2MM_FRAMESTRIDE,uint32(videoParam.frameStride));
        writememory(jtagMaster,vdmaInfo.S2MM_START,uint32(1));
    otherwise
        error('cannot recognize the type of this VDMA');

    end

