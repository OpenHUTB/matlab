function bcc=dnnfpgaInterprocessorfifobaseGetAlexnetBCCFIFO(CONV_THREAD_NUM,FC_THREAD_NUM,fcOpDataType)



    if nargin<1
        CONV_THREAD_NUM=4;
        FC_THREAD_NUM=8;
        fcOpDataType='single';
    elseif nargin<2
        FC_THREAD_NUM=8;
        fcOpDataType='single';
    elseif nargin<3
        fcOpDataType='single';
    end

    bcc=dnnfpga.processorbase.processorUtils.getAlexnetBCCFIFO1(CONV_THREAD_NUM,FC_THREAD_NUM,fcOpDataType);
end

