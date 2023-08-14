function bcc=getBCCDefaultCNN5(conv_threadNumLimit,fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit,convKernelDataType,fcKernelDataType,dataTransNum,addKernelDataType,convRoundingMode,fcRoundingMode,convMemoryMinDepth,fcMemoryMinDepth,customLayerList)




    if(nargin<4)
        opDDRBitWidthLimit=128;
    end

    if(nargin<5)
        convKernelDataType='single';
    end

    if(nargin<6)
        fcKernelDataType='single';
    end

    if(nargin<7)


        dataTransNum=1;
    end

    if(nargin<8)
        addKernelDataType='single';
    end

    if(nargin<9)
        convRoundingMode='Round';
    end

    if(nargin<10)
        fcRoundingMode='Round';
    end

    if(nargin<11)
        convMemoryMinDepth=[32,32,1];
    end

    if(nargin<12)
        fcMemoryMinDepth=1024;
    end

    if(nargin<13)
        customLayerList={};
    end





    dataTransNum=power(2,nextpow2(dataTransNum));


    bcc.convp=dnnfpga.bcc.getBCCDefaultConv4(conv_threadNumLimit,opDDRBitWidthLimit,convKernelDataType,dataTransNum,convRoundingMode,convMemoryMinDepth);

    bcc.fcp=dnnfpga.bcc.getBCCDefaultFC4(fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit,fcKernelDataType,fcRoundingMode,fcMemoryMinDepth);

    bcc.debug=dnnfpga.bcc.getBCCDefaultDebug();

    bcc.dataTransNum=dataTransNum;

    bcc.addp=dnnfpga.bcc.getBCCDefaultAdd(customLayerList,addKernelDataType);


    bcc.fcp.ProdLatency=3;
    bcc.fcp.SumLatency=3;
    bcc.fcp.CmpLatency=1;
    bcc.convp.conv.imageNumWLimit=128;
    bcc.fcp.resultNumWLimit=128;
    bcc.enableAxiStream=false;
end


