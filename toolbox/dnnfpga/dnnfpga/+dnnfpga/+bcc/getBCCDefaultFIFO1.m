function bcc=getBCCDefaultFIFO1(conv_threadNumLimit,fc_threadNumLimit,fcOpDataType,opDDRBitWidthLimit)







    if(nargin<4)
        opDDRBitWidthLimit=128;
    end
    bcc.CONV_LIMIT=9216;
    bcc.CONV_THREAD_NUM=conv_threadNumLimit;

    bcc.FC_THREAD_NUM=fc_threadNumLimit;
    bcc.BIN_SIZE=1;

    bcc.CONV_TRANS_CTRL_LATENCY=0;

    bcc.supportedProfileEvents={};
end


