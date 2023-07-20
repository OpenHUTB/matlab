function bcc=getBCCDefaultFIFO2(conv_threadNumLimit,fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit)







    if(nargin<4)
        opDDRBitWidthLimit=128;
    end
    bcc=dnnfpga.bcc.getBCCDefaultFIFO1(conv_threadNumLimit,fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit);
    bcc.CONV_LIMIT=(128+mod(-128,conv_threadNumLimit))*2*6*6;
    bcc.CONV_TRANS_CTRL_LATENCY=5;
    bcc.BIN_SIZE=9;
    bcc.FC_THREAD_NUM=dnnfpga.bcc.getBCCDefaultFC(fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit).threadNumLimit;

end


