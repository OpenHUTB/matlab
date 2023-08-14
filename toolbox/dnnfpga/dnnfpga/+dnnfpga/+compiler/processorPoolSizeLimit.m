function[poolSizeLimit]=processorPoolSizeLimit(processor)





    getBCC=processor.getBCC();

    switch(class(processor))
    case{'dnnfpga.processorbase.conv2Processor'}
        poolSizeLimit=getBCC.origOpWLimit;
    case{'dnnfpga.processorbase.cnn2Processor'}
        poolSizeLimit=getBCC.conv.origOpWLimit;
    case{'dnnfpga.processorbase.cnn4Processor','dnnfpga.processorbase.cnn5Processor'}
        poolSizeLimit=getBCC.convp.conv.origOpWLimit;
    case{'dnnfpga.processorbase.conv4Processor','dnnfpga.processorbase.conv5Processor'}
        poolSizeLimit=getBCC.conv.origOpWLimit;
    otherwise
        poolSizeLimit=12;
    end
end


