function frameParam=initVTC(jtagMaster,vtcInfo)


    jtagMaster.writememory(vtcInfo.CTL,uint32(0));
    jtagMaster.writememory(vtcInfo.CTL,uint32(1));
    pause(0.5);


    encRegVal=jtagMaster.readmemory(vtcInfo.DENC,1);
    vidFormatVal=bin2dec(num2str(bitget(encRegVal,4:-1:1)));
    switch vidFormatVal
    case 0
        frameParam.bytePerPixel=2;
    case{1,2}
        frameParam.bytePerPixel=4;
    case 3
        frameParam.bytePerPixel=1;
    otherwise
        frameParam.bytePerPixel=2;
    end




    aRegVal=jtagMaster.readmemory(vtcInfo.DASIZE,1);
    frameParam.width=bin2dec(num2str(bitget(aRegVal,13:-1:1)));
    frameParam.height=bin2dec(num2str(bitget(aRegVal,28:-1:16)))/frameParam.bytePerPixel;


    vRegVal=jtagMaster.readmemory(vtcInfo.DVSIZE,1);

    frameParam.horizontalPorch=soc.util.getVideoPorchTiming(frameParam.width);
    frameParam.verticalPorch=bin2dec(num2str(bitget(vRegVal,13:-1:1)))-frameParam.height;
    frameParam.HDMIOutMemRegion=frameParam.width*frameParam.height*frameParam.bytePerPixel;
end

