function bcc=getBCCDefaultInputP(threadNumLimit,~,kernelDataType,dataTransNum)







    if(nargin<3)
        kernelDataType='single';
    end

    if(nargin<4)


        dataTransNum=1;
    end





    dataTransNum=power(2,nextpow2(dataTransNum));


    bcc.kernelDataType=kernelDataType;
    bcc.layerNumWLimit=4096;
    bcc.layerConfigNumWLimit=14;
    bcc.imageNumWLimit=128;
    bcc.layerModeNumWLimit=8;
    bcc.imgWLimit=227;
    bcc.featureSizeLimit=[400;400;1];
    bcc.resultMemDepthLimit=[96;55;55];
    bcc.inputMemDepthLimit=[3;227;227];
    bcc.opW=3;
    bcc.debugIDNumWLimit=2^16;
    bcc.debugBankNumWLimit=2^16;
    bcc.blockNumWLimit=4;
    bcc.requestAddrWLimit=32;
    bcc.Fixdt_0_16_0_To_SingleLatency=4;
    bcc.threadNumLimit=threadNumLimit;
    bcc.CONV_TRANS_CTRL_LATENCY=5;
    bcc.halfProgLCFIFODepth=126*3;
    bcc.supportedProfileEvents={'Processor_Start','Processor_Done','Layer_Start','Layer_Done','WeightBurst_Start','WeightBurst_Done'};
    bcc.dataTransNum=dataTransNum;

end


