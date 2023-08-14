function bcc=getBCCDefaultCNN4(conv_threadNumLimit,fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit,convKernelDataType,fcKernelDataType,dataTransNum,convRoundingMode,fcRoundingMode)







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
        convRoundingMode='Round';
    end

    if(nargin<9)
        fcRoundingMode='Round';
    end





    dataTransNum=power(2,nextpow2(dataTransNum));

    bcc.convp=dnnfpga.bcc.getBCCDefaultConv4(conv_threadNumLimit,opDDRBitWidthLimit,convKernelDataType,dataTransNum,convRoundingMode);
    bcc.fcp=dnnfpga.bcc.getBCCDefaultFC4(fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit,fcKernelDataType,fcRoundingMode);

    bcc.debug=dnnfpga.bcc.getBCCDefaultDebug();

    bcc.dataTransNum=dataTransNum;


    bcc.fcp.ProdLatency=3;
    bcc.fcp.SumLatency=3;
    bcc.fcp.CmpLatency=1;
    bcc.convp.conv.imageNumWLimit=128;
    bcc.fcp.resultNumWLimit=128;

end


