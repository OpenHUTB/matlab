function bcc=getBCCDefaultCNN2(conv_threadNumLimit,fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit)







    if(nargin<4)
        opDDRBitWidthLimit=128;
    end
    bcc.conv=dnnfpga.bcc.getBCCDefaultConv2(conv_threadNumLimit,opDDRBitWidthLimit);
    bcc.fc=dnnfpga.bcc.getBCCDefaultFC(fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit);
    bcc.fc.ProdLatency=3;
    bcc.fc.SumLatency=3;
    bcc.fc.CmpLatency=1;
    bcc.conv.imageNumWLimit=128;
    bcc.fc.resultNumWLimit=128;
    bcc.fifo1=dnnfpga.bcc.getBCCDefaultFIFO2(conv_threadNumLimit,fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit);


    bcc.fifo1.BIN_SIZE=9;
end



