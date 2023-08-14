function[threadNum]=processorThreadNum(processor)



    bcc=processor.getBCC();

    switch(class(processor))
    case{'dnnfpga.processorbase.fcProcessor'}
        threadNum=bcc.threadNumLimit;
    case{'dnnfpga.processorbase.fc4Processor','dnnfpga.processorbase.fc5Processor'}
        threadNum=bcc.fcp.threadNumLimit;
    case{'dnnfpga.processorbase.cnn2Processor'}
        threadNum=bcc.fc.threadNumLimit;
    case{'dnnfpga.processorbase.cnn4Processor','dnnfpga.processorbase.cnn5Processor'}
        threadNum=bcc.fcp.threadNumLimit;
    otherwise
        threadNum=4;
    end
end


