function initVDMAFrameBuffer(jtagMaster,vdmaInfo,frameParam,memoryRegion)




    videoParam.vdmaWidth=frameParam.width*frameParam.bytePerPixel;
    videoParam.vdmaHeight=frameParam.height;
    videoParam.vdmaStride=frameParam.width*frameParam.bytePerPixel;
    videoParam.frameStride=videoParam.vdmaWidth*videoParam.vdmaHeight;

    FLOCK_FRAMES=3;
    FLOCK_FRAMEDISTANCE=1;
    FLOCK_MODE=1;


    switch vdmaInfo.type
    case 'buffer'
        addr=uint32(hex2dec(memoryRegion.VDMAFrameBufMemRegion));
        FLOCK_WAIT_WRITER=1;
    case 'hdmiOut'
        if isfield(memoryRegion,'VDMAFrameBufMemRegion')
            addr=frameParam.HDMIOutMemRegion*3+uint32(hex2dec(memoryRegion.VDMAFrameBufMemRegion));
        else
            addr=frameParam.HDMIOutMemRegion*3;
        end
        FLOCK_WAIT_WRITER=0;
    otherwise
        error('cannot recognize the type of this VDMA frame buffer');
    end

    FLOCKREG=bitor(bitor(bitshift(FLOCK_FRAMEDISTANCE-1,16),bitshift(FLOCK_WAIT_WRITER,9)),bitor(bitshift(FLOCK_MODE,8),FLOCK_FRAMES));


    writememory(jtagMaster,vdmaInfo.S2MM_ENABLE,uint32(0));
    writememory(jtagMaster,vdmaInfo.S2MM_ENABLE,uint32(1));
    writememory(jtagMaster,vdmaInfo.S2MM_FLAGS,uint32(11));
    writememory(jtagMaster,vdmaInfo.S2MM_DA,uint32(addr));
    writememory(jtagMaster,vdmaInfo.S2MM_XLENGTH,uint32(videoParam.vdmaWidth-1));
    writememory(jtagMaster,vdmaInfo.S2MM_YLENGTH,uint32(videoParam.vdmaHeight-1));
    writememory(jtagMaster,vdmaInfo.S2MM_DESTSTRIDE,uint32(videoParam.vdmaStride));
    writememory(jtagMaster,vdmaInfo.S2MM_FLOCK,uint32(FLOCKREG));
    writememory(jtagMaster,vdmaInfo.S2MM_FRAMESTRIDE,uint32(videoParam.frameStride));
    writememory(jtagMaster,vdmaInfo.S2MM_START,uint32(1));


    writememory(jtagMaster,vdmaInfo.MM2S_ENABLE,uint32(0));
    writememory(jtagMaster,vdmaInfo.MM2S_ENABLE,uint32(1));
    writememory(jtagMaster,vdmaInfo.MM2S_FLAGS,uint32(11));
    writememory(jtagMaster,vdmaInfo.MM2S_SA,uint32(addr));
    writememory(jtagMaster,vdmaInfo.MM2S_XLENGTH,uint32(videoParam.vdmaWidth-1));
    writememory(jtagMaster,vdmaInfo.MM2S_YLENGTH,uint32(videoParam.vdmaHeight-1));
    writememory(jtagMaster,vdmaInfo.MM2S_SRCSTRIDE,uint32(videoParam.vdmaStride));
    writememory(jtagMaster,vdmaInfo.MM2S_FLOCK,uint32(FLOCKREG));
    writememory(jtagMaster,vdmaInfo.MM2S_FRAMESTRIDE,uint32(videoParam.frameStride));
    writememory(jtagMaster,vdmaInfo.MM2S_START,uint32(1));
end

