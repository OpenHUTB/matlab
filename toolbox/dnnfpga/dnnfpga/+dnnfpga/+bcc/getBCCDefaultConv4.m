function bcc=getBCCDefaultConv4(threadNumLimit,opDDRBitWidthLimit,kernelDataType,dataTransNum,RoundingMode,MemoryMinDepth)







    if(nargin<2)
        opDDRBitWidthLimit=128;
    end

    if(nargin<3)
        kernelDataType='single';
    end

    if(nargin<4)


        dataTransNum=1;
    end

    if(nargin<5)
        RoundingMode='Round';
    end

    if(nargin<6)
        MemoryMinDepth=[32,32,1];
    end




    dataTransNum=power(2,nextpow2(dataTransNum));


    bcc.kernelDataType=kernelDataType;
    bcc.RoundingMode=RoundingMode;

    format.opMin=0;
    format.opMax=3;
    format.idMin=format.opMax;
    format.idMax=5;
    format.deltaMin=5;
    format.deltaMax=7;










    format.newPCMin=7;
    format.newPCMax=20;

    format.sMin=format.opMax;
    format.sMax=15;
    format.wMin=15;
    format.wMax=27;
    format.op2Min=27;
    format.op2Max=29;




    format.funcMin=format.opMax;
    format.funcMax=format.funcMin+format.newPCMax-format.newPCMin;

    format.limitMin=7;
    format.limitMax=20;
    format.instructionW=32;
    format.instructionDSync=1;
    format.instructionDProg=14;
    format.instructionMemSizeLimit=512;
    format.opCodeSW=0;
    format.opCodeGoto=1;
    format.opCodeCall=2;
    format.opCodeReturn=3;
    format.opCodeSet=4;
    format.opCodeReset=5;
    bcc.syncInstFormat=format;

    bcc.conv=dnnfpga.bcc.getBCCDefaultConv2(threadNumLimit,opDDRBitWidthLimit,kernelDataType,RoundingMode,MemoryMinDepth);





    bcc.conv.resultMemDepthLimit=[3;227;227];
    bcc.conv.inputMemDepthLimit=[3;227;227];

    bcc.ip0=dnnfpga.bcc.getBCCDefaultInputP(threadNumLimit,[],kernelDataType,dataTransNum);
    bcc.ip1=dnnfpga.bcc.getBCCDefaultInputP(threadNumLimit,[],kernelDataType,dataTransNum);
    bcc.op0=dnnfpga.bcc.getBCCDefaultOutputP(threadNumLimit,[],kernelDataType,dataTransNum);

end


